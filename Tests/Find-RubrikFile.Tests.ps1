Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Find-RubrikFile' -Tag 'Public', 'Find-RubrikFile' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '5.0'
    }
    #endregion

    Context -Name 'Returned Results' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith { }
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                "path"         = "C:\myfile.csv"
                "filename"     = "myfile.csv"
                "fileVersions" = @(
                    @{
                        "lastModified" = "10/15/2018 10: 12: 01"
                        "size"         = 710
                        "snapshotId"   = "ac974225-fe1c-486d-a661-bdf193531979"
                        "fileMode"     = "file"
                        "source"       = "cloud"
                    },
                    @{
                        "lastModified" = "10/15/2018 10: 12: 01"
                        "size"         = 710
                        "snapshotId"   = "f5442df8-31a9-485d-8cc1-7b5e6cf1a336"
                        "fileMode"     = "file"
                        "source"       = "cloud"
                    }
                )
                "ObjectId"   = "VirtualMachine:::5ed1b046-0bd9-4468-a67c-3293f15f27ed-vm-107"
                "ObjectName" = "MyWindowsVM"  
            }
        }
        It -Name 'Returns results' -Test {
            ( Find-RubrikFile -id "123" -SearchString "myfile" | Measure-Object ).Count |
                Should -BeExactly 1
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'ID Missing' -Test {
            {  Find-RubrikFile -id -searchstring "myfile" } |
                Should -Throw "Missing an argument for parameter 'Id'. Specify a parameter of type 'System.String' and try again."
        }
        It -Name 'SearchString Missing' -Test {
            {  Find-RubrikFile -id "123" -SearchString} |
                Should -Throw "Missing an argument for parameter 'SearchString'. Specify a parameter of type 'System.String' and try again."
        }
    }
}