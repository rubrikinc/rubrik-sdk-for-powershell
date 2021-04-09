Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

Describe -Name 'Public/Get-RubrikDebugInfo' -Tag 'Public', 'Get-RubrikDebugInfo' -Fixture {
    #region init
    $rubrikConnection = @{
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

    Context -Name 'Validate output of cmdlet' {
        It -Name 'Should return correct PSVersion' -Test {
            (Get-RubrikDebugInfo).PSVersion | Should -BeExactly $PSVersionTable.PSVersion
        }

        It -Name 'Should return correct HostConsoleVersion' -Test {
            $WarningPreference = 0
            (Get-RubrikDebugInfo).HostConsoleName | Should -BeExactly $host.Name
        }

        It -Name 'Should return correct Culture' -Test {
            $WarningPreference = 0
            (Get-RubrikDebugInfo).HostCulture | Should -BeExactly $host.CurrentCulture
        }
    }
}