Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Private/Submit-Request' -Tag 'Private', 'Submit-Request' -Fixture {
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

    $EventObject = [pscustomobject]@{
        id            = '2019-07-02:21:4:::1562103677178-d71cf9d8-c460-4411-8e34-c24a5d197824'
        objectId      = 'MssqlDatabase:::427e4ac6-7add-4240-9cde-e102b82a04b1'
        objectType    = 'Mssql'
        objectName    = 'ReportServer'
        eventInfo     = '{"message":"Replicated Microsoft SQL Server Database ''ReportServer'' from ''Cluster_A'' to ''Cluster_B''","id":"Replication.ReplicationSucceeded","params":{"${snappableType}":"Microsoft SQL Server Database","${snappableName}":"ReportServer","${sourceClusterName}":"Cluster_A","${targetClusterName}":"Cluster_B"}}'
        time          = 'Tue Jul 02 21:41:17 UTC 2019'
        eventType     = 'Replication'
        eventStatus   = 'Success'
        eventSeriesId = 'ec203598-ea31-4929-ad76-c98744c3d489'
        relatedIds    = 'MssqlDatabase:::427e4ac6-7add-4240-9cde-e102b82a04b1'
        jobInstanceId = 'PULL_REPLICATE_f6fe4db5-7f1a-4d51-a16c-0eef911dc033:::346'
    }, [pscustomobject]@{
        id            = '2019-07-02:21:4:::1562103732903-ca725080-210a-4577-b703-74c6ec6b9588'
        objectId      = 'CloudNativeSource:::02ff9580-adf2-464e-aeef-b77321b402fc'
        objectType    = 'AwsAccount'
        objectName    = 'AWS Matt'
        eventInfo     = '{"message":"Finished refreshing cloud native source AWS Matt (AWS).","id":"CloudNative.RefreshCloudNativeSourceSucceeded","params":{"${sourceName}":"AWS Matt","${sourceType}":"AWS"}}'
        time          = 'Tue Jul 02 21:42:12 UTC 2019'
        eventType     = 'CloudNativeSource'
        eventStatus   = 'Success'
        eventSeriesId = '6b09fa1a-0f21-41e2-bdb3-71bfac1b931b'
        relatedIds    = ''
        jobInstanceId = 'REFRESH_CLOUD_NATIVE_SOURCE_02ff9580-adf2-464e-aeef-b77321b402fc:::5268'
    }
    
    $EventJson = [pscustomobject]@{
        content = '{"hasMore":true,"data":[{"id":"2019-07-02:21:4:::1562103677178-d71cf9d8-c460-4411-8e34-c24a5d197824","objectId":"MssqlDatabase:::427e4ac6-7add-4240-9cde-e102b82a04b1","objectType":"Mssql","objectName":"ReportServer","eventInfo":"{\"message\":\"Replicated Microsoft SQL Server Database ''ReportServer'' from ''Cluster_A'' to ''Cluster_B''\",\"id\":\"Replication.ReplicationSucceeded\",\"params\":{\"${snappableType}\":\"Microsoft SQL Server Database\",\"${snappableName}\":\"ReportServer\",\"${sourceClusterName}\":\"Cluster_A\",\"${targetClusterName}\":\"Cluster_B\"}}","time":"Tue Jul 02 21:41:17 UTC 2019","eventType":"Replication","eventStatus":"Success","eventSeriesId":"ec203598-ea31-4929-ad76-c98744c3d489","relatedIds":"MssqlDatabase:::427e4ac6-7add-4240-9cde-e102b82a04b1","jobInstanceId":"PULL_REPLICATE_f6fe4db5-7f1a-4d51-a16c-0eef911dc033:::346"},{"id":"2019-07-02:21:4:::1562103732903-ca725080-210a-4577-b703-74c6ec6b9588","objectId":"CloudNativeSource:::02ff9580-adf2-464e-aeef-b77321b402fc","objectType":"AwsAccount","objectName":"AWS Matt","eventInfo":"{\"message\":\"Finished refreshing cloud native source AWS Matt (AWS).\",\"id\":\"CloudNative.RefreshCloudNativeSourceSucceeded\",\"params\":{\"${sourceName}\":\"AWS Matt\",\"${sourceType}\":\"AWS\"}}","time":"Tue Jul 02 21:42:12 UTC 2019","eventType":"CloudNativeSource","eventStatus":"Success","eventSeriesId":"6b09fa1a-0f21-41e2-bdb3-71bfac1b931b","relatedIds":"","jobInstanceId":"REFRESH_CLOUD_NATIVE_SOURCE_02ff9580-adf2-464e-aeef-b77321b402fc:::5268"}]}'
    }

    $SLAObject = [pscustomobject]@{
        id                            = '156eff81-b7d8-48c3-b3e5-97c2f788e215'
        primaryClusterId              = '8b4fe6f6-cc87-4354-a125-b65e23cf8c90'
        name                          = 'TestSLA_1 (Managed by Polaris)'
        polarisManagedId              = '4896a9de-b7e4-4a0b-ac20-d93d91bfb260'
        frequencies                   = '@{daily=}'
        allowedBackupWindows          = $null
        firstFullAllowedBackupWindows = $null
        maxLocalRetentionLimit        = '604800'
        archivalSpecs                 = $null
        replicationSpecs              = $null
        numDbs                        = '0'
        numOracleDbs                  = '0'
        numFilesets                   = '0'
        numHypervVms                  = '0'
        numNutanixVms                 = '0'
        numManagedVolumes             = '0'
        numStorageArrayVolumeGroups   = '0'
        numWindowsVolumeGroups        = '0'
        numLinuxHosts                 = '0'
        numShares                     = '0'
        numWindowsHosts               = '0'
        numVms                        = '0'
        numEc2Instances               = '0'
        numVcdVapps                   = '0'
        numProtectedObjects           = '0'
        isDefault                     = 'False'
        uiColor                       = '#7f3340'
        showAdvancedUi                = $true
        advancedUiConfig              = '@{timeUnit=Daily; retentionType=Daily}'
    }

    $SLAJson = [pscustomobject]@{
        content = '{"hasMore":false,"data":[{"id":"156eff81-b7d8-48c3-b3e5-97c2f788e215","primaryClusterId":"8b4fe6f6-cc87-4354-a125-b65e23cf8c90","name":"TestSLA_1 (Managed by Polaris)","polarisManagedId":"4896a9de-b7e4-4a0b-ac20-d93d91bfb260","frequencies":{"daily":{"frequency":1,"retention":7}},"allowedBackupWindows":[],"firstFullAllowedBackupWindows":[],"maxLocalRetentionLimit":604800,"archivalSpecs":[],"replicationSpecs":[],"numDbs":0,"numOracleDbs":0,"numFilesets":0,"numHypervVms":0,"numNutanixVms":0,"numManagedVolumes":0,"numStorageArrayVolumeGroups":0,"numWindowsVolumeGroups":0,"numLinuxHosts":0,"numShares":0,"numWindowsHosts":0,"numVms":0,"numEc2Instances":0,"numVcdVapps":0,"numProtectedObjects":0,"isDefault":false,"uiColor":"#7f3340","showAdvancedUi":true,"advancedUiConfig":[{"timeUnit":"Daily","retentionType":"Daily"}]}],"total":1}'
    }

    Context -Name 'Method:Delete-Success/Error' {
        Mock -CommandName 'Invoke-RubrikWebRequest' -Verifiable -MockWith {
           [pscustomobject]@{
                StatusCode = 204
           }
        }

        It 'Status:Success' {
           $resources = @{
                Method = 'Delete'
                Success = 204
           }
           (Submit-Request -Uri 1 -Method Delete).Status | Should -BeExactly 'Success'
        }

        Mock -CommandName 'Invoke-RubrikWebRequest' -Verifiable -MockWith {
            [pscustomobject]@{
                 StatusCode = 1337
            }
         }
        
        It 'Status:Error' {
            $resources = @{
                Method = 'Delete'
                Success = 204
            }
            
            (Submit-Request -Uri 1 -Method Delete).Status | Should -BeExactly 'Error'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Invoke-RubrikWebRequest -Times 2
    }
    
    Context -Name 'Test empty result filtering' {
        Mock -CommandName 'Invoke-RubrikWebRequest' -Verifiable -MockWith {
            [pscustomobject]@{
                StatusCode = 204
            }
        }
        
        $resources = @{
            Method = 'Delete'
            Success = 204
        }
        
        It 'Method:Delete - Empty Object should not be empty' {
            (Submit-Request -Uri 1 -Method Delete) | Should -Not -BeNullOrEmpty
        }
        
        $resources.Method = 'Post'        
        It 'Method:Post - Empty Object should not be empty' {
            (Submit-Request -Uri 1 -Method Post) | Should -Not -BeNullOrEmpty
        }
        
        $resources.Method = 'Patch'        
        It 'Method:Patch - Empty Object should not be empty' {
            (Submit-Request -Uri 1 -Method Patch) | Should -Not -BeNullOrEmpty
        }
        
        $resources.Method = 'Put'
        It 'Method:Put - Empty Object should not be empty' {
            (Submit-Request -Uri 1 -Method Put) | Should -Not -BeNullOrEmpty
        }
    }

    Context -Name 'Method:Other-EventObject' {
        Mock -CommandName 'Invoke-RubrikWebRequest' -Verifiable -MockWith {
            $EventJson
        }

        $EventCases = $EventObject[0].psobject.properties.name | ForEach-Object {
            @{
                'Property'=$_
            }
        }

        It 'Parse as PowerShell - Event Objects - Verify <Property> Property' -TestCases $EventCases {
            param($Property)
            (Submit-Request -Uri 1 -Method Post).Data.$Property | Should -BeExactly $EventObject.$Property
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Invoke-RubrikWebRequest -Times 11
    }

    Context  -Name 'Method:Other-SLAObject' {
        Mock -CommandName 'Invoke-RubrikWebRequest' -Verifiable -MockWith {
            $SLAJson
        }

        $SLACases = $SLAObject.psobject.properties.name | ForEach-Object {
            @{
                'Property'=$_
            }
        }
        It 'Parse as PowerShell - SLA Object - Verify <Property> Property' -TestCases $SLACases {
            param($Property)
            (Submit-Request -Uri 1 -Method Post).Data.$Property | Should -BeExactly $SLAObject.$Property
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Invoke-RubrikWebRequest -Times 29
    }

    Context -Name 'Error:Route not defined' {
        Mock -CommandName 'Invoke-RubrikWebRequest' -Verifiable -MockWith {
            throw 'Route not defined.'
        }

        It 'Should throw - Route not defined.' {
            {Submit-Request -Uri 1 -Method Post 3>$null} | Should -Throw
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Invoke-RubrikWebRequest -Times 1
    }
}