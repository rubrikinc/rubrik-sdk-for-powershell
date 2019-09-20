#Requires -Version 3
function Get-RubrikVMwareDatastore
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves a list of VMware datastores
            
      .DESCRIPTION
      The Get-RubrikVMwareDatastore cmdlet will retrieve VMware datastores known to an authenticated Rubrik cluster.
            
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikVMwareDatastore.html
            
      .EXAMPLE
      Get-RubrikVMwareDatastore
      This will return a listing of all of the datastores known to a connected Rubrik cluster
      
      .EXAMPLE
      Get-RubrikVMwareDatastore -Name 'vSAN'
      This will return a listing of all of the datastores named 'vSAN' known to a connected Rubrik cluster
      
      .EXAMPLE
      Get-RubrikVMwareDatastore -DatastoreType 'NFS'
      This will return a listing of all of the NFS datastores known to a connected Rubrik cluster
  #>

  [CmdletBinding()]
  Param(
    # Datastore Name
    [String]$Name,
    # Filter Datastore type
    [ValidateSet('VMFS', 'NFS','vSAN')]
    [String]$DatastoreType,     
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
    $result = Set-ObjectTypeName -TypeName $resources.ObjectLabel -result $result

    return $result

  } # End of process
} # End of function