Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikReport' -Tag 'Public', 'Set-RubrikReport' -Fixture {
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

    Context -Name 'Returned Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
           [pscustomobject]@{ 
                'id'                     = 'CustomReport:::1:1:1:1'
                'name'                   = 'TestReport1'
                'filters'                = 'Ready'
                'chart0'                 = 'Custom'
                'chart1'                 = 'CustomReport:::11111'
                'table'                  = [pscustomobject]@{columns = 1,2,3}
            }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -ParameterFilter {$Method -eq 'Patch'} -MockWith {
            [pscustomobject]@{ 
                'id'                     = 'CustomReport:::1:1:1:1'
                'name'                   = 'Quokka'
                'filters'                = 'Ready'
                'chart0'                 = 'Custom'
                'chart1'                 = 'CustomReport:::11111'
                'table'                  = [pscustomobject]@{columns = 'ReplicationTarget', 'ArchivalTarget', 'TaskStatus'}
            }
        }

        It -Name 'Should display warning if no new values are presented' -Test {
            $Output = Get-RubrikReport | Set-RubrikReport *>&1
            (-join $Output) | Should -BeLike "*No new values submitted, no changes made to report:*"
        }

        It -Name 'Should return name field with correct name' -Test {
            (Get-RubrikReport | Set-RubrikReport -NewName Quokka).Name |
                Should -Be "Quokka"
        }
   
        It -Name 'Should return correct array of table columns' -Test {
            (Get-RubrikReport | Set-RubrikReport -NewTableColumns 'ReplicationTarget', 'ArchivalTarget', 'TaskStatus').Table.Columns |
                Should -Be @('ReplicationTarget', 'ArchivalTarget', 'TaskStatus')
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikReport -id | Set-RubrikReport} |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }       
        It -Name 'Type validation validateset should work for NewTableColumns' -Test {
            { Set-RubrikReport -NewTableColumns 'NewReport' } |
                Should -Throw 'Cannot validate argument on parameter ''NewTableColumns''. The argument "NewReport" does not belong to the set "Hour,Day,Month,Quarter,Year,SlaDomain,ReplicationTarget,ArchivalTarget,TaskStatus,TaskType,Location,ObjectName,ObjectType,ObjectIndexType,ClusterLocation,ComplianceStatus,Organization,RecoveryPoint,RecoveryPointType,Username,FailureReason,SnapshotConsistency,QueuedTime,StartTime,EndTime,Duration,DataTransferred,LogicalDataProtected,DataStored,NumFilesTransferred,EffectiveThroughput,DedupRatio,LogicalDedupRatio,DataReductionPercent,LogicalDataReductionPercent,TaskCount,SuccessfulTaskCount,CanceledTaskCount,FailedTaskCount,AverageDuration,ObjectCount,TotalLocalStorage,TotalReplicaStorage,TotalArchiveStorage,LocalStorageGrowth,ArchiveStorageGrowth,ReplicaStorageGrowth,ProtectedOn,InComplianceCount,NonComplianceCount,ArchivalInComplianceCount,ArchivalNonComplianceCount,TotalSnapshots,MissedLocalSnapshots,MissedArchivalSnapshots,LocalSnapshots,ReplicaSnapshots,ArchiveSnapshots,LatestLocalSnapshot,LocalCdpStatus,PercentLocal24HourCdpHealthy,LocalCdpLogStorage,LocalCdpThroughput,LatestLocalSnapshotIndexState,LocalIndexedSnapshotsCount,LocalUnindexedSnapshotsCount,LocalPendingForIndexSnapshotsCount,LatestLocalIndexedSnapshotTime,CdpReplicationStatus" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.'
        }
        It -Name 'Type validation validateset should be case-sensitive NewTableColumns' -Test {
            { Set-RubrikReport -NewTableColumns 'hour' } |
                Should -Throw 'Cannot validate argument on parameter ''NewTableColumns''. The argument "hour" does not belong to the set "Hour,Day,Month,Quarter,Year,SlaDomain,ReplicationTarget,ArchivalTarget,TaskStatus,TaskType,Location,ObjectName,ObjectType,ObjectIndexType,ClusterLocation,ComplianceStatus,Organization,RecoveryPoint,RecoveryPointType,Username,FailureReason,SnapshotConsistency,QueuedTime,StartTime,EndTime,Duration,DataTransferred,LogicalDataProtected,DataStored,NumFilesTransferred,EffectiveThroughput,DedupRatio,LogicalDedupRatio,DataReductionPercent,LogicalDataReductionPercent,TaskCount,SuccessfulTaskCount,CanceledTaskCount,FailedTaskCount,AverageDuration,ObjectCount,TotalLocalStorage,TotalReplicaStorage,TotalArchiveStorage,LocalStorageGrowth,ArchiveStorageGrowth,ReplicaStorageGrowth,ProtectedOn,InComplianceCount,NonComplianceCount,ArchivalInComplianceCount,ArchivalNonComplianceCount,TotalSnapshots,MissedLocalSnapshots,MissedArchivalSnapshots,LocalSnapshots,ReplicaSnapshots,ArchiveSnapshots,LatestLocalSnapshot,LocalCdpStatus,PercentLocal24HourCdpHealthy,LocalCdpLogStorage,LocalCdpThroughput,LatestLocalSnapshotIndexState,LocalIndexedSnapshotsCount,LocalUnindexedSnapshotsCount,LocalPendingForIndexSnapshotsCount,LatestLocalIndexedSnapshotTime,CdpReplicationStatus" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.'
        }
    }
}