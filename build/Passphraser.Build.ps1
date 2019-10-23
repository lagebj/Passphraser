#Requires -Modules psake

##############################################################################
# DO NOT MODIFY THIS FILE!  Modify Nmh.Ps.Core.Build.Settings.ps1 instead.
##############################################################################

###############################################################################
# Dot source customized properties and extension tasks.
###############################################################################
. $PSScriptRoot\Passphraser.Build.Settings.ps1

###############################################################################
# Private properties.
###############################################################################
Properties {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $UpdatableHelpOutDir = "$DocsRootDir\cab"

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $LineSep = "-" * 78
}

Task Default -depends Build

Task StageFiles -depends BeforeStageFiles, AfterStageFiles {
}

Task Build -depends BeforeBuild, StageFiles, Analyze, Sign, AfterBuild {
}

Task Analyze -depends StageFiles `
    -requiredVariables ScriptAnalysisEnabled, ScriptAnalysisFailBuildOnSeverityLevel, ScriptAnalyzerSettingsPath {
    if (!$ScriptAnalysisEnabled) {
        "Script analysis is not enabled. Skipping $($psake.context.currentTaskName) task."
        return
    }

    if (!(Get-Module PSScriptAnalyzer -ListAvailable)) {
        "PSScriptAnalyzer module is not installed. Skipping $($psake.context.currentTaskName) task."
        return
    }

    "ScriptAnalysisFailBuildOnSeverityLevel set to: $ScriptAnalysisFailBuildOnSeverityLevel"

    $analysisResult = Invoke-ScriptAnalyzer -Path $ScriptsRootDir -Settings $ScriptAnalyzerSettingsPath -Recurse -Verbose:$VerbosePreference
    $analysisResult | Format-Table
    switch ($ScriptAnalysisFailBuildOnSeverityLevel) {
        'None' {
            return
        }
        'Error' {
            Assert -conditionToCheck (
                ($analysisResult | Where-Object Severity -eq 'Error').Count -eq 0
            ) -failureMessage 'One or more ScriptAnalyzer errors were found. Build cannot continue!'
        }
        'Warning' {
            Assert -conditionToCheck (
                ($analysisResult | Where-Object {
                        $_.Severity -eq 'Warning' -or $_.Severity -eq 'Error'
                    }).Count -eq 0) -failureMessage 'One or more ScriptAnalyzer warnings were found. Build cannot continue!'
        }
        default {
            Assert -conditionToCheck (
                $analysisResult.Count -eq 0
            ) -failureMessage 'One or more ScriptAnalyzer issues were found. Build cannot continue!'
        }
    }
}

Task Sign -depends StageFiles -requiredVariables CertPath, SettingsPath, ScriptSigningEnabled {
    if (!$ScriptSigningEnabled) {
        "Script signing is not enabled. Skipping $($psake.context.currentTaskName) task."
        return
    }

    $validCodeSigningCerts = Get-ChildItem -Path $CertPath -CodeSigningCert -Recurse | Where-Object NotAfter -ge (Get-Date)
    if (!$validCodeSigningCerts) {
        throw "There are no non-expired code-signing certificates in $CertPath. You can either install " +
        "a code-signing certificate into the certificate store or disable script analysis in Nmh.Ps.Core.Build.Settings.ps1."
    }

    $certSubjectNameKey = "CertSubjectName"
    $storeCertSubjectName = $true

    # Get the subject name of the code-signing certificate to be used for script signing.
    if (!$CertSubjectName -and ($CertSubjectName = GetSetting -Key $certSubjectNameKey -Path $SettingsPath)) {
        $storeCertSubjectName = $false
    } elseif (!$CertSubjectName) {
        "A code-signing certificate has not been specified."
        "The following non-expired, code-signing certificates are available in your certificate store:"
        $validCodeSigningCerts | Format-List Subject, Issuer, Thumbprint, NotBefore, NotAfter

        $CertSubjectName = Read-Host -Prompt 'Enter the subject name (case-sensitive) of the certificate to use for script signing'
    }

    # Find a code-signing certificate that matches the specified subject name.
    $certificate = $validCodeSigningCerts |
    Where-Object { $_.SubjectName.Name -cmatch [regex]::Escape($CertSubjectName) } |
    Sort-Object NotAfter -Descending | Select-Object -First 1

    if ($certificate) {
        $SharedProperties.CodeSigningCertificate = $certificate

        if ($storeCertSubjectName) {
            SetSetting -Key $certSubjectNameKey -Value $certificate.SubjectName.Name -Path $SettingsPath
            "The new certificate subject name has been stored in ${SettingsPath}."
        } else {
            "Using stored certificate subject name $CertSubjectName from ${SettingsPath}."
        }

        "Using code-signing certificate: $certificate"

        $files = @(Get-ChildItem -Path $ModuleRootDir\* -Recurse -Include *.ps1, *.psm1)
        foreach ($file in $files) {
            $setAuthSigParams = @{
                FilePath    = $file.FullName
                Certificate = $certificate
                Verbose     = $VerbosePreference
            }

            $result = Microsoft.PowerShell.Security\Set-AuthenticodeSignature @setAuthSigParams
            if ($result.Status -ne 'Valid') {
                throw "Failed to sign script: $($file.FullName)."
            }

            "Successfully signed script: $($file.Name)"
        }
    } else {
        $expiredCert = Get-ChildItem -Path $CertPath -CodeSigningCert -Recurse |
        Where-Object { ($_.SubjectName.Name -cmatch [regex]::Escape($CertSubjectName)) -and
            ($_.NotAfter -lt (Get-Date)) }
        Sort-Object NotAfter -Descending | Select-Object -First 1

        if ($expiredCert) {
            throw "The code-signing certificate `"$($expiredCert.SubjectName.Name)`" EXPIRED on $($expiredCert.NotAfter)."
        }

        throw 'No valid certificate subject name supplied or stored.'
    }
}

