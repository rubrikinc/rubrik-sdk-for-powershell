Describe -Name 'ObjectDefinitions' -Tag 'Public', 'ObjectDefinitions' -Fixture {
    Context -Name 'Test script logic' -Fixture {
        $cases = Get-ChildItem ./Rubrik/{
            @{'v'=$versions;'f' = $function}
        }

    }
}