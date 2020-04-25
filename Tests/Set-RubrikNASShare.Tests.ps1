Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Set-RubrikNASShare' -Tag 'Public', 'Set-RubrikNASShare' -Fixture {
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

    $Cred = (New-Object PSCredential "jaap.brasser@rubrik.us", (ConvertTo-SecureString -String 'JaapDoesntUsePlaintextPasswords' -AsPlainText -Force))
    $SecurePW = (ConvertTo-SecureString -String 'JaapDoesntUsePlaintextPasswords' -AsPlainText -Force)
    #endregion

    Context -Name 'Results Filtering' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'                    = '11-22-33'
                'hostId'                = 'Host:::111'
                'exportPoint'           = 'SMBTest'
                'status'                = 'Connected'
                'username'              = 'jaap.brasser@rubrik.us'
            }
        }
        
        It -Name 'Credential - Should return correct username' -Test {
            (Set-RubrikNASShare -id '11-22-33' -Credential $Cred).username |
                Should -BeExactly 'jaap.brasser@rubrik.us'
        }
        
        It -Name 'Credential - Verify param - exportPoint' -Test {
            (Set-RubrikNASShare -id '11-22-33' -exportPoint 'SMBTest' -Credential $Cred).exportPoint |
            Should -BeExactly 'SMBTest'
        }
        
        It -Name 'Credential - Should return correct password should be decoded from credential object' -Test {
            $Output = & {
                Set-RubrikNASShare -id '11-22-33' -Credential $Cred -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*JaapDoesntUsePlaintextPasswords*'
        }
        
        It -Name 'UserName Password - Should return correct username' -Test {
            (Set-RubrikNASShare -id '11-22-33' -Username jaap.brasser@rubrik.us -Password $SecurePW).username |
                Should -BeExactly 'jaap.brasser@rubrik.us'
        }

        It -Name 'UserName Password - Should return correct password should be decoded from credential object' -Test {
            $Output = & {
                Set-RubrikNASShare -id '11-22-33' -Username jaap.brasser@rubrik.us -Password $SecurePW -Verbose 4>&1
            }
            (-join $Output) | Should -BeLike '*JaapDoesntUsePlaintextPasswords*'
        }

        It -Name 'Parameter ID cannot be empty' -Test {
            { Set-RubrikNASShare -Id '' } |
                Should -Throw "Cannot bind argument to parameter 'id' because it is an empty string."
        } 
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Exactly 5
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Exactly 5
    }
}