Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Private/Set-RubrikDefaultParameterValues.Tests.ps1' -Tag 'Private', 'Set-RubrikDefaultParameterValues' -Fixture {
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
          "PrimaryClusterId": "local"
        },
        "ModuleOption": {
          "ApplyCustomViewDefinitions": "True",
          "DefaultWebRequestTimeout": "",
          "CredentialPath": ""
        }
      }'
    $global:rubrikOptions = $GlobalOptionsJson | ConvertFrom-Json
    Set-RubrikDefaultParameterValues
    #endregion
    Context -Name 'Defaults are applied' -Fixture {

        It -Name "PrimaryClusterId should exist and be local" -Test {

            $Global:PSDefaultParameterValues."*Rubrik*:PrimaryClusterId" |
                Should be "local"
        }
    }

}