Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Remove-RubrikVolumeGroupSnapshot' -Tag 'Public', 'Remove-RubrikVolumeGroupSnapshot' -Fixture {
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

    Context -Name 'Parameters' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                Status = 'Success'
                HTTPStatusCode = 204
            }
        }
        It -Name 'Should Return status of Success' -Test {
            ( Remove-RubrikVolumeGroupSnapshot -id '01234567-8910-1abc-d435-0abc1234d567' -Confirm:$false).Status |
                Should -BeExactly 'Success'
        }

        It -Name 'Should Return HTTP status code 204' -Test {
            ( Remove-RubrikVolumeGroupSnapshot -id '01234567-8910-1abc-d435-0abc1234d567' -Confirm:$false).HTTPStatusCode |
                Should -BeExactly 204
        }

        Context -Name 'Parameter Validation' {
            It -Name 'Parameter id cannot be $null or empty' -Test {
                { Remove-RubrikVolumeGroupSnapshot -id $null -Confirm:$false} |
                    Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
            }
            It -Name 'Location parameter set validation should fail' -Test {
                { Remove-RubrikVolumeGroupSnapshot -id '01234567-8910-1abc-d435-0abc1234d567' -location 'nonexistant' } |
                    Should -Throw "Cannot validate argument"
            }
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}