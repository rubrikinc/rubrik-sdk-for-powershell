Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

Describe -Name 'Public/Get-RubrikDownloadLink' -Tag 'Public', 'Get-RubrikDownloadLink' -Fixture {
    Context -Name 'Convert different date time objects' -Fixture {
        Mock -CommandName Submit-Request -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Get-RubrikEvent -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{
                EventInfo = 'Download link for testtest "download_dir/ASDFASDF" testtest'
                Links = 'Thisshouldbefiltered***File_ValidateLink_Thisshouldbefiltered***'
                Date = (Get-Date).AddHours(-1)
            }
        }
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {
            $Global:Header = @{
                Authorization = 'Bearer test-authorization'
            }
        }

        It -Name "Should return the correctly formatted download link based on input" -Test {
            Get-RubrikDownloadLink -SLAObject ([pscustomobject]@{sourceObjectType='test'}) -sourceDirs '\test' |
                Should -Be 'https://test-server/download_dir/ASDFASDF'
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 1
        Assert-MockCalled -CommandName Get-RubrikEvent -ModuleName 'Rubrik' -Exactly 1
    }
}