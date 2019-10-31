Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikVolumeGroup' -Tag 'Public', 'Get-RubrikVolumeGroup' -Fixture {
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

    Context -Name 'Results Filtering' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Test-RubrikSLA -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 'slaid' = 'SLA1' }
        }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{
                'name'                   = 'VG01'
                'id'                     = 'VolumeGroup:::11111'
                'hostname'               = 'VG01.domain.local'
                'effectiveSlaDomainName' = 'Gold'
                'effectiveSlaDomainId'   = 'SLA1'
                'hostId'                 = 'host01'
            },
            @{ 
                'name'                   = 'VG02'
                'id'                     = 'VolumeGroup:::22222'
                'hostname'               = 'VG02.domain.local'
                'effectiveSlaDomainName' = 'Gold'
                'effectiveSlaDomainId'   = 'SLA1'
                'hostId'                 = 'host02'
            },
            @{
                'name'                   = 'VG03'
                'id'                     = 'VolumeGroup:::33333'
                'hostname'               = 'VG03.domain.local'
                'effectiveSlaDomainName' = 'Silver'
                'effectiveSlaDomainId'   = 'SLA2'
                'hostId'                 = 'host03'
            },
            @{
                'name'                   = 'VG04'
                'id'                     = 'VolumeGroup:::44444'
                'hostname'               = 'VG04.domain.local'
                'effectiveSlaDomainName' = 'Gold'
                'effectiveSlaDomainId'   = 'SLA1'
                'hostId'                 = 'host04'
            }
        }
        It -Name 'Requesting all should return count of 4' -Test {
            ( Get-RubrikVolumeGroup).Count |
                Should -BeExactly 4
        }
        It -Name 'Requesting name of VG04 should return id of VolumeGroup:::44444' -Test {
            (Get-RubrikVolumeGroup -name 'VG04').id |
                Should -BeExactly 'VolumeGroup:::44444'
        }
        It -Name 'Requesting SLA Gold returns count of 3' -Test {
            ( Get-RubrikVolumeGroup -SLA 'Gold').Count |
                Should -BeExactly 3
        }
        It -Name 'Missing ID Exception' -Test {
            { Get-RubrikVolumeGroup -id  } |
                Should -Throw "Missing an argument for parameter 'id'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'Missing Name Exception' -Test {
            { Get-RubrikVolumeGroup -name  } |
                Should -Throw "Missing an argument for parameter 'name'. Specify a parameter of type 'System.String' and try again."
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 3
        Assert-MockCalled -CommandName Test-RubrikSLA -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 3
    }
    Context -Name 'DetailedObject querying' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'name'                   = 'VG01'
                'id'                     = 'VolumeGroup:::11111'
                'hostname'               = 'VG01.domain.local'
                'effectiveSlaDomainName' = 'Gold'
                'effectiveSlaDomainId'   = 'SLA1'
                'hostId'                 = 'host01'
                'volumes'                = @{
                    'mountPoints' = '/etc'
                }
            }
        }

        It -Name 'Requesting all should return count of 1' -Test {
            @( Get-RubrikVolumeGroup).Count |
                Should -BeExactly 1
        }

        It -Name 'Requesting volumes property should be /etc when queried by id' -Test {
            ( Get-RubrikVolumeGroup -id VolumeGroup:::11111).includes |
                Should -BeExactly '/etc'
        }

        It -Name 'Requesting volumes property should be /etc when using -DetailedObject' -Test {
            ( Get-RubrikVolumeGroup -Name VG01 -DetailedObject).includes |
                Should -BeExactly '/etc'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 4
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 4
    }    
}