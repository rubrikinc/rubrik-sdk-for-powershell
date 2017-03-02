#requires -Version 3
function Get-UnmanagedObjects
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more virtual machines known to a Rubrik cluster

      .DESCRIPTION
      The Get-UnmanagedObjects cmdlet is used to pull a detailed data set from a Rubrik cluster on unmanaged objects

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      Get-UnmanagedObjects 
      This will return the ID of the virtual machine named Server1
  #>

  [CmdletBinding()]
  Param(      
    # Filter results based on object_type, VirtualMachine, MssqlDatabase, Fileset
    [Parameter(Position = 1)]
    [Alias('object_status')]
    [ValidateSet('VirtualMachine', 'MssqlDatabase',"fileset")]
    [String]$Filter,
    # Rubrik server IP or FQDN
    [Parameter(Position = 2)]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(Position = 3)]
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Process {

    TestRubrikConnection
        
    Write-Verbose -Message 'Determining which version of the API to use'
    $resources = GetRubrikAPIData -endpoint ('UnmanagedObject')
    
    Write-Verbose -Message 'Building the URI'
    $uri = 'https://'+$Server+$resources.$api.URI

    # Optional parameters for the query
    # We'll start with an empty array
    $params = @()

    # Param #1 = Filter
    # Can filter results based on active, relic (archived), or all VMs
    if ($Filter -and $resources.$api.Params.Filter -ne $null) 
    {
      $params += $($resources.$api.Params.Filter)+'='+$Filter
    }
    
    # Param #2 = Search
    # Optional search filter if a VM is specified
    # Otherwise, all VMs will be retrieved
    if ($VM -and $resources.$api.Params.Search -ne $null) 
    {
      $params += $($resources.$api.Params.Search)+'='+$VM
    }
    
    # Param #3 = Limit
    # Optional limitation on the number of results returned
    # By default, the API only returns a small subset of the objects
    $params += 'limit=9999'

    # Build the optional params string for the query
    # Start by using a "?" for the first param, and then use an "&" for any additional params
    foreach ($_ in $params)
    {
      if ($_ -eq $params[0]) 
      {
        $uri += '?'+$_
      }
      else 
      {
        $uri += '&'+$_
      }
    }      

    # Set the method
    $method = $resources.$api.Method

    try 
    {
      Write-Verbose -Message "Submitting a request to $uri"
      $r = Invoke-WebRequest -Uri $uri -Headers $Header -Method $method
      
      Write-Verbose -Message 'Convert JSON content to PSObject (Max 64MB)'
      [void][System.Reflection.Assembly]::LoadWithPartialName('System.Web.Extensions')
      $result = ParseItem -jsonItem ((New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{
            MaxJsonLength = 67108864
      }).DeserializeObject($r.Content))
      
      # The v0 API doesn't have queries
      # This will manually filter the results if the user has provided inputs
      if ($api -ne 'v0') 
      {
        # Strip out the overhead
        $result = $result.data
      }

    write-host "Name,Status,Snapshot Count"
    foreach ($item in $result)
    {
        write-host $item.name "," $item.unmanagedStatus "," $item.unmanagedSnapshotCount
    }  
    
    }
    catch 
    {
      throw $_
    }

  } # End of process
} # End of function
