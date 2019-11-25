#Requires -Version 3
function Set-RubrikSetting
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and sets Rubrik cluster settings
            
      .DESCRIPTION
      The Set-RubrikSetting cmdlet will set the cluster settings on the system. This does require authentication.
            
      .NOTES
      Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage
            
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/set-rubriksetting
            
      .EXAMPLE
      Set-RubrikSetting -ClusterName "test-rubrik-cluster" -Timezone "America/Los Angeles" -ClusterLocation "LA Office"
      This will set the designated cluster settings on the Rubrik cluster
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # New name for a Rubrik cluster
    [Parameter(Mandatory=$True)]
    [Alias('name')]
    [string]$ClusterName,
    # New time zone for a Rubrik cluster 
    [Parameter(Mandatory=$True)]
    [ValidateSet("Africa/Johannesburg","Africa/Lagos","Africa/Nairobi","America/Anchorage","America/Araguaina","America/Barbados","America/Chicago","America/Denver","America/Los_Angeles","America/Mexico_City","America/New_York","America/Noronha","America/Phoenix","America/Toronto","America/Vancouver","Asia/Bangkok","Asia/Dhaka","Asia/Hong_Kong","Asia/Karachi","Asia/Kathmandu","Asia/Kolkata","Asia/Magadan","Asia/Singapore","Asia/Tokyo","Atlantic/Cape_Verde","Australia/Perth","Australia/Sydney","Europe/Amsterdam","Europe/Athens","Europe/London","Europe/Moscow","Pacific/Auckland","Pacific/Honolulu","Pacific/Midway","UTC")]
    [string]$Timezone,
    # Address information for mapping the location of the Rubrik cluster. This value is used to provide a location for the Rubrik cluster on the dashboard map
    [Parameter(Mandatory=$True)]
    [string]$ClusterLocation,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # ID of the Rubrik cluster or me for self
    [String]$id = 'me',
    # API version
    [ValidateNotNullorEmpty()]
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
    #region One-off
    Write-Verbose -Message "Build the body"
    [PSCustomObject]$tz = @{timezone = $timezone}
    [PSCustomObject]$add = @{address = $clusterLocation}

    Write-Verbose "TimeZone = $tz"
    Write-Verbose "Address = $add"

    $body = @{
        $resources.Body.timezone = $tz
        $resources.Body.geolocation = $add
        $resources.Body.name = $clusterName
    }
        
    $body = ConvertTo-Json $body
    Write-Verbose -Message "Body = $body"
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    #$body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function