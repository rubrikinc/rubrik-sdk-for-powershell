Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Private/Submit-Request' -Tag 'Private', 'Submit-Request' -Fixture {
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

    Context -Name 'Method:Delete' {
        It 'Parse as Windows PowerShell' {

        }
        It 'Parse as PowerShell' {
            
        }
        It 'Status:success' {
            
        }
        It 'Status:error' {
            
        }
    }

    Context -Name 'Method:Other' {
        It 'Parse as Windows PowerShell' {

        }
        It 'Parse as PowerShell' {
            
        }
    }

    Context -Name 'Error' {
    
    }
}