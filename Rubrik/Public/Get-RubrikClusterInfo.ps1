#Requires -Version 3
function Get-RubrikClusterInfo
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves node information for a given cluster
            
      .DESCRIPTION
      The Get-RubrikClusterInfo cmdlet will retrieve various information and settings for a given cluster.
            
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
            
      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/Get-RubrikClusterInfo
            
      .EXAMPLE
      Get-RubrikClusterInfo 
      This will return the advanced settings and information around the currently authenticated cluster.
  #>

  [CmdletBinding()]
  Param(
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
    
    $result = @{}
    foreach ($key in $resources.URI.Keys ) {
        $uri = New-URIString -server $Server -endpoint $Resources.URI[$key] -id $id
        $iresult = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
        switch ($key) {
            {$_ -in "BrikCount","CPUCoresCount"} { $result.Add($key, $iresult.count) }
            
            "MemoryCapacityInGb" { $result.add($key,($iresult.bytes / 1GB)) } 
            "ConnectedToPolaris"  { $result.add($key,$iresult.isConnected) } 
            "NodeCount"         { $result.add($key, $iresult.total) } 
            "Platform"         { $result.add($key,$iresult.platform ) } 
            {$_ -in "HasTPM","OnlyAzureSupport","IsEncrypted","IsHardwareEncrypted","IsOnCloud","IsRegistered","IsSingleNode" }  { 
              $result.add($key, $iresult.value )  
            }
            "GeneralInfo" {
              $result.add("Name", $iresult.name) 
              $result.add("Id",$iresult.id  ) | Add-Member -NotePropertyName "Id" -NotePropertyValue $iresult.id 
              $result.add("APIVersion", $iresult.apiVersion)
              $result.add("timezone",$iresult.timezone ) 
              $result.add("geolocation", $iresult.geolocation)
              $result.add("acceptedEulaVersion",$iresult.acceptedEulaVersion) 
              $result.add("softwareVersion", $iresult.version) 
            }
            "Status" {
              $result.add("ClusterStatus",$iresult.status ) 
            }
            
        }
    }

    return $result

  } # End of process
} # End of function