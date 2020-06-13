Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

Describe -Name 'Public/Get-RubrikDownloadLink' -Tag 'Public', 'Get-RubrikDownloadLink' -Fixture {
    Context -Name 'Convert different date time objects' -Fixture {
        Mock -CommandName Get-RubrikSnapshot -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{
                primaryclusterid = 11111
            }
        }
        Mock -CommandName Get-RubrikFileSet -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{
                primaryclusterid = 11111
            }
        }
        Mock -CommandName Invoke-RubrikWebRequest -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Get-RubrikEvent -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{
                Links = 'Thisshouldbefiltered***File_ValidateLink_Thisshouldbefiltered***'
            }
        }
        It -Name "PrimaryClusterId should remain 11111" -Test {
            Get-RubrikDownloadLink -SLAObject ([pscustomobject]@{sourceObjectType='test'}) -sourceDirs '\test' |
                Should -Be 'yes'
        }
    }
}