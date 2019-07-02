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
    
    $EventJson = '{"hasMore":true,"data":[{"id":"2019-07-02:21:4:::1562103677178-d71cf9d8-c460-4411-8e34-c24a5d197824","objectId":"MssqlDatabase:::427e4ac6-7add-4240-9cde-e102b82a04b1","objectType":"Mssql","objectName":"ReportServer","eventInfo":"{\"message\":\"Replicated Microsoft SQL Server Database ''ReportServer'' from ''Cluster_A'' to ''Cluster_B''\",\"id\":\"Replication.ReplicationSucceeded\",\"params\":{\"${snappableType}\":\"Microsoft SQL Server Database\",\"${snappableName}\":\"ReportServer\",\"${sourceClusterName}\":\"Cluster_A\",\"${targetClusterName}\":\"Cluster_B\"}}","time":"Tue Jul 02 21:41:17 UTC 2019","eventType":"Replication","eventStatus":"Success","eventSeriesId":"ec203598-ea31-4929-ad76-c98744c3d489","relatedIds":"MssqlDatabase:::427e4ac6-7add-4240-9cde-e102b82a04b1","jobInstanceId":"PULL_REPLICATE_f6fe4db5-7f1a-4d51-a16c-0eef911dc033:::346"},{"id":"2019-07-02:21:4:::1562103732903-ca725080-210a-4577-b703-74c6ec6b9588","objectId":"CloudNativeSource:::02ff9580-adf2-464e-aeef-b77321b402fc","objectType":"AwsAccount","objectName":"AWS Matt","eventInfo":"{\"message\":\"Finished refreshing cloud native source AWS Matt (AWS).\",\"id\":\"CloudNative.RefreshCloudNativeSourceSucceeded\",\"params\":{\"${sourceName}\":\"AWS Matt\",\"${sourceType}\":\"AWS\"}}","time":"Tue Jul 02 21:42:12 UTC 2019","eventType":"CloudNativeSource","eventStatus":"Success","eventSeriesId":"6b09fa1a-0f21-41e2-bdb3-71bfac1b931b","relatedIds":"","jobInstanceId":"REFRESH_CLOUD_NATIVE_SOURCE_02ff9580-adf2-464e-aeef-b77321b402fc:::5268"}]}'

    Context -Name 'Method:Delete' {
        It 'Parse as PowerShell' {
            Mock -CommandName Test-PowerShellSix -Verifiable  -MockWith {$true}
        }
        It 'Status:success' {
            Mock -CommandName Test-PowerShellSix -Verifiable -MockWith {$true}
        }
        It 'Status:error' {
            Mock -CommandName Test-PowerShellSix -Verifiable -MockWith {$true}
        }
    }

    Context -Name 'Method:Other' {
        Mock -CommandName Test-PowerShellSix -Verifiable -MockWith {
            $true
        }
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

        Assert-MockCalled -CommandName Test-PowerShellSix -Times 1
        Assert-MockCalled -CommandName Invoke-RubrikWebRequest -Times 1
    }

    Context -Name 'Error' {
    
    }
}