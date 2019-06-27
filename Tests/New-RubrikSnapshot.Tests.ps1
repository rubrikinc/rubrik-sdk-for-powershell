Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikSnapshot' -Tag 'Public', 'New-RubrikSnapshot' -Fixture {
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
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'slaid' = '11111'
            }
        }
        Mock -CommandName Test-QueryParam -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'uri' = ('https://server/v1/vm/VirtualMachine:::123123123/snapshot')
            }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id'        = 'CREATE_ORACLE_SNAPSHOT_11111'
                'status'    = 'QUEUED'
                'progress'  = '0'
            }
        }
        It -Name 'Should Return status of QUEUED' -Test {
            ( New-RubrikSnapshot -id 1 -SLA 'Gold' -Confirm:$false).status |
                Should -BeExactly 'QUEUED'
        }

        Context -Name 'Parameter Validation' {
            It -Name 'Parameter id cannot be $null or empty' -Test {
                { New-RubrikSnapshot -id $null } |
                    Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
            }
            $results = New-RubrikSnapshot -id 'VirtualMachine:::11111' -SLA 'Gold' -ForceFull -Confirm:$false -WarningVariable warning
            It -Name 'Should issue warning' {
                $warning | Should -BeLike "*Oracle and MSSQL databases*"
            }

        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Test-RubrikSLA -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Test-QueryParam -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Times 1
    }
}