Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Update-RubrikModuleOption' -Tag 'Public', 'Update-RubrikModuleOption'  -Fixture {
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
          "PrimaryClusterId": "11111",
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

    Context -Name 'ModuleOption Add/Sync' {
        Mock -CommandName Sync-RubrikOptionsFile -ModuleName 'Rubrik' -MockWith {
            return $global:rubrikOptions
        }

        Mock -CommandName Get-HomePath -Verifiable -MockWith {
            'TestDrive:\'
        }

        It -Name "ApplyCustomViewDefinitions should remain true" -Test {
            Update-RubrikModuleOption -Sync
            $global:rubrikOptions.ModuleOption.ApplyCustomViewDefinitions |
                Should -BeExactly 'True'
        }
        It -Name "ApplyCustomViewDefinitions should change to False" -Test {
            Update-RubrikModuleOption -OptionName 'ApplyCustomViewDefinitions' -OptionValue 'False' -OptionType "ModuleOption" -Action "AddUpdate"
            $global:rubrikOptions.ModuleOption.ApplyCustomViewDefinitions |
                Should -BeExactly 'False'
        }
    }

    Context -Name 'DefaultParameterValues Add/Remove/Sync/Modify' {
        Mock -CommandName Sync-RubrikOptionsFile -ModuleName 'Rubrik' -MockWith {
            return $global:rubrikOptions
        }
        Mock -CommandName Get-HomePath -Verifiable -MockWith {
            'TestDrive:\'
        }

        It -Name "PrimaryClusterId should remain 11111" -Test {
            Update-RubrikModuleOption -Sync
            $global:rubrikOptions.DefaultParameterValue.PrimaryClusterId |
                Should -BeExactly '11111'
        }
        It -Name "PrimaryClusterId should be 22222" -Test {
            Update-RubrikModuleOption -OptionName 'PrimaryClusterId' -OptionValue '22222' -OptionType "DefaultParameterValue" -Action "AddUpdate"
            $global:rubrikOptions.DefaultParameterValue.PrimaryClusterId |
                Should -BeExactly '22222'
        }
        It -Name "Should add NewParameter" -Test {
            Update-RubrikModuleOption -OptionName 'NewParameter' -OptionValue 'NewValue' -OptionType "DefaultParameterValue" -Action "AddUpdate"
            $global:rubrikOptions.DefaultParameterValue.NewParameter |
                Should -BeExactly 'NewValue'
        }
        It -Name "Another Parameter should be null" -Test {
            Update-RubrikModuleOption -OptionName 'AnotherParameter' -OptionType "DefaultParameterValue" -Action "RemoveSingle"
            $global:rubrikOptions.DefaultParameterValue.AnotherParameter |
                Should -BeExactly $null
        }
    }
}