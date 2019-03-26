Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Private/Get-RubrikAPIData' -Tag 'Private', 'Get-RubrikAPIData' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '4.0'
    }

    #Function List
    $ignorelist = @('Invoke-RubrikRESTCall','Move-RubrikMountVMDK','Sync-RubrikAnnotation','Sync-RubrikTag') 
    $functions = ( Get-ChildItem -Path './Rubrik/Public' | Where-Object extension -eq '.ps1').Name.Replace('.ps1','')
    $functions = $functions | Where-Object {$ignorelist -notcontains $_}

    #CDM versions
    $versions = @('4.0','4.1','4.2','5.0')

    $cases =@()
    foreach($version in $versions){
        foreach($function in $functions){
         $cases += @{'v'=$version;'f' = $function}
        }
    }
    #endregion
    it -Name "Get-RubrikAPIData <v> - <f> test" -TestCases $cases {
        param($v,$f)
        $global:rubrikConnection.version = $v
        $resources = Get-RubrikAPIData -endpoint $f
        $resources.Method | Should -BeIn @('Get','Post','Patch','Delete','Put')
        $resources.URI | Should -Not -Be $null 

    }


}