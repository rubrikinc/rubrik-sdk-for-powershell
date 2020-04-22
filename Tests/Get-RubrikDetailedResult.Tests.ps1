Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Private/Get-RubrikDetailedResult' -Tag 'Private', 'Get-RubrikDetailedResult' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '4.0'
    }


    Context -Name "Test Returned Data" -Fixture {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'name'                   = 'test-vm1'
                'id'                     = 'vm1'
                'effectiveSlaDomainName' = 'test-valid_sla_name'
            }
        }
        it -Name "Returns proper data" -Test {
            $results = @{
                'name'  = 'test-vm1'
                'id'    = 'vm1'
            }
            $arrResults = @()
            $arrResults += $results
            (Get-RubrikDetailedResult -result $arrResults -cmdlet 'Get-RubrikVM').id |
                Should -Be 'vm1'
        }
    }
}