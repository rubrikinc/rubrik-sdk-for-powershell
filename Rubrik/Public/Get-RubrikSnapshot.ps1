#Requires -Version 3
function Get-RubrikSnapshot
{
  <#  
      .SYNOPSIS
      Retrieves all of the snapshots (backups) for any given object
      
      .DESCRIPTION
      The Get-RubrikSnapshot cmdlet is used to query the Rubrik cluster for all known snapshots (backups) for any protected object
      The correct API call will be made based on the object id submitted
      Multiple objects can be piped into this function so long as they contain the id required for lookup
      
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
      
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
      
      .EXAMPLE
      Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
      This will return all snapshot (backup) data for the virtual machine id of "VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345"

      .EXAMPLE
      Get-Rubrikvm 'Server1' | Get-RubrikSnapshot -Date '03/21/2017'
      This will return the closest matching snapshot to March 21st, 2017 for any virtual machine named "Server1"

      .EXAMPLE
      Get-RubrikDatabase 'DB1' | Get-RubrikSnapshot -OnDemandSnapshot
      This will return the details on any on-demand (user initiated) snapshot to for any database named "DB1"
  #>

  [CmdletBinding()]
  Param(
    # Rubrik id of the protected object
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Filter results based on where in the cloud the snapshot lives
    [Int]$CloudState,
    # Filter results to show only snapshots that were created on demand
    [Switch]$OnDemandSnapshot,
    # Date of the snapshot
    [Datetime]$Date,
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
    $resources = (Get-RubrikAPIData -endpoint $function).$api
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
  
  }

  Process {

    Write-Verbose -Message 'Build the URI'
    Switch -Wildcard ($id)
    {
      'VirtualMachine*'
      {
        Write-Verbose -Message 'Loading VMware API data'
        $uri = 'https://'+$Server+$resources.URI.VMware
      }
      'MssqlDatabase*'
      {
        Write-Verbose -Message 'Loading MSSQL API data'
        $uri = 'https://'+$Server+$resources.URI.MSSQL
      }
    }
    $uri = $uri -replace '{id}', $id

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    
    Write-Verbose -Message 'Formatting return value'
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-ReturnFilter -object $CloudState -location $resources.Filter['$CloudState'] -result $result
    $result = Test-ReturnFilter -object ([boolean]::Parse($OnDemandSnapshot)) -location $resources.Filter['$OnDemandSnapshot'] -result $result
    if ($Date) 
    {
      $result = Test-ReturnFilter -object (Test-DateDifference -date $($result.date) -compare $Date) -location $resources.Filter['$Date'] -result $result
    }
    
    return $result

  } # End of process
} # End of function