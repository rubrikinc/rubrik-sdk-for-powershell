Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Sync-RubrikAnnotation' -Tag 'Public', 'Sync-RubrikAnnotation' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '4.0.0'
    }
    #endregion

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter Name cannot be $null' -Test {
            { Sync-RubrikAnnotation -SLA $null } |
                Should -Throw "Cannot validate argument on parameter 'SLA'"
        }
        It -Name 'Parameter Name cannot be empty' -Test {
            { Sync-RubrikAnnotation -SLA '' } |
                Should -Throw "Cannot validate argument on parameter 'SLA'"
        }

    }
}