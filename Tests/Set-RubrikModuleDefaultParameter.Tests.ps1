Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikModuleDefaultParameter' -Tag 'Public', 'Set-RubrikModuleDefaultParameter' -Fixture {
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
    $GlobalOptionsJson = '{
        "DefaultParameterValue": {
          "PrimaryClusterId": "local",
          "AnotherParameter": "Value"
        },
        "ModuleOption": {
          "ApplyCustomViewDefinitions": "True",
          "CredentialPath": "c:\\credentialpath\\creds.xml"
        }
      }'
      $global:rubrikOptions = $GlobalOptionsJson | ConvertFrom-Json
    #endregion
    Context -Name 'Parameter Validation' {
        It -Name "Should throw ParameterSet Error" -Test {
            { Set-RubrikModuleDefaultParameter -ParameterName 'Test' -Sync } |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }

    }

}