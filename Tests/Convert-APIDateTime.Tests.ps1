Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Private/Convert-APIDateTime' -Tag 'Private', 'Convert-APIDateTime' -Fixture {
    Context -Name 'Convert different date time objects' -Fixture {
      
        $cases = 'Mon Jan 10 17:12:14 UTC 2019',
        'Mon Mar 11 09:12:14 UTC 2017',
        'Mon Sep 12 23:12:14 UTC 2018',
        'Mon Dec 13 14:12:14 UTC 2006' | ForEach-Object {
            @{'DateTimeString' = $_}
            
        }

        It -Name "Get-RubrikAPIData - <DateTimeString> test" -TestCases $cases {
            param($DateTimeString)
            Convert-APIDateTime -DateTimeString $DateTimeString.ToString() |
                Should -BeOfType DateTime
        }
    }
    
    Context -Name 'Error handling' -Fixture {
        It -Name 'February 30' -Test {
            Convert-APIDateTime -DateTimeString 'Mon Mar 11 09:12:14 UTC 2017' |
                Should -BeExactly $null
        }
    }
}