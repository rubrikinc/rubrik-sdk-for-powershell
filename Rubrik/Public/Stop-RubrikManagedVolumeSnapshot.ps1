#requires -Version 3
function Stop-RubrikManagedVolumeSnapshot
{
  <#  
      .SYNOPSIS
      Stops Rubrik Managed Volume snopshot

      .DESCRIPTION
      The Stop-RubrikManagedVolumeSnapshot cmdlet is used to close a Rubrik Managed Volume
      for read/write actions.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/stop-rubrikmanagedvolumesnapshot

      .EXAMPLE
      Stop-ManagedVolumeSnapshot -id ManagedVolume:::f68ecd45-bdb9-46dd-aea4-8f041fb2dec2

      Close the specified managed volume for read/write operations

      .EXAMPLE
      Get-RubrikManagedVolume -name 'foo' | Stop-ManagedVolumeSnapshot

  #>

  [CmdletBinding(SupportsShouldProcess = $true)]
  Param(
    # Rubrik's Managed Volume id value
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
     # The SLA Domain in Rubrik
     [String]$SLA,
     # The snapshot will be retained indefinitely and available under Unmanaged Objects
     [Switch]$Forever,
         # SLA id value
    [String]$SLAID, 
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

    #region One-off
    if($SLA -ne $null -or $Forever -eq '$true'){
      $SLAID = Test-RubrikSLA -SLA $SLA -DoNotProtect $Forever
    }
    #endregion One-off
  
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    #Custom body is used, uncomment this line and integrate if more options are added
    #$body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)  

    #region Add-SLAID
    if($SLAID){
      $body = @{retentionConfig=@{slaId=$SLAID}} | ConvertTo-Json 
      Write-Verbose -Message "Body = $body"
    }
    #endregion Add-SLAID

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function