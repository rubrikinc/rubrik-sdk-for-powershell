Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

Describe -Name 'Public/Start-RubrikDownload' -Tag 'Public', 'Start-RubrikDownload' -Fixture {
    Context -Name 'Context validate correct processing of function with different parameter sets' -Fixture {
        Mock -CommandName Invoke-WebRequest -ModuleName 'Rubrik' -MockWith {
            if ($Outfile -match '\.') {
                mkdir -Path (Split-Path $Outfile) -Force | Out-Null
            } else {
                mkdir -Path $OutFile | Out-Null
            }
            New-Item $OutFile -ItemType File | Out-Null
        }
        Mock -CommandName Get-RubrikEvent -ModuleName 'Rubrik' -MockWith {
            [pscustomobject]@{
                EventInfo = 'Download link for testtest "download_dir/ASDFASDF" testtest'
                Links = 'Thisshouldbefiltered***File_ValidateLink_Thisshouldbefiltered***'
                Date = (Get-Date).AddHours(-1)
            }
        }

        It -Name "Should return a file object" -Test {
            Start-RubrikDownload -Uri https://cluster-b.rubrik.us/download_dir/EVep2PMDpJEAWhIQS6Si.zip -Path "TestDrive:/Temp/MyImportedFileSet.zip" |
                Should -BeOfType [System.IO.FileInfo]
        }

        It -Name "Should filename should match when explicitly specified" -Test {
            (Start-RubrikDownload -Uri https://cluster-b.rubrik.us/download_dir/EVep2PMDpJEAWhIQS6Si.zip -Path "TestDrive:/Temp/MyImportedFileSet2.zip").Name |
                Should -Be 'MyImportedFileSet2.zip'
        }

        It -Name "Should use filename from Rubrik Cluster when only path is specified" -Test {
            (Start-RubrikDownload -Uri https://cluster-b.rubrik.us/download_dir/EVep2PMDpJEAWhIQS6Si.zip -Path "TestDrive:/Temp/").Name |
                Should -Be 'EVep2PMDpJEAWhIQS6Si.zip'
        }

        It -Name "Path should match" -Test {
            (Start-RubrikDownload -Uri https://cluster-b.rubrik.us/download_dir/EVep2PMDpJEAWhIQS6Si.zip -Path "TestDrive:/Temp/ComplicatedPath/MyImportedFileSet2.zip").DirectoryName |
                Should -BeLike '*Temp*ComplicatedPath*'
        }

        Assert-VerifiableMock
    }
}