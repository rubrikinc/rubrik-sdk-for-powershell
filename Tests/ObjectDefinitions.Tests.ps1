Describe -Name 'ObjectDefinitions' -Tag 'Public', 'ObjectDefinitions' -Fixture {
    Context -Name 'Test script logic' -Fixture {
        $cases = Get-ChildItem ./Rubrik/ObjectDefinitions | ForEach-Object {
            @{'o' = $_.BaseName}
        }

        It -Name "ObjectDefinition - <o> - XML Validation Test" -TestCases $cases { 
            param($o)
            $ErrorActionPreference = 'Stop'
            {[xml](Get-Content -Path "./Rubrik/ObjectDefinitions/$o.ps1xml" -Raw)} | Should -Not -Throw
        }

        It -Name "ObjectDefinition - <o> - Correct ViewType" -TestCases $cases { 
            param($o)
            Get-Content -Path "./Rubrik/ObjectDefinitions/$o.ps1xml" -Raw | Should -BeLike "*<TypeName>$O*"
        }
    }
}