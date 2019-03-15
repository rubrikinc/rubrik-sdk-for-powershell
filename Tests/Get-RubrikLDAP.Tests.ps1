Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name '../Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path '../Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikLDAP' -Tag 'Public', 'Get-RubrikLDAP' -Fixture {
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

    Context -Name 'Parameter/SLA' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
          [pscustomobject]@{
            hasMore = $False
            data    = [pscustomobject]@{id='11111111-2222-3333-4444-555555555555'; domainType='LOCAL'; name='local'; initialRefreshStatus='success'},
                      [pscustomobject]@{id='11111111-2222-3333-4444-555555555555'; domainType='AD'; name='rubrik.com'; serviceAccount='Cluster_Account';initialRefreshStatus='success'}
            total   = 2
          }
        }
        It -Name 'Should return local' -Test {
            (Get-RubrikLDAP)[0].Name |
                Should -BeExactly 'local'
        }
        It -Name 'Should return rubrik.com' -Test {
            (Get-RubrikLDAP)[1].Name |
                Should -BeExactly 'rubrik.com'
        }
        It -Name 'Output should be PSCustomObject' -Test {
            Get-RubrikLDAP |
                Should -BeOfType 'System.Management.Automation.PSCustomObject'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}