Task BuildHelp -depends Build, BeforeBuildHelp, GenerateMarkdown, GenerateHelpFiles, AfterBuildHelp {
}

Task GenerateMarkdown -requiredVariables DefaultLocale, DocsRootDir, ModuleName, ModuleRootDir {
    if (!(Get-Module platyPS -ListAvailable)) {
        "platyPS module is not installed. Skipping $($psake.context.currentTaskName) task."
        return
    }

    $moduleInfo = Import-Module $ModuleRootDir\$ModuleName.psd1 -Global -Force -PassThru

    try {
        if ($moduleInfo.ExportedCommands.Count -eq 0) {
            "No commands have been exported. Skipping $($psake.context.currentTaskName) task."
            return
        }

        if (!(Test-Path -LiteralPath $DocsRootDir)) {
            New-Item $DocsRootDir -ItemType Directory > $null
        }

        if (Get-ChildItem -LiteralPath $DocsRootDir -Filter *.md -Recurse) {
            Get-ChildItem -LiteralPath $DocsRootDir -Directory | ForEach-Object {
                Update-MarkdownHelp -Path $_.FullName -Verbose:$VerbosePreference > $null
            }
        }

        # ErrorAction set to SilentlyContinue so this command will not overwrite an existing MD file.
        New-MarkdownHelp -Module $ModuleName -Locale $DefaultLocale -OutputFolder "$DocsRootDir\Markdown" `
            -WithModulePage -ErrorAction SilentlyContinue -Verbose:$VerbosePreference > $null
    } finally {
        Remove-Module $ModuleName
    }
}

Task GenerateHelpFiles -requiredVariables DocsRootDir, ModuleName, ModuleRootDir {
    if (!(Get-Module platyPS -ListAvailable)) {
        "platyPS module is not installed. Skipping $($psake.context.currentTaskName) task."
        return
    }

    if (!(Get-ChildItem -LiteralPath $DocsRootDir -Filter *.md -Recurse -ErrorAction SilentlyContinue)) {
        "No markdown help files to process. Skipping $($psake.context.currentTaskName) task."
        return
    }

    $helpLocales = (Get-ChildItem -Path "$DocsRootDir\locales" -Directory).Name

    # Generate the module's primary MAML help file.
    foreach ($locale in $helpLocales) {
        New-ExternalHelp -Path "$DocsRootDir\markdown" -OutputPath "$DocsRootDir\locales\$locale" -Force `
            -ErrorAction SilentlyContinue -Verbose:$VerbosePreference > $null
    }
}

Task BuildUpdatableHelp -depends BuildHelp, BeforeBuildUpdatableHelp, CoreBuildUpdatableHelp, AfterBuildUpdatableHelp {
}

