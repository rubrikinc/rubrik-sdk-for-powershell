#requires -Version 3
function New-RubrikFileset
{
  <#  
      .SYNOPSIS
      {required: high level overview}

      .DESCRIPTION
      {required: more detailed description of the function's purpose}

      .NOTES
      Written by {required}
      Twitter: {optional}
      GitHub: {optional}
      Any other links you'd like here

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/new-rubrikfileset

      .EXAMPLE
      New-RubrikFileset -TemplateID '1111-1111-1111-1111' -HostID 'Host::::2222-2222-2222-2222'

      Creates a new fileset on the specified host, using the selected template.

      .EXAMPLE
      New-RubrikFileset -TemplateID (Get-RubrikFilesetTemplate -Name 'FOO').id -ShareID (Get-RubrikNASShare -name 'BAR').id

      Creates a new fileset for the BAR NAS, using the FOO template.

      .EXAMPLE
      New-RubrikFileset -TemplateID (Get-RubrikFilesetTemplate -Name 'FOO').id -ShareID (Get-RubrikNASShare -name 'BAR').id -DirectArchive

      Creates a new fileset for the BAR NAS, using the FOO template. Enables the NAS Direct Archive functionality on the share.
  #>

  [CmdletBinding()]
  Param(
    #Fileset Template ID to use for the new fileset
    [Parameter(ParameterSetName='Host',Mandatory=$true)]
    [Parameter(ParameterSetName='NAS',Mandatory=$true)]
    [String]$TemplateID,
    # HostID - Used for Windows or Linux Filesets
    [Parameter(ParameterSetName='Host',Mandatory=$true)]
    [String]$HostID,
    # ShareID - used for NAS shares
    [Parameter(ParameterSetName='NAS',Mandatory=$true)]
    [String]$ShareID, 
    [Parameter(ParameterSetName='NAS')]
    # DirectArchive - used to specify if data should be directly sent to archive (bypassing Rubrik Cluster)
    [Alias('isPassThrough')]
    [Switch]$DirectArchive , 
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

    if ($DirectArchive) {
      $uri = New-URIString -server $server -endpoint ('/api/internal/fileset/bulk')
      $body = @{
        templateId = $TemplateId
        shareId = $ShareId
        isPassthrough = $true
      }
      $body = ConvertTo-Json @($body)
      Write-Verbose "Body is: $body"
      $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
      $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
      $result = Test-FilterObject -filter ($resources.Filter) -result $result
    }
    else {
      $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
      $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
      $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
      $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
      $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
      $result = Test-FilterObject -filter ($resources.Filter) -result $result
    }
    return $result

  } # End of process
} # End of function