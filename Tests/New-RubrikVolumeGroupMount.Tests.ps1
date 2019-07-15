Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/New-RubrikVolumeGroupMount' -Tag 'Public', 'New-RubrikVolumeGroupMount' -Fixture {
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

    Context -Name 'Parameter Validation' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id'       = 'MOUNT_VOLUME_GROUP_SNAPSHOT_11111'
                'status'   = 'QUEUED'
                'progress' = '0'
            }
        }

        It -Name 'Should newly created Volume Group Mount task with QUEUED status' -Test {
            ( New-RubrikVolumeGroupMount -TargetHost 'host01' -VolumeGroupSnapshot 'snapshot').status |
                Should -BeExactly 'QUEUED'
        }
        
        It -Name 'Parameter TargetHost is missing' -Test {
            { New-RubrikVolumeGroupMount -TargetHost -VolumeGroupSnapshot 'snap'  } |
                Should -Throw "Missing an argument for parameter 'TargetHost'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Parameter VolumeGroupSnapshot is missing' -Test {
            { New-RubrikVolumeGroupMount -TargetHost 'host01' -VolumeGroupSnapshot   } |
                Should -Throw "Missing an argument for parameter 'VolumeGroupSnapshot'. Specify a parameter of type 'System.Object' and try again."
        }
        It -Name 'Parameter TargetHost is empty' -Test {
            { New-RubrikVolumeGroupMount -TargetHost '' -VolumeGroupSnapshot 'snap'  } |
                Should -Throw "Cannot bind argument to parameter 'TargetHost' because it is an empty string."
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Times 1
    }
}