Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Private/Convert-APIDateTime' -Tag 'Private', 'Convert-APIDateTime' -Fixture {
    Context -Name 'Results Filtering' {
        It -Name 'Should convert date correctly' -Test {
            (Convert-APIDateTime).Count |
                Should -BeExactly 5
        }    
        
        $cases = 'Mon Jan 10 17:12:14 UTC 2019',
        'Mon Mar 11 09:12:14 UTC 2017',
        'Mon Sep 12 23:12:14 UTC 2018',
        'Mon Dec 13 14:12:14 UTC 2006' | ForEach-Object {
            @{'DateTimeString' = $_}
            
        }

        It -Name "Get-RubrikAPIData - <f> test" -TestCases $cases {
            
        }
    }
}