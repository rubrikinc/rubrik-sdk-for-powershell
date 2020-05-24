Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikReportData' -Tag 'Public', 'Get-RubrikReportData' -Fixture {
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
            @{ 
                'columns'               = @('TaskStatus','TaskType','ObjectId','ObjectName')
                'cursor'                = '1111-2222-3333'
                'reportTemplate'        = 'ProtectionTaskDetails'
                'datagrid'              = @('OracleDatabase','Backup','11111','OracleHR')  
            }
        }
        It -Name 'Returns reportTemplate' -Test {
            ( Get-RubrikReportData -id 1111).reportTemplate |
                Should -BeExactly 'ProtectionTaskDetails'
        } 
        It -Name 'Sets hasMore to false' -Test {
            (Get-RubrikReportData -id 1111 -limit -1).hasMore | 
            Should -BeExactly 'false'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 2
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 2
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            { Get-RubrikReportData -id } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Name Missing' -Test {
            { Get-RubrikReportData -id '11111' -name  } |
                Should -Throw "Missing an argument for parameter 'name'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'TaskType Missing' -Test {
            { Get-RubrikReportData -id '11111' -TaskType  } |
                Should -Throw "Missing an argument for parameter 'TaskType'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'TaskStatus Missing' -Test {
            { Get-RubrikReportData -id '11111' -TaskStatus   } |
                Should -Throw "Missing an argument for parameter 'TaskStatus'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'ObjectType Missing' -Test {
            { Get-RubrikReportData -id '11111' -ObjectType  } |
                Should -Throw "Missing an argument for parameter 'ObjectType'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Validate ComplianceStatus' -Test {
            { Get-RubrikReportData -id '11111' -ComplianceStatus 'NotCorrect'  } |
                Should -Throw 'The argument "NotCorrect" does not belong to the set "InCompliance,NonCompliance" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.'
        }
    }

    Context -Name 'DatagridObject Validation' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}    
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{ 
                'columns'               = ('ObjectId','ObjectState','ComplianceStatus','MissedLocalSnapshots') -as [array]
                'cursor'                = '1111-2222-3333'
                'reportTemplate'        = 'ProtectionTaskDetails'
                'datagrid'              = 'ManagedVolume:::1111','Active','NonCompliance','42'
                'hasmore'               = $false
            }
        }

        $ReportDataResult = Get-RubrikReportData -id 1111

        it "Datagridobject 'ObjectId' should be correct" {
            $ReportDataResult.DatagridObject.ObjectId[0] |
                Should -BeExactly 'ManagedVolume:::1111'
        }

    }
}