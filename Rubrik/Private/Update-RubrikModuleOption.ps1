function Update-RubrikModuleOption([string]$OptionType,[string]$OptionName,[string]$OptionValue,[string]$Action) {
<#
    .SYNOPSIS
    Retrieves the default parameter values and applies them globally

    .DESCRIPTION
    This function will retrieve the default parameter values from the users options file and apply them globally.

    .PARAMETER OptionType
    Type of module option to set (ModuleOption or DefaultParameterValue)

    .PARAMETER OptionName
    Option name to modify

    .PARAMETER OptionValue
    Option Value to modify

    .PARAMETER Action
    Action to take (AddUpdate, Remove, Defaults, Sync)
#>

    # Action of Sync is applies to both ModuleOption and DefaultParameterValue.
    # If sync is called, execute and return
    if ("Sync" -eq $Action) {
        Write-Verbose -Message "Setting global options file to match values in user options file"
        # Sync global variable with user options file and apply (handles both defaultparameters and moduleoptions)
        $global:rubrikOptions = Sync-RubrikOptionsFile
        Set-RubrikDefaultParameterValue
        return
    }

    if ("ModuleOption" -eq $OptionType) {
        switch ($Action) {
            "Default" {
                Write-Verbose -Message "Reseting all Module Options to default values"
                # remove all ModuleOptions from global variable and userfile
                $global:rubrikoptions.ModuleOption.psobject.properties | ForEach-Object {$global:rubrikOptions.ModuleOption.psobject.properties.remove($_.Name)}
                $global:rubrikOptions | ConvertTo-Json | Out-File -FilePath "$(Get-HomePath)\rubrik_sdk_for_powershell_options.json"
                # run sync to recreate them from template
                $global:rubrikOptions = Sync-RubrikOptionsFile
                # Remove Credential from PSDefaultParameterValues if it exists as CredentialFiles default is null
                if ($Global:PSDefaultParameterValues.Contains("Connect-Rubrik:Credential") ) {
                    Write-Verbose -Message "Default credentials detected, removing"
                    $Global:PSDefaultParameterValues.Remove("Connect-Rubrik:Credential")
                }
            }
            "AddUpdate" {
                Write-Verbose -Message "Adding/Updating default setting for $($OptionName)"
                # CredentialPath is special as we need to set option and default parameter so deal with it first
                if ($OptionName -eq "CredentialPath") {
                    # First, make sure the path exists...
                    Write-Verbose -Message "CredentialPath option specified, adding to default parameter values"
                    if (Test-Path $OptionValue) {
                        if ($Global:PSDefaultParameterValues.Contains("Connect-Rubrik:Credential") ) {
                            # If value is already set, reconfigure it
                            Write-Verbose -Message "Updating PSDefaultParameterValues for Connect-Rubrik:Credential"
                            $Global:PSDefaultParameterValues."Connect-Rubrik:Credential" = (Import-CliXml -Path $OptionValue)
                        } else {
                            # Otherwise add it
                            Write-Verbose -Message "Adding PSDefaultParameterValue for Connect-Rubrik:Credential"
                            $Global:PSDefaultParameterValues.Add("Connect-Rubrik:Credential",(Import-CliXml -Path $OptionValue))
                        }
                    } elseif ("" -eq $OptionValue) {
                        # Remove from DefaultParameterValues
                        Write-Verbose -Message "Removing PSDefaultParameterValue for Connect-Rubrik:Credential"
                        if ($Global:PSDefaultParameterValues.Contains("Connect-Rubrik:Credential") ) {
                            $Global:PSDefaultParameterValues.Remove("Connect-Rubrik:Credential")
                        }
                    } else {
                        Throw "$OptionValue does not appear to be a valid credential path"
                    }
                }

                # Set value in global variable
                Write-Verbose -Message "Setting $OptionName to $OptionValue in global options"
                $global:rubrikOptions.ModuleOption.$OptionName = $OptionValue
                # overwrite options file with global information
                Write-Verbose -Message "Exporting global options to $(Get-HomePath)\rubrik_sdk_for_powershell_options.json"
                $global:rubrikOptions | ConvertTo-Json | Out-File -FilePath "$(Get-HomePath)\rubrik_sdk_for_powershell_options.json"
            }
            Default {
                Throw "Invalid Action specified"
            }
        }
    }
    elseif ("DefaultParameterValue" -eq $OptionType) {
        switch ($Action) {
            "AddUpdate" {
                if ($Global:rubrikOptions.DefaultParameterValue.PSObject.Properties[$OptionName]) {
                    Write-Verbose -Message "Default Parmater $OptionName exists, updating value to $OptionValue"
                    $global:rubrikOptions.DefaultParameterValue.$OptionName = $OptionValue
                } else {
                    Write-Verbose -Message "Default Parameter $OptionName not found, creating and setting value to $OptionValue"
                $global:rubrikOptions.DefaultParameterValue | Add-Member -NotePropertyName $OptionName -NotePropertyValue $OptionValue
                }

                # Write options back to file.
                Write-Verbose -Message "Syncing global options back to $(Get-HomePath)\rubrik_sdk_for_powershell_options.json"
                $global:rubrikOptions | ConvertTo-Json | Out-File -FilePath "$(Get-HomePath)\rubrik_sdk_for_powershell_options.json"
                # Set newly defined values globally.
                Write-Verbose -Message "Syncing desired Default Parameters to global PSDefaultParameters"
                Set-RubrikDefaultParameterValue
            }
            "RemoveSingle" {
                if ($global:rubrikOptions.DefaultParameterValue.PSObject.Properties[$OptionName]) {
                    Write-Verbose -Message "Removing $OptionName from global rubrikOptions"
                    $global:rubrikOptions.DefaultParameterValue.PSObject.Properties.Remove("$OptionName")
                    Write-Verbose -Message "Removing *Rubrik*:$($OptionName) from PSDefaultParameters"
                    $global:PSDefaultParameterValues.Remove("*Rubrik*:$OptionName")
                }

                # Write options back to file.
                Write-Verbose -Message "Syncing global options back to $(Get-HomePath)\rubrik_sdk_for_powershell_options.json"
                $global:rubrikOptions | ConvertTo-Json | Out-File -FilePath "$(Get-HomePath)\rubrik_sdk_for_powershell_options.json"
                # Set newly defined values globally.
                Write-Verbose -Message "Syncing desired Default Parameters to global PSDefaultParameters"
                Set-RubrikDefaultParameterValue
            }
            "RemoveAll" {
                $global:rubrikoptions.DefaultParameterValue.psobject.properties | ForEach {
                    Write-Verbose -Message "Removing $($_.Name) from global rubrikOptions"
                    $global:rubrikOptions.DefaultParameterValue.psobject.properties.remove($_.Name)
                    Write-Verbose -Message "Removing *Rubrik*:$($_.Name) from PSDefaultParameters"
                    $global:PSDefaultParameterValues.Remove("*Rubrik*:$($_.Name)")
                }

                # Write options back to file.
                Write-Verbose -Message "Syncing global options back to $(Get-HomePath)\rubrik_sdk_for_powershell_options.json"
                $global:rubrikOptions | ConvertTo-Json | Out-File -FilePath "$(Get-HomePath)\rubrik_sdk_for_powershell_options.json"
                # Set newly defined values globally.
                Write-Verbose -Message "Syncing desired Default Parameters to global PSDefaultParameters"
                Set-RubrikDefaultParameterValue
            }
            Default {
                Throw "Invalid Action specified"
            }
        }
    }
}