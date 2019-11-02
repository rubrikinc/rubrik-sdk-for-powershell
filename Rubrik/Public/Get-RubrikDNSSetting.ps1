#Requires -Version 3
function Get-RubrikDNSSetting
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves DNS Settings assigned to a given cluster
            
      .DESCRIPTION
      The Get-RubrikDNSSetting cmdlet will retrieve information around the node members of a given cluster.
            
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikDNSSetting.html
            
      .EXAMPLE
      Get-RubrikDNSSetting 
      This will return the information around the DNS settings of the currently authenticated cluster
  #>

  [CmdletBinding()]
  Param(
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section

    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    
    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
  }

  Process {

    $result = New-Object -TypeName psobject
    foreach ($key in $resources.URI.Keys ) {
        $uri = New-URIString -server $Server -endpoint $Resources.URI[$key] -id $id
        $iresult = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
        # support for < 5.0
        if ($null -ne $iresult.data ) { $iresult = $iresult.data }
        
        switch ($key) {
            "DNSServers"        {$result | Add-Member -NotePropertyName "$key" -NotePropertyValue $iresult}
            "DNSSearchDomain"   {$result | Add-Member -NotePropertyName "$key" -NotePropertyValue $iresult}
        }
    }
    return $result

  } # End of process
} # End of function