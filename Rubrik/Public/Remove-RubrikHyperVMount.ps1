#Requires -Version 3
function Remove-RubrikHyperVMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and removes one or more live mounts
            
      .DESCRIPTION
      The Remove-RubrikHyperVMount cmdlet is used to request the deletion of one or more instant mounts
            
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
            
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikhypervmount

      .EXAMPLE
      Remove-RubrikHyperVMount -id '11111111-2222-3333-4444-555555555555'
      This will remove mount id "11111111-2222-3333-4444-555555555555".
            
      .EXAMPLE
      Get-RubrikMount | Remove-RubrikHyperVMount
      This will remove all mounted virtual machines.

      .EXAMPLE
      Get-RubrikMount -VMID (Get-RubrikVM -VM 'Server1').id | Remove-RubrikHyperVMount
      This will remove any mounts found using the virtual machine named "Server1" as a base reference.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The Rubrik ID value of the mount
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Force unmount to deal with situations where host has been moved.
    [Switch]$Force,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)        
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function