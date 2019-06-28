Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikAPIToken' -Tag 'Public', 'New-RubrikAPIToken' -Fixture {
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
        It -Name 'Parameter Expiration cannot be $null' -Test {
            { New-RubrikAPIToken -Expiration $null } |
                Should -Throw "Cannot validate argument on parameter 'Expiration'"
        }
        It -Name 'Parameter Expiration cannot be empty' -Test {
            { New-RubrikAPIToken -Expiration '' } |
                Should -Throw "Cannot validate argument on parameter 'Expiration'"
        }
        It -Name 'Parameter OrganizationId cannot be $null' -Test {
            { New-RubrikAPIToken -OrganizationId $null } |
                Should -Throw "Cannot validate argument on parameter 'OrganizationId'"
        }
        It -Name 'Parameter OrganizationId cannot be empty' -Test {
            { New-RubrikAPIToken -OrganizationId '' } |
                Should -Throw "Cannot validate argument on parameter 'OrganizationId'"
        }
    }
}