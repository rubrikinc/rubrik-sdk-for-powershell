Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Invoke-RubrikVgfUpgrade' -Tag 'Public', 'Invoke-RubrikVgfUpgrade' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '5.3'
    }
    #endregion

    Context -Name 'Parameter Validation' {
        It -Name 'VGList cannot be null' -Test {
            { Invoke-RubrikVgfUpgrade -VGList $null } |
                Should -Throw "Cannot validate argument on parameter 'VGList'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It -Name 'VGList cannot be empty' -Test {
            { Invoke-RubrikVgfUpgrade -VGList '' } |
                Should -Throw "Cannot validate argument on parameter 'VGList'. The argument is null, empty, or an element of the argument collection contains a null value. Supply a collection that does not contain any null values and then try the command again."
        }
    }
}