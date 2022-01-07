function Test-FilterObject($filter, $result) {
  <#
    .SYNOPSIS
    Used to filter response objects

    .DESCRIPTION
    The Test-FilterObject function is used to filter data that has been returned from an endpoint for specific objects important to the user as specified in Get-RubrikAPIData

    .PARAMETER filter
    The list of parameters that the user can use to filter response data. Each key is the parameter name without the "$" and each value corresponds to the response data's key
    
    .PARAMETER result
    The formatted API response content
  #>

  Write-Verbose -Message 'Filter the results'
  foreach ($param in $filter.Keys) {
    if ((Get-Variable -Name $param -ErrorAction SilentlyContinue).Value -ne $null) {
      Write-Verbose -Message "Filter match = '$param' with value = '$((Get-Variable -Name $param).Value)'"
      $result = Test-ReturnFilter -object (Get-Variable -Name $param).Value -location $filter[$param] -result $result
    }
  }
    
  return $result
}
