Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Move-RubrikMountVMDK' -Tag 'Public', 'Move-RubrikMountVMDK' -Fixture {
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

    Context -Name 'Parameter/Date' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {} 
        Mock -CommandName Test-VMwareConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}

        It -Name 'Should detect invalid date' -Test {
            { Move-RubrikMountVMDK -SourceVM 'SourceVM' -TargetVM 'TargetVM' -Date 'foo' } |
                Should -Throw "Invalid Date"
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Test-VMwareConnection -ModuleName 'Rubrik' -Times 1
    }
 
    Context -Name 'Parameter Validation' {
        It -Name 'Parameters SourceVM and Cleanup cannot be simultaneously used' -Test {
            { Move-RubrikMountVMDK -SourceVM 'SourceVM' -Cleanup 'C:\Users\Person1\Documents\SourceVM_to_TargetVM-1234567890.txt'} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
        It -Name 'Parameters TargetVM and Cleanup cannot be simultaneously used' -Test {
            { Move-RubrikMountVMDK -TargetVM 'TargetVM' -Cleanup 'C:\Users\Person1\Documents\SourceVM_to_TargetVM-1234567890.txt'} |
                Should -Throw "Parameter set cannot be resolved using the specified named parameters."
        }
    }
}