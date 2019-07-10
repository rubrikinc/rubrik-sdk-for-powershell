#requires -Version 3
function Register-RBS
{
  <#  
      .SYNOPSIS
      Register the Rubrik Backup Service

      .DESCRIPTION
      Register the Rubrik Backup Service for the specified VM.

      .NOTES
      Written by Pierre-François Guglielmi
      Twitter: @pfguglielmi
      GitHub: pfguglielmi

      .LINK
      https://github.com/rubrikinc/rubrik-sdk-for-powershell

      .EXAMPLE
      Get-RubrikVM -Name "demo-win01" | Register-RBS
      Get the details of VM demo-win01 and register the Rubrik Backup Service installed on it with the Rubrik cluster
      
      .EXAMPLE
      Register-RBS -id VirtualMachine:::2af8fe5f-5b64-44dd-a9e0-ec063753b823-vm-37558
      Register the Rubrik Backup Service installed on this VM with the Rubrik cluster by specifying the VM id
  #>

  [CmdletBinding()]
  Param(
    # ID of the VM which agent needs to be registered
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
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

    return $result

  } # End of process
} # End of function