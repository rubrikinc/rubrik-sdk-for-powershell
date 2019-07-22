#Requires -Version 3
function New-RubrikBootStrap
{
  <#  
      .SYNOPSIS
      Send a Rubrik Bootstrap Request
            
      .DESCRIPTION
      This will send a bootstrap request 
            
      .NOTES
      #DNS Param must be an array even if only passing a single server
      #NTP Must be an array than contains hash table for each server object
      #Nodeconfigs Param must be a hash table object.

            
      .LINK
      https://github.com/nshores/rubrik-sdk-for-powershell/tree/bootstrap
            
      .EXAMPLE
      https://gist.github.com/nshores/104f069570740ea645d67a8aeab19759
      New-RubrikBootStrap -Server 169.254.11.25 
      -name 'rubrik-edge' 
      -dnsNameservers @('192.168.11.1')
      -dnsSearchDomains @('corp.us','branch.corp.us')
      -ntpserverconfigs @(@{server = 'pool.ntp.org'})
      -adminUserInfo @{emailAddress = 'nick@shoresmedia.com'; id ='admin'; password = 'P@SSw0rd!'}
      -nodeconfigs @{node1 = @{managementIpConfig = @{address = '192.168.11.1'; gateway = '192.168.11.100'; netmask = '255.255.255.0'}}}
      
  #>

  [CmdletBinding()]
  Param(
    # ID of the Rubrik cluster or me for self
    [ValidateNotNullOrEmpty()]
    [String] $id = 'me',
    # Rubrik server IP or FQDN
    [ValidateNotNullOrEmpty()]
    [String] $Server,
    # Admin User Info Hashtable
    [Parameter(Mandatory = $true)]
    [ValidateScript({             
      $requiredProperties = @("emailAddress","id","password")
      ForEach($item in $requiredProperties) {
        if(!$_.ContainsKey($item)) {
          Throw "adminUserInfo missing property $($item)"
        }
        if([string]::IsNullOrEmpty($_[$item])) {
          Throw "adminUserInfo $($item) is null or empty"
        }
      }
      return $true
     })]
    [ValidateNotNullOrEmpty()]
    [Object] 
    $adminUserInfo, 
    # Node Configuration Hashtable
    [Parameter(Mandatory = $true)]
    [ValidateScript({             
      $requiredProperties = @("address","gateway","netmask")
      ForEach($node in $_.Keys) {
        $ipConfig = $_[$node].managementIpConfig
        ForEach($item in $requiredProperties) {
          if(!$ipConfig.ContainsKey($item)) {
            Throw "node configuration for $($node) missing property $($item)"
          }
          if([string]::IsNullOrEmpty($ipConfig[$item])) {
            Throw "node configuration for $($node) value $($item) is null or empty"
          }
        }
      }
      return $true
     })]
    [ValidateNotNullOrEmpty()]
    [System.Object]
    $nodeConfigs,
    # Software Encryption
    [bool]
    $enableSoftwareEncryptionAtRest = $false,
    # Cluster/Edge Name
    [ValidateNotNullOrEmpty()]
    [string]
    $name,
    # NTP Servers
    $ntpServerConfigs,
    # DNS Servers
    [String[]]
    $dnsNameservers,
    # DNS Search Domains
    [String[]]
    $dnsSearchDomains
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
    
    #region One-off
    # If there is more than node node, update the API data to contain all data for all nodes
    if($nodeConfigs.Count -gt 1) {
      ForEach($key in $nodeConfigs.Keys) {
        $resources.Body.nodeConfigs[$key] = $nodeConfigs[$key]
      }
    }

    # Default DNS servers to 8.8.8.8
    if($dnsNameServers -eq '') {
      $dnsNameServers = @(
        '8.8.8.8'
      )
    }

    # Default DNS search domains to an empty array
    if($dnsSearchDomains -eq '') {
      $dnsSearchDomains = @()
    }

    # Default NTP servers to pool.ntp.org
    if($ntpServerConfigs.Length -lt 1) {
      $ntpServerConfigs = @(
        @{
          server = 'pool.ntp.org'
        }
      )
    }
    #endregion
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -Headers @{"content-type"="application/json"} -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
