#Requires -Version 3
function Get-RubrikHostVolume
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves information of volumes connected to a host
            
      .DESCRIPTION
      The Get-RubrikHostVolume cmdlet will retrieve all volume of the selected windows host that are currently present
            
      .NOTES
      Written by Pierre Flammer for community usage
      Twitter: @PierreFlammer
      GitHub: Pierre-PvF
            
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhostvolume
            
      .EXAMPLE
      Get-RubrikHostVolume -id Host:::a9d9a5ac-ed22-4723-b329-74db48c93e03

      .EXAMPLE
      Get-RubrikHost -name 2016.flammi.home | Get-RubrikHostVolume
  #>

  [CmdletBinding()]
  Param(
    # Host ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]    
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

    # only return volumes that are currently present on the system
    return $result | where-object {($_.isCurrentlyPresentOnSystem -eq "True")}

  } # End of process
} # End of function