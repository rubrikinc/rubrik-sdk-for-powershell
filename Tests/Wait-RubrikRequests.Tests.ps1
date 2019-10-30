Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Wait-RubrikRequest' -Tag 'Public', 'Wait-RubrikRequest' -Fixture {
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
    Context -Name "When Type is mssql" {
        
        It -Name 'When Status is SUCCEEDED or FAILED' -Test {
            Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
            Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
                $response = '
                {
                    "id": "MSSQL_DB_MOUNT_1a234567-1a23-1a2b-1234-123a4b5cd67e_1a234b5c-1a23-12ab-1a23-12ab345c6789:::0",
                    "status": "SUCCEEDED",
                    "progress": 0.0,
                    "startTime": "2019-10-28T20:47:25.327Z",
                    "endTime": "2019-10-28T20:47:25.327Z",
                    "nodeId": "cluster:::RVM123A456789",
                    "error": {
                        "message": "string"
                    },
                    "links": [
                        {
                            "href": "https://rubrikcluster.com/api/v1/mssql/request/MSSQL_DB_MOUNT_1a234567-1a23-1a2b-1234-123a4b5cd67e_1a234b5c-1a23-12ab-1a23-12ab345c6789:::0",
                            "rel": "self"
                        }
                    ]
                }'
                return ConvertFrom-Json $response
            }
            Wait-RubrikRequest -RubrikRequestID "MSSQL_DB_MOUNT_1a234567-1a23-1a2b-1234-123a4b5cd67e_1a234b5c-1a23-12ab-1a23-12ab345c6789:::0" -Type "mssql"
        }
    }
}