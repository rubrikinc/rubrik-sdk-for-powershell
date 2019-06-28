Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Remove-RubrikAPIToken' -Tag 'Public', 'Remove-RubrikAPIToken' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '5.0.0'
    }
    #endregion

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter TokenId cannot be $null' -Test {
            { Remove-RubrikAPIToken -TokenId $null } |
                Should -Throw "Cannot validate argument on parameter 'TokenId'"
        }
        It -Name 'Parameter TokenId cannot be empty' -Test {
            { Remove-RubrikAPIToken -TokenId '' } |
                Should -Throw "Cannot validate argument on parameter 'TokenId'"
        }
    }
}