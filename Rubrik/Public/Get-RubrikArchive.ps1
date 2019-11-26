#requires -Version 3
function Get-RubrikArchive
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves a list of archive targets

      .DESCRIPTION
      The Get-RubrikArchive cmdlet is used to pull a list of configured archive targets from the Rubrik cluster.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
     https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikarchive

      .EXAMPLE
      Get-RubrikArchive
      This will return all the archive targets configured on the Rubrik cluster.

      .EXAMPLE
      Get-RubrikArchive -name 'archive01'
      This will return the archive targets configured on the Rubrik cluster with the name of 'archive01'.
  #>

  [CmdletBinding()]
  Param(
    # Archive Location ID
    [ValidateNotNullOrEmpty()]
    [Parameter(
        ParameterSetName='ID',
        Position = 0,
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true)]
    [String]$Id,
    # Archive Location Name
    [ValidateNotNullOrEmpty()]
    [Parameter(
        ParameterSetName='Query',
        Position = 0,
        ValueFromPipelineByPropertyName = $true)]
    [String]$Name,
    # Filter by Archive location type (Currently S3 and Azure only)
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('S3', 'Azure','Nfs', 'Google','Qstar','Glacier')]
    [Alias('location_type')]
    [String]$ArchiveType, 
    # DetailedObject will retrieved the detailed archive object, the default behavior of the API is to only retrieve a subset of the archive object. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Parameter(ParameterSetName='Query')]
    
    [Switch]$DetailedObject, 
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
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
    # If the Get-RubrikArchive function has been called with the -DetailedObject parameter,
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      for ($i = 0; $i -lt @($result).Count; $i++) {
        $Percentage = [int]($i/@($result).count*100)
        Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
        
        switch ($result[$i].locationType) {
          "Azure" { Get-RubrikObjectStoreArchive -Name $result[$i].name }
          "S3" { Get-RubrikObjectStoreArchive -Name $result[$i].name }
          "Glacier" { Get-RubrikObjectStoreArchive -Name $result[$i].name }
          "Google" { Get-RubrikObjectStoreArchive -Name $result[$i].name }
          "Nfs" { Get-RubrikNfsArchive -Name $result[$i].name}
          "Qstar" { Get-RubrikQstarArchive -Name $result[$i].name }
        }
      }
    } else {
      return $result
    }
    

  } # End of process
} # End of function