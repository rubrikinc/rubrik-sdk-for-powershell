Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Update-RubrikHost' -Tag 'Public', 'Update-RubrikHost' -Fixture {
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

    Context -Name 'Request Succeeds' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'name'                   = 'host01'
                'id'                     = 'Host:::11111'
                'operatingSystemType'    = 'Windows'
                'status'                 = 'Connected'
                'compressionEnabled'     = 'False'
                'primaryClusterId'       = 'clusterid'
                'hostname'               = 'host01'
            }
        }
        It -Name 'Should return proper hostname' -Test {
            ( Update-RubrikHost -id 'host01').hostname |
                Should -BeExactly 'host01'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }

    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be null' -Test {
           { Update-RubrikHost -id $null } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        } 
        It -Name 'Parameter ID cannot be empty' -Test {
            { Update-RubrikHost -id '' } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        }
    }
}