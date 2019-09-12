Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikManagedVolume' -Tag 'Public', 'Set-RubrikManagedVolume' -Fixture {
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
 
    Context -Name 'Parameter Validation' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'slaid' = '12345678-1234-abcd-8910-1234567890ab' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'id'         = 'ManagedVolume:::11111'
                'name'       = 'MV1'
                'volumeSize' = '473883748'
            }
        }
        It -Name 'Request Fulfilled VolumeSize' -Test {
            (Set-RubrikManagedVolume -id 'ManagedVolume:::11111' -VolumeSize '473883748').volumeSize |
                Should -BeExactly '473883748'
        }
        It -Name 'Request Fulfilled SLA' -Test {
            (Set-RubrikManagedVolume -id 'ManagedVolume:::11111' -SLA 'Gold' -VolumeSize '473883748').name |
                Should -BeExactly 'MV1'
        }
        It -Name 'Parameter ID cannot be $null' -Test {
            { Set-RubrikManagedVolume -Id $null } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
        It -Name 'Parameter ID cannot be empty' -Test {
            { Set-RubrikManagedVolume -Id '' } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
        It -Name 'Volume Size is integer' -Test {
            { Set-RubrikManagedVolume -Id 'ManagedVolume:::11111' -VolumeSize 'seven' } |
                Should -Throw "Cannot process argument transformation on parameter 'VolumeSize'. Cannot convert value `"seven`" to type `"System.Int64`"."
        }
        It -Name 'Name cannot be null or empty' -Test {
            { Set-RubrikManagedVolume -Id 'ManagedVolume:::11111' -Name $null } |
                Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik'  -Times 1
    }
}