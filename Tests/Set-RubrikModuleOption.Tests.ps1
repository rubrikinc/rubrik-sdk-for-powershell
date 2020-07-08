Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikModuleOption' -Tag 'Public', 'Set-RubrikModuleOption' -Fixture {
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
    Context -Name 'Option Validation' {

        It -Name "Should throw not found error" -Test {
            {Set-RubrikModuleOption -OptionName 'Test' -OptionValue 'Value' } |
                Should -Throw '''OptionName''. The argument "Test" does not belong to the set "ApplyCustomViewDefinitions,CredentialPath,DefaultWebRequestTimeOut" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.'
        }

    }
    Context -Name 'Parameter Validation' {
        It -Name "Should throw ParameterSet Error" -Test {
            { Set-RubrikModuleOption -OptionName 'ApplyCustomViewDefinitions' -Sync } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }

    }
}