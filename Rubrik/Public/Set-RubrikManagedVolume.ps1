#requires -Version 3
function Set-RubrikManagedVolume
{
  <#  
      .SYNOPSIS
      Sets Rubrik Managed Volume properties

      .DESCRIPTION
      The Set-RubrikMakangedVolume cmdlet is used to update certain settings for a Rubrik Managed Volume.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Set-RubrikManagedVolume -id ManagedVolume:::f68ecd45-bdb9-46dd-aea4-8f041fb2dec2 -SLA 'Gold'

      Protect the specified managed volume with the 'Gold' SLA domain

      .EXAMPLE
      Set-RubrikManagedVolume -id ManagedVolume:::f68ecd45-bdb9-46dd-aea4-8f041fb2dec2 -VolumeSize 536870912000
      
      .EXAMPLE
      Set-RubrikManagedVolume -id ManagedVolume:::f68ecd45-bdb9-46dd-aea4-8f041fb2dec2 -Name 'NewName'

      Resize the specified managed volume to 536870912000 bytes (500GB)

  #>

   [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik's Managed Volume id value
    [Parameter(ValueFromPipelineByPropertyName = $true,Mandatory=$true)]
    [String]$id,
    #Size of the Managed Volume in Bytes
    [int64]$VolumeSize,
    #Export config, such as host hints and host name patterns
    [PSCustomObject[]]$exportConfig,
    #SLA Domain ID for the database
    [Alias('ConfiguredSlaDomainId')]
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [string]$SLAID,
    # The SLA Domain name in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Managed Volume Name
    [ValidateNotNullOrEmpty()]
    [String]$Name,
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

    #region One-off
    if($SLA){
      $SLAID = Test-RubrikSLA $SLA
    }
    
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