Task CoreBuildUpdatableHelp -requiredVariables DocsRootDir, ModuleName, UpdatableHelpOutDir {
    if (!(Get-Module platyPS -ListAvailable)) {
        "platyPS module is not installed. Skipping $($psake.context.currentTaskName) task."
        return
    }

    $helpLocales = (Get-ChildItem -Path "$DocsRootDir\locales" -Directory).Name

    # Create updatable help output directory.
    if (!(Test-Path -LiteralPath "$DocsRootDir\cab")) {
        New-Item "$DocsRootDir\cab" -ItemType Directory -Verbose:$VerbosePreference > $null
    } else {
        Write-Verbose "$($psake.context.currentTaskName) - directory already exists '$DocsRootDir\cab'."
        Get-ChildItem "$DocsRootDir\cab" | Remove-Item -Recurse -Force -Verbose:$VerbosePreference
    }

    # Generate updatable help files.  Note: this will currently update the version number in the module's MD
    # file in the metadata.
    foreach ($locale in $helpLocales) {
        New-ExternalHelpCab -CabFilesFolder "$DocsRootDir\locales\$locale" -LandingPagePath "$DocsRootDir\markdown\$ModuleName.md" `
            -OutputFolder "$DocsRootDir\cab" -Verbose:$VerbosePreference > $null
    }
}

Task GenerateFileCatalog -depends Build, BuildHelp, BeforeGenerateFileCatalog, CoreGenerateFileCatalog, AfterGenerateFileCatalog {
}

Task CoreGenerateFileCatalog -requiredVariables CatalogGenerationEnabled, CatalogVersion, ModuleName, ModuleRootDir {
    if (!$CatalogGenerationEnabled) {
        "FileCatalog generation is not enabled. Skipping $($psake.context.currentTaskName) task."
        return
    }

    if (!(Get-Command Microsoft.PowerShell.Security\New-FileCatalog -ErrorAction SilentlyContinue)) {
        "FileCatalog commands not available on this version of PowerShell. Skipping $($psake.context.currentTaskName) task."
        return
    }

    $catalogFilePath = "$DocsRootDir\cab\$ModuleName.cat"

    $newFileCatalogParams = @{
        Path            = $ModuleRootDir
        CatalogFilePath = $catalogFilePath
        CatalogVersion  = $CatalogVersion
        Verbose         = $VerbosePreference
    }

    Microsoft.PowerShell.Security\New-FileCatalog @newFileCatalogParams > $null

    if ($ScriptSigningEnabled) {
        if ($SharedProperties.CodeSigningCertificate) {
            $setAuthSigParams = @{
                FilePath    = $catalogFilePath
                Certificate = $SharedProperties.CodeSigningCertificate
                Verbose     = $VerbosePreference
            }

            $result = Microsoft.PowerShell.Security\Set-AuthenticodeSignature @setAuthSigParams
            if ($result.Status -ne 'Valid') {
                throw "Failed to sign file catalog: $($catalogFilePath)."
            }

            "Successfully signed file catalog: $($catalogFilePath)"
        } else {
            "No code-signing certificate was found to sign the file catalog."
        }
    } else {
        "Script signing is not enabled. Skipping signing of file catalog."
    }

    Move-Item -LiteralPath $newFileCatalogParams.CatalogFilePath -Destination $ModuleRootDir
}

Task Test -depends Build -requiredVariables TestRootDir, ModuleName, CodeCoverageEnabled, CodeCoverageFiles {
    if (!(Get-Module Pester -ListAvailable)) {
        "Pester module is not installed. Skipping $($psake.context.currentTaskName) task."
        return
    }

    Import-Module Pester

    try {
        Microsoft.PowerShell.Management\Push-Location -LiteralPath $TestRootDir

        if ($TestOutputFile) {
            $testing = @{
                OutputFile   = $TestOutputFile
                OutputFormat = $TestOutputFormat
                PassThru     = $true
                Verbose      = $VerbosePreference
            }
        } else {
            $testing = @{
                PassThru = $true
                Verbose  = $VerbosePreference
            }
        }

        # To control the Pester code coverage, a boolean $CodeCoverageEnabled is used.
        if ($CodeCoverageEnabled) {
            $testing.CodeCoverage = $CodeCoverageFiles
        }

        $testResult = Invoke-Pester @testing

        Assert -conditionToCheck (
            $testResult.FailedCount -eq 0
        ) -failureMessage "One or more Pester tests failed, build cannot continue."

        if ($CodeCoverageEnabled) {
            $testCoverage = [int]($testResult.CodeCoverage.NumberOfCommandsExecuted /
                $testResult.CodeCoverage.NumberOfCommandsAnalyzed * 100)
            "Pester code coverage on specified files: ${testCoverage}%"
        }
    } finally {
        Microsoft.PowerShell.Management\Pop-Location
        Remove-Module $ModuleName -ErrorAction SilentlyContinue
    }
}

###############################################################################
# Secondary/utility tasks - typically used to manage stored build settings.
###############################################################################

Task ? -description 'Lists the available tasks' {
    "Available tasks:"
    $psake.context.Peek().Tasks.Keys | Sort-Object
}

Task RemoveCertSubjectName -requiredVariables SettingsPath {
    if (GetSetting -Path $SettingsPath -Key CertSubjectName) {
        RemoveSetting -Path $SettingsPath -Key CertSubjectName
    }
}

Task StoreCertSubjectName -requiredVariables SettingsPath {
    $certSubjectName = 'CN='
    $certSubjectName += Read-Host -Prompt 'Enter the certificate subject name for script signing. Use exact casing, CN= prefix will be added'
    SetSetting -Key CertSubjectName -Value $certSubjectName -Path $SettingsPath
    "The new certificate subject name '$certSubjectName' has been stored in ${SettingsPath}."
}

Task ShowCertSubjectName -requiredVariables SettingsPath {
    $CertSubjectName = GetSetting -Path $SettingsPath -Key CertSubjectName
    "The stored certificate is: $CertSubjectName"

    $cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert |
    Where-Object { $_.Subject -eq $CertSubjectName -and $_.NotAfter -gt (Get-Date) } |
    Sort-Object -Property NotAfter -Descending | Select-Object -First 1

    if ($cert) {
        "A valid certificate for the subject $CertSubjectName has been found"
    } else {
        'A valid certificate has not been found'
    }
}

###############################################################################
# Helper functions
###############################################################################
function PromptUserForCredentialAndStorePassword {
    [Diagnostics.CodeAnalysis.SuppressMessage("PSProvideDefaultParameterValue", '')]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $DestinationPath,

        [Parameter(Mandatory)]
        [string]
        $Message,

        [Parameter(Mandatory, ParameterSetName = 'SaveSetting')]
        [string]
        $Key
    )

    $cred = Get-Credential -Message $Message -UserName "ignored"
    if ($DestinationPath) {
        SetSetting -Key $Key -Value $cred.Password -Path $DestinationPath
    }

    $cred
}

function AddSetting {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSShouldProcess', '', Scope = 'Function')]
    param(
        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Value
    )

    switch ($type = $Value.GetType().Name) {
        'securestring' { $setting = $Value | ConvertFrom-SecureString }
        default { $setting = $Value }
    }

    if (Test-Path -LiteralPath $Path) {
        $storedSettings = Import-Clixml -Path $Path
        $storedSettings.Add($Key, @($type, $setting))
        $storedSettings | Export-Clixml -Path $Path
    } else {
        $parentDir = Split-Path -Path $Path -Parent
        if (!(Test-Path -LiteralPath $parentDir)) {
            New-Item $parentDir -ItemType Directory > $null
        }

        @{$Key = @($type, $setting) } | Export-Clixml -Path $Path
    }
}

function GetSetting {
    param(
        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        $securedSettings = Import-Clixml -Path $Path
        if ($securedSettings.$Key) {
            switch ($securedSettings.$Key[0]) {
                'securestring' {
                    $value = $securedSettings.$Key[1] | ConvertTo-SecureString
                    $cred = New-Object -TypeName PSCredential -ArgumentList 'jpgr', $value
                    $cred.GetNetworkCredential().Password
                }
                default {
                    $securedSettings.$Key[1]
                }
            }
        }
    }
}

function SetSetting {
    param(
        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Value
    )

    if (GetSetting -Key $Key -Path $Path) {
        RemoveSetting -Key $Key -Path $Path
    }

    AddSetting -Key $Key -Value $Value -Path $Path
}

function RemoveSetting {
    param(
        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        $storedSettings = Import-Clixml -Path $Path
        $storedSettings.Remove($Key)
        if ($storedSettings.Count -eq 0) {
            Remove-Item -Path $Path
        } else {
            $storedSettings | Export-Clixml -Path $Path
        }
    } else {
        Write-Warning "The build setting file '$Path' has not been created yet."
    }
}

