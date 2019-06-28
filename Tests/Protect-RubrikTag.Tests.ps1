Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Protect-RubrikTag' -Tag 'Public', 'Protect-RubrikTag' -Fixture {
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
        It -Name 'Parameter Tag is mandatory' -Test {
            { Protect-RubrikTag } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameter Category is mandatory' -Test {
            { Protect-RubrikTag -Tag 'mytag' } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameter Tag is null or empty' -Test {
            { Protect-RubrikTag -Tag '' -Category 'mycategory'} |
                Should -Throw "Cannot bind argument to parameter 'Tag' because it is an empty string."
        }
        It -Name 'Parameter Category is null or empty' -Test {
            { Protect-RubrikTag -Tag 'mytag' -Category $null} |
                Should -Throw "Cannot bind argument to parameter 'Category' because it is an empty string."
        }

    }
}