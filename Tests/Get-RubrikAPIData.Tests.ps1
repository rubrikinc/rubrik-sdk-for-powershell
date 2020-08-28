Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Private/Get-RubrikAPIData' -Tag 'Private', 'Get-RubrikAPIData' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '4.0'
    }

    #Function List
    $ignorelist = @('Invoke-RubrikRESTCall','Invoke-RubrikGraphQLCall','Move-RubrikMountVMDK','Sync-RubrikAnnotation','Sync-RubrikTag','Get-RubrikModuleDefaultParameter','Set-RubrikModuleDefaultParameter','Get-RubrikModuleOption','Set-RubrikModuleOption','Remove-RubrikModuleDefaultParameter','Get-RubrikDownloadLink','Start-RubrikDownload')
    $functions = ( Get-ChildItem -Path './Rubrik/Public' | Where-Object extension -eq '.ps1').Name.Replace('.ps1','')
    $functions = $functions | Where-Object {$ignorelist -notcontains $_}

    #CDM versions
    $versions = @('4.0','4.1','4.2','5.0','5.1','5.2','5.3')

    $cases = foreach($function in $functions){
        @{'v'=$versions;'f' = $function}
    }
    #endregion

    Context -Name "Function specific tests" -Fixture {
        # This variable contains an array of functions that should be excluded from API endpoint testing
        $ExcludedFunctions = @(
            'Get-RubrikObject'
            'Get-RubrikDatabaseRecoveryPoint'
            'Get-RubrikVgfClusterStorage'
            'Get-RubrikVgfReport'
            'Get-RubrikVgfUpgradeReport'
        )

        it -Name "Get-RubrikAPIData - <f> test" -TestCases $cases {
            param($v,$f)
            if ($ExcludedFunctions -contains $f) {
                $methodresult = $true
                $uriresult = $true
            } else {
                $v | ForEach-Object -Begin {
                    $methodresult = New-Object System.Collections.Generic.List[System.Boolean]
                    $uriresult = New-Object System.Collections.Generic.List[System.Boolean]
                } -Process {
                    $global:rubrikConnection.version = $_
                    try {
                        $resources = Get-RubrikAPIData -endpoint $f
                        $methodresult.add($resources.Method -In @('Get','Post','Patch','Delete','Put')) | Out-Null
                        $uriresult.add($null -ne $resources.URI) | Out-Null
                    } catch {}
                }
            }

            $methodresult | Should -Contain $true
            $uriresult | Should -Contain $true
        }
    }

    Context -Name "Should contain Function property as output" {
        It -Name 'Verify property exists' -Test {
            $functions = ( Get-ChildItem -Path './Rubrik/Public' |
                Where-Object extension -eq '.ps1').Name.Replace('.ps1','')
            $ignorelist = @('Invoke-RubrikRESTCall','Invoke-RubrikGraphQLCall','Move-RubrikMountVMDK','Sync-RubrikAnnotation','Sync-RubrikTag','Get-RubrikObject','Get-RubrikDatabaseRecoveryPoint','Get-RubrikModuleDefaultParameter','Set-RubrikModuleDefaultParameter','Get-RubrikModuleOption','Set-RubrikModuleOption','Remove-RubrikModuleDefaultParameter', 'Get-RubrikDownloadLink','Start-RubrikDownload','Get-RubrikVgfClusterStorage','Get-RubrikVgfReport','Get-RubrikVgfUpgradeReport')
            $functions = $functions | Where-Object {$ignorelist -notcontains $_}
            $functions | ForEach-Object {
                (Get-RubrikAPIData -Endpoint $_).Function |
                Should -BeExactly $_
            }
        }
    }

    Context -Name "Failure tests, validate incorrect input" -Fixture {
        It -Name 'Get-RubrikAPIData - Incorrect version number, should fail' -Test {
            '0.1337' | ForEach-Object -Begin {
                $methodresult = New-Object System.Collections.Generic.List[System.Boolean]
                $uriresult = New-Object System.Collections.Generic.List[System.Boolean]
            } -Process {
                $global:rubrikConnection.version = $_
                try {
                    $resources = Get-RubrikAPIData -endpoint Connect-Rubrik
                    $methodresult.add($resources.Method -In @('Get','Post','Patch','Delete','Put')) | Out-Null
                    $uriresult.add($null -ne $resources.URI) | Out-Null
                } catch {}
            }

            $methodresult | Should -Not -Contain $true
            $uriresult | Should -Not -Contain $true
        }

        It -Name 'Get-RubrikAPIData - Non-existent function, should fail' -Test {
            '4.2','5.0' | ForEach-Object -Begin {
                $methodresult = New-Object System.Collections.Generic.List[System.Boolean]
                $uriresult = New-Object System.Collections.Generic.List[System.Boolean]
            } -Process {
                $global:rubrikConnection.version = $_
                try {
                    $resources = Get-RubrikAPIData -endpoint Initialize-RoxieAtRubrik
                    $methodresult.add($resources.Method -In @('Get','Post','Patch','Delete','Put')) | Out-Null
                    $uriresult.add($null -ne $resources.URI) | Out-Null
                } catch {}
            }

            $methodresult | Should -Not -Contain $true
            $uriresult | Should -Not -Contain $true
        }
    }
}
