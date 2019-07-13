Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikManagedVolume' -Tag 'Public', 'New-RubrikManagedVolume' -Fixture {
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

    Context -Name 'Object Creation' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id'            = 'ManagedVolume:::11111'
                'numChannels'   = '1'
                'name'          = 'ManagedVolumeName'
                'volumeSize'    = '536870912000'
                'isDeleted'     = 'False'
            }
        }

        It -Name 'Should newly created managed volume' -Test {
            ( New-RubrikManagedVolume -Name 'ManagedVolumeName' -Channels 1 -VolumeSize (500*1GB)).name |
                Should -BeExactly 'ManagedVolumeName'
        }
        It -Name 'Parameter name is required' -Test {
            { New-RubrikManagedVolume -Name -Channels 1 } |
                Should -Throw "Missing an argument for parameter 'Name'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Parameter Channels is required' -Test {
            { New-RubrikManagedVolume -Name 'ManagedVolumeName' -Channels  } |
                Should -Throw "Missing an argument for parameter 'Channels'. Specify a parameter of type 'System.Int32' and try again."
        }
        It -Name 'Parameter ApplicationTag is correct' -Test {
            { New-RubrikManagedVolume -Name 'Test' -Channels 2 -ApplicationTag 'windows' } |
                Should -Throw "Cannot validate argument on parameter 'applicationTag'. The argument `"windows`" does not belong to the set `"Oracle,OracleIncremental,MsSql,SapHana,MySql,PostgreSql,RecoverX`" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again."
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Times 1
    }
}