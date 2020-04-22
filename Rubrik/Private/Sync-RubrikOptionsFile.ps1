function Sync-RubrikOptionsFile() {
    <#
      .SYNOPSIS
      Syncs a users options file with the template and creates the global rubrikOptions variable

      .DESCRIPTION
      This function will check the default options file provided with the module and copy any new key/values to the users options file, maintaining any key/values which have been previously set.
    #>



    # Check for existance of options file and copy default if none
    if (-not (Test-Path $Home\rubrik_sdk_for_powershell_options.json)) {
        Write-Verbose -Message "Options file does not exist, creating $Home\rubrik_sdk_for_powershell_options.json with defaults"
        Copy-Item -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\OptionsDefault\rubrik_sdk_for_powershell_options.json" -Destination $Home\
    }

    # Retrieve custom options
    $rubrikOptions = Get-Content -Raw -Path $Home\rubrik_sdk_for_powershell_options.json | ConvertFrom-Json

    # Retrieve default options, write warning if file does not exist
    if (Test-Path -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\OptionsDefault\rubrik_sdk_for_powershell_options.json") {
        $rubrikDefaults = Get-Content -Raw -Path "$($MyInvocation.MyCommand.Module.ModuleBase)\OptionsDefault\rubrik_sdk_for_powershell_options.json" | ConvertFrom-Json
    } else {
        Write-Warning -Message 'rubrik_sdk_for_powershell_options.json not found in module path, cannot synchronize settings...'
    }
    # Check if any default options exist in DefaultPropertyValues realm which aren't already defined in custom options, if so, add them.
    $rubrikDefaults.DefaultParameterValue.PSObject.Properties | ForEach-Object {
        if (-not $rubrikOptions.DefaultParameterValue.PSObject.Properties["$($_.name)"]) {
            Add-Member -InputObject $rubrikOptions.DefaultParameterValue -NotePropertyName "$($_.Name)" -NotePropertyValue "$($_.Value)"

        }
    }
    # Check if any default options exist in ModuleOptions realm which aren't already defined in custom options, if so, add them.
    $rubrikDefaults.ModuleOption.PSObject.Properties | ForEach-Object {
        if (-not $rubrikOptions.ModuleOption.PSObject.Properties["$($_.name)"]) {
            Add-Member -InputObject $rubrikOptions.ModuleOption -NotePropertyName "$($_.Name)" -NotePropertyValue "$($_.Value)"
        }
    }
    # Export $rubrikOptions back to user file...
    $rubrikOptions | ConvertTo-Json | Out-File $Home\rubrik_sdk_for_powershell_options.json

    return $rubrikOptions
  }