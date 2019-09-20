Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Sync-RubrikTag' -Tag 'Public', 'Sync-RubrikTag' -Fixture {
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
        
        It -Name 'Parameter category cannot be null or empty' -Test {
            { Sync-RubrikTag -Category $null  } |
                Should -Throw "Cannot validate argument on parameter 'Category'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It -Name 'Parameter category missing' -Test {
            { Sync-RubrikTag -Category  } |
                Should -Throw "Missing an argument for parameter 'Category'. Specify a parameter of type 'System.String' and try again."
        }
    }
}