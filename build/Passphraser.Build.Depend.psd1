@{ 
    PSDependOptions  = @{ 
        Target    = '$DependencyPath/_build-cache/'
        AddToPath = $true
    }
    psake            = 'latest'
    BuildHelpers     = 'latest'
    PSScriptAnalyzer = 'latest'
    Pester           = @{
        Version = 'latest'
    }
}