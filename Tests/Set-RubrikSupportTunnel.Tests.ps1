Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikSupportTunnel' -Tag 'Public', 'Set-RubrikSupportTunnel' -Fixture {
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
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'inactivityTimeoutInSeconds'        = '1000'
                'port'                              = '11874'
                'isTunnelEnabled'                   = 'True'
            }
        }
        It -Name 'Enabling Tunnel' -Test {
            (Set-RubrikSupportTunnel -EnableTunnel $true).isTunnelEnabled |
                Should -BeExactly 'True'
        }
        It -Name 'Parameter EnableTunnel cannot be $null' -Test {
            { Set-RubrikSupportTunnel -EnableTunnel $null } |
                Should -Throw "Cannot process argument transformation on parameter 'EnableTunnel'. Cannot convert value `"`" to type `"System.Boolean`". Boolean parameters accept only Boolean values and numbers, such as `$True, `$False, 1 or 0."
        }
        It -Name 'Parameter EnableTunnel must be specified' -Test {
            { Set-RubrikSupportTunnel -EnableTunnel } |
                Should -Throw "Missing an argument for parameter 'EnableTunnel'. Specify a parameter of type 'System.Boolean' and try again."
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Exactly 1
    }
}