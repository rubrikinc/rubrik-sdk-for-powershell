Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Private/Invoke-RubrikWebRequest' -Tag 'Private', 'Invoke-RubrikWebRequest' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '4.0.5'
    }

    $fakeResponse = [PSCustomObject]@{
        StatusCode = 200
        RawContent = 'HTTP/1.1 200 OK'
    }

    Mock -CommandName Test-UnicodeInString -MockWith { $false }
    Mock -CommandName Invoke-WebRequest -MockWith { $fakeResponse }
    #endregion

    Context -Name 'PS6+ with timeout greater than 99 uses custom TimeoutSec' {
        Mock -CommandName Test-PowerShellSix   -MockWith { $true }
        Mock -CommandName Test-PowerShellSeven -MockWith { $false }

        $global:rubrikOptions = [PSCustomObject]@{
            ModuleOption = [PSCustomObject]@{ DefaultWebRequestTimeOut = 120 }
        }

        It -Name 'Verbose output confirms custom timeout is applied' -Test {
            $output = & {
                Invoke-RubrikWebRequest -Uri 'https://test-server/api' -Headers @{} -Method 'GET' -Body $null -Verbose 4>&1
            }
            (-join $output) | Should -BeLike '*custom timeout of 120 seconds*'
        }
    }

    Context -Name 'PS6+ with timeout of 99 uses default timeout' {
        Mock -CommandName Test-PowerShellSix   -MockWith { $true }
        Mock -CommandName Test-PowerShellSeven -MockWith { $false }

        $global:rubrikOptions = [PSCustomObject]@{
            ModuleOption = [PSCustomObject]@{ DefaultWebRequestTimeOut = 99 }
        }

        It -Name 'Verbose output confirms default timeout is used when value is exactly 99' -Test {
            $output = & {
                Invoke-RubrikWebRequest -Uri 'https://test-server/api' -Headers @{} -Method 'GET' -Body $null -Verbose 4>&1
            }
            (-join $output) | Should -BeLike '*default value of 100 seconds*'
        }
    }

    Context -Name 'PS6+ with empty timeout uses default timeout' {
        Mock -CommandName Test-PowerShellSix   -MockWith { $true }
        Mock -CommandName Test-PowerShellSeven -MockWith { $false }

        $global:rubrikOptions = [PSCustomObject]@{
            ModuleOption = [PSCustomObject]@{ DefaultWebRequestTimeOut = '' }
        }

        It -Name 'Verbose output confirms default timeout is used when value is empty' -Test {
            $output = & {
                Invoke-RubrikWebRequest -Uri 'https://test-server/api' -Headers @{} -Method 'GET' -Body $null -Verbose 4>&1
            }
            (-join $output) | Should -BeLike '*default value of 100 seconds*'
        }
    }

    Context -Name 'PS5 with timeout greater than 99 uses custom TimeoutSec' {
        Mock -CommandName Test-PowerShellSix   -MockWith { $false }
        Mock -CommandName Test-PowerShellSeven -MockWith { $false }

        $global:rubrikOptions = [PSCustomObject]@{
            ModuleOption = [PSCustomObject]@{ DefaultWebRequestTimeOut = 150 }
        }

        It -Name 'Verbose output confirms custom timeout is applied' -Test {
            $output = & {
                Invoke-RubrikWebRequest -Uri 'https://test-server/api' -Headers @{} -Method 'GET' -Body $null -Verbose 4>&1
            }
            (-join $output) | Should -BeLike '*custom timeout of 150 seconds*'
        }
    }

    Context -Name 'PS5 with timeout of 50 uses default timeout' {
        Mock -CommandName Test-PowerShellSix   -MockWith { $false }
        Mock -CommandName Test-PowerShellSeven -MockWith { $false }

        $global:rubrikOptions = [PSCustomObject]@{
            ModuleOption = [PSCustomObject]@{ DefaultWebRequestTimeOut = 50 }
        }

        It -Name 'Verbose output confirms default timeout is used when value is below threshold' -Test {
            $output = & {
                Invoke-RubrikWebRequest -Uri 'https://test-server/api' -Headers @{} -Method 'GET' -Body $null -Verbose 4>&1
            }
            (-join $output) | Should -BeLike '*default value of 100 seconds*'
        }
    }
}
