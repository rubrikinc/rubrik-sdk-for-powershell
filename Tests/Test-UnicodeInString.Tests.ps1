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
        It -Name 'String param with "AbCdE12345!@#$%" should return $false' -Test {
            Test-UnicodeInString -String "AbCdE12345!@#$%" |
                Should -Be $false
        }
        It -Name 'String param "おはよう日本" should return $true' -Test {
            Test-UnicodeInString -String "おはよう日本" |
                Should -Be $true
        }
        It -Name 'String param "🦏 🦑 🦖 🦓 🦋 🦁" should return $true' -Test {
            Test-UnicodeInString -String "🦏 🦑 🦖 🦓 🦋 🦁" |
                Should -Be $true
        }
    }
}