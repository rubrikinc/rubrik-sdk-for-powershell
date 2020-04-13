Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikModuleOption' -Tag 'Public', 'Get-RubrikModuleOption' -Fixture {
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
    $global:rubrikOptions = @{
        DefaultParameterValue = @{
            PrimaryClusterId = 'local'
            AnotherParameter = 'Value'
        }
        ModuleOption = @{
            ApplyCustomViewDefinitions = 'True'
            CredentialPath = 'c:\\credentialpath\\creds.xml'
        }
    }
    #endregion

    Context -Name 'Results Filtering' {
        It -Name "Should return count of 2" -Test {
            (Get-RubrikModuleOption).Count |
                Should -BeExactly 2
        }
        It -Name "Should return true for ApplyCustomViewDefinitions" -Test {
            (Get-RubrikModuleOption -OptionName "ApplyCustomViewDefinitions").ApplyCustomViewDefinitions |
                Should -BeExactly "True"
        }
    }
}