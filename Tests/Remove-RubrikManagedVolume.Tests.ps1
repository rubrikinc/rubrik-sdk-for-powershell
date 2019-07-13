Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Remove-RubrikManagedVolume' -Tag 'Public', 'Remove-RubrikManagedVolume' -Fixture {
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
    #endregion

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter id cannot be $null' -Test {
            { Remove-RubrikManagedVolume -id $null } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
        It -Name 'Parameter id cannot be empty' -Test {
            { Remove-RubrikManagedVolume -id '' } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
    }
}