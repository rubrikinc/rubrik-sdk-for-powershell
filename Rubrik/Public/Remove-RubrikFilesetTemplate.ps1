#requires -Version 3
function Remove-RubrikFilesetTemplate
{
  <#  
    .SYNOPSIS
    Removes Fileset Template from a Rubrik Cluster

    .DESCRIPTION
    Removes Fileset Template for either the cluster

    .NOTES
    Written by Jaap Brasser for community usage
    Twitter: @jaap_brasser
    GitHub: jaapbrasser
    
    .LINK
    https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/remove-rubrikfilesettemplate
    
    .EXAMPLE
    Remove-RubrikFilesetTemplate -id FilesetTemplate:::1111
    
    Removes the Rubrik Fileset Template
    
    .EXAMPLE
    Get-RubrikRubrikFilesetTemplate | Remove-RubrikFilesetTemplate -Verbose
    
    Removes the templates supplied by Get-RubrikFilesetTemplate, while displaying Verbose information
    
    .EXAMPLE
    Remove-RubrikFilesetTemplate -id FilesetTemplate:::1111 -PreserveSnapshots:$false
    
    Removes the Fileset Template and does not preserve existing snapshots
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The Rubrik ID value of the fileset
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # When not specified, the default is to preserve snapshots, add -PreserverSnapshots:$false to delete existing snapshots
    [Alias('preserve_snapshots')]
    [Switch]$PreserveSnapshots,
    # Rubrik server IP or FQDN
    [Parameter(
        ValueFromPipelineByPropertyName = $true)]
    [Alias('ipAddress','NodeIPAddress')]
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

    # If nothing is specified, then this value is not presented to the API endpoint, the endpoint currently defaults to true
    if ($null -eq $PreserveSnapshots.IsPresent) {
      $Resources.Query.Remove('preserve_snapshots')
    }
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function