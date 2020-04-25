Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikModuleDefaultParameter' -Tag 'Public', 'Get-RubrikModuleDefaultParameter' -Fixture {
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
          "AnotherParameter": "test"
        },
        "ModuleOption": {
          "ApplyCustomViewDefinitions": "True",
          "DefaultWebRequestTimeout": "",
          "CredentialPath": ""
        }
      }'
    $global:rubrikOptions = $GlobalOptionsJson | ConvertFrom-Json

    #endregion

    Context -Name 'Results Filtering' {
        It -Name "Should test for value" -Test {
            (Get-RubrikModuleDefaultParameter -ParameterName AnotherParameter).AnotherParameter |
                Should -BeExactly "test"
        }
        It -Name "Should contain two properties" -Test {
          ((Get-RubrikModuleDefaultParameter).PSObject.Properties | ? MemberType -eq "NoteProperty").count |
             Should -BeExactly 2
     }
    }
}