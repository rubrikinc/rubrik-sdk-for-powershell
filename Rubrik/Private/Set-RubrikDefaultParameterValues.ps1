function Set-RubrikDefaultParameterValues() {
    <#
      .SYNOPSIS
      Retrieves the default parameter values and applies them globally

      .DESCRIPTION
      This function will retrieve the default parameter values from the users options file and apply them globally.
    #>

    # Load Default Parameter Values
    $Global:rubrikOptions.DefaultParameterValue.PSObject.Properties | ForEach-Object {
        if ($_.Value -ne "") {
            if ($Global:PSDefaultParameterValues.Contains("*Rubrik*:$($_.Name)") ) {
               $Global:PSDefaultParameterValues."*Rubrik*:$($_.Name)" = "$($_.Value)"
            }
            else {
                $Global:PSDefaultParameterValues.Add("*Rubrik*:$($_.Name)","$($_.Value)")
            }

        }
    }
}