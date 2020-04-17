Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Sync-RubrikOptionsFile' -Tag 'Public', 'Sync-RubrikOptionsFile'  -Fixture {
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

    Context -Name 'File Operations' {

        $GlobalOptionsJson = '{
            "DefaultParameterValue": {
              "PrimaryClusterId": "11111-22222-33333-44444-55555"
            },
            "ModuleOption": {
              "ApplyCustomViewDefinitions": "True",
              "DefaultWebRequestTimeout": "",
              "CredentialPath": "c:\\creds\\creds.xml"
            }
          }'
          $global:rubrikOptions = $GlobalOptionsJson | ConvertFrom-Json

        Mock -CommandName Copy-Item -Verifiable -MockWith {
            $GlobalOptionsJson = '{
                "DefaultParameterValue": {
                  "PrimaryClusterId": "11111-22222-33333-44444-55555"
                },
                "ModuleOption": {
                  "ApplyCustomViewDefinitions": "True",
                  "DefaultWebRequestTimeout": "",
                  "CredentialPath": "c:\\creds\\creds.xml"
                }
              }'
              $GlobalOptionsJson | Out-File $Home\rubrik_sdk_for_powershell_options.json
        }
        Mock -CommandName Get-Content -Verifiable -MockWith {
            return '{
                "DefaultParameterValue": {
                  "PrimaryClusterId": "11111-22222-33333-44444-55555"
                },
                "ModuleOption": {
                  "ApplyCustomViewDefinitions": "True",
                  "DefaultWebRequestTimeout": "",
                  "CredentialPath": "c:\\creds\\creds.xml"
                }
              }'
        } -ParameterFilter {$Path -eq "$Home\rubrik_sdk_for_powershell_options.json"}
        Mock -CommandName Get-Content -Verifiable -MockWith {
            return '{
                "DefaultParameterValue": {

                },
                "ModuleOption": {
                  "ApplyCustomViewDefinitions": "True",
                  "DefaultWebRequestTimeout": "",
                  "CredentialPath": "",
                  "NewDefaultOption": "True"
                }
              }'
        } -ParameterFilter {$Path -like "*OptionsDefault*"}

        # temporarily rename options file in event test is run locally
        if (Test-Path $Home\rubrik_sdk_for_powershell_options.json) {
            Move-Item -Path $Home\rubrik_sdk_for_powershell_options.json -Destination $Home\rubrik_sdk_for_powershell_options.json.pester -Force
        }

        It -Name "Should create file" -Test {
            $global:rubrikOptions = Sync-RubrikOptionsFile
            Test-Path $Home\rubrik_sdk_for_powershell_options.json |
                Should -BeExactly $true
        }
        It -Name "Should add NewDefaultOption" -Test {
            $global:rubrikOptions.ModuleOption.NewDefaultOption |
                Should -Be "True"
        }
        It -Name "CredentialPath value is maintained" -Test {
            $global:rubrikOptions.ModuleOption.CredentialPath |
                Should -Be "c:\creds\creds.xml"
        }
        It -Name "PrimaryClusterId value is maintained" -Test {
            $global:rubrikOptions.DefaultParameterValue.PrimaryClusterId |
                Should -Be "11111-22222-33333-44444-55555"
        }

        # restore original options file in event tests are run locally
        Move-Item -Path $Home\rubrik_sdk_for_powershell_options.json.pester -Destination $Home\rubrik_sdk_for_powershell_options.json -Force

    }


}