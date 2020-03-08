#Requires -Version 3

function Suspend-RubrikSLA
{
  <#  
      .SYNOPSIS
      Pauses an existing Rubrik SLA Domain

      .DESCRIPTION
      The Pause-RubrikSLA cmdlet will pause an existing SLA Domain with specified parameters. An alias has been created for this function, Pause-RubrikSLA to allign better with the Rubrik Terminology. Note that this functionality is only available on Rubrik Cluster running 5.1 or later.

      .NOTES
      Written by Jaap Brasser for community usage
      Twitter: @jaap_brasser
      GitHub: JaapBrasser

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Suspend-RubrikSLA

      .EXAMPLE
      Get-RubrikSLA -Name Gold | Suspend-RubrikSLA

      This will update the SLA Domain named "Gold" to pause backups

      .EXAMPLE
      Get-RubrikSLA -Name Gold | Pause-RubrikSLA

      This will update the SLA Domain named "Gold" to pause backups

      .EXAMPLE
      Pause-RubrikSLA Gold -Verbose

      This will pause the backups for the Gold SLA while displaying verbose information
  #>

  [CmdletBinding(
    SupportsShouldProcess = $true,
    ConfirmImpact = 'High',
    DefaultParameterSetName='Query' )]
  [Alias("Pause-RubrikSLA")]
  Param(
    # SLA id value from the Rubrik Cluster
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      ValueFromPipelineByPropertyName = $true,
      Mandatory = $true )]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # SLA Domain Name
    [Parameter(
      ParameterSetName='Query',
      Position = 0,
      ValueFromPipeline=$true,
      Mandatory = $true )]
    [Alias('SLA')]
    [ValidateNotNullOrEmpty()]
    [String]$Name,
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
    if ('Query' -eq $pscmdlet.parametersetname) {
      $id = (Get-RubrikSLA -Name $Name -PrimaryClusterID local).id
    }
    
    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    # Custom as paused is always true
    $body = '{"isPaused": true}'
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
    return $result

  } # End of process
} # End of function