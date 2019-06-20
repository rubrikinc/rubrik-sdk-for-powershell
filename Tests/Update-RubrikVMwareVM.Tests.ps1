Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Update-RubrikVMwareVM' -Tag 'Public', 'Update-RubrikVMwareVM' -Fixture {
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

    Context -Name 'Request Fails' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            throw
        }

        It -Name 'Invalid vCenter id' -Test {
            {Update-RubrikVMwareVM -Id vCenter:::doesnotexist -moid vm-1337} | Should -Throw
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Request Succeeds' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        function Get-TestVM {}
        Mock -CommandName Get-TestVM -MockWith {
            [pscustomobject]@{
                vcenterId = 'vCenter:::1226ff04-6100-454f-905b-5df817b6981a'
                vmMoid = 'vm-100'
            }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            $null
        }

        Get-RubrikVM 
        It -Name 'Get-VM' -Test {
            Get-TestVM -Name 'Jaap' | Should -Be '@{vcenterId=vCenter:::1226ff04-6100-454f-905b-5df817b6981a; vmMoid=vm-100}'
        }

        It -Name 'Valid execution' -Test {
            Get-TestVM -Name 'Jaap' | ForEach-Object {
                Update-RubrikVMwareVM -vcenterId $_.vcenterId -vmMoid $_.vmMoid
            } | Should -Be $null
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Get-TestVM -Times 2
    }
}