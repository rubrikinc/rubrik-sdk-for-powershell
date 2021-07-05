Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Test-UnicodeInString' -Tag 'Public', 'Test-UnicodeInString' -Fixture {
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
    #endregion
    Context -Name 'Parameter Validation' {
        
        It -Name 'String param with $null should return $false' -Test {
            Test-UnicodeInString -String $null |
                Should -Be $false
        }
        
        $String = @'
AbCdE12345!@#$%
'@        
        It -Name "String param with '$String' should return `$false" -Test {
            Test-UnicodeInString -String $String |
                Should -Be $false
        }

        $String = @'
おはよう日本
'@
        It -Name "String param with '$String' should return `$true" -Test {
            Test-UnicodeInString -String $String |
                Should -Be $true
        }

        $String = @'
🦏 🦑 🦖 🦓 🦋 🦁
'@
It -Name "String param with '$String' should return `$true" -Test {
    Test-UnicodeInString -String $String |
                Should -Be $true
        }
    }
}