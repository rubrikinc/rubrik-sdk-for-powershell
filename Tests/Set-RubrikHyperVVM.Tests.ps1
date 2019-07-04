Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikHyperVVM' -Tag 'Public', 'Set-RubrikHyperVVM' -Fixture {
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
        It -Name 'Parameter ID cannot be $null' -Test {
            { Set-RubrikHyperVVM -Id $null } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Set-RubrikHyperVVM -Id '' } |
                Should -Throw "Cannot validate argument on parameter 'ID'"
        }
    }
}