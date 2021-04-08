Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Test-RubrikSnapshotVerification' -Tag 'Public', 'Test-RubrikSnapshotVerification' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '5.3'
    }
    #endregion
 
    Context -Name 'Parameter Validation' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id' = 'BACKUP_INTEGRITY_VERIFICATION_eedf871d-65d6-4595-8e25-50ff79a2cefc_d0376dc4-af94-494a-b4ea-5140812f5eb5:::0'
                'status' = 'RUNNING'
                'progress' = '0'
                'startTime' = '4/8/2021 5:13:17 PM'
                'nodeId' = 'cluster:::22222'
                'links' = 'http:; rel=self}}'
                'snapshotVerificationInfo' = '@{snapshotId=b33a8'
            }
        }
        It -Name 'Request Initiated' -Test {
            (Test-RubrikSnapshotVerification -id 'VirtualMachine:::11111' ).snapshotVerificationInfo |
                Should -BeExactly '@{snapshotId=b33a8'
        }

        It -Name 'Parameter ID must be present' -Test {
            { Start-RubrikManagedVolumeSnapshot -Id  } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Exactly 1
    }
}