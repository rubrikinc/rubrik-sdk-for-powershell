#requires -Version 3
function Get-RubrikHvmForceFullSpec
{
  <#
      .SYNOPSIS
      Retrieves the HyperV Virtual Machine's force full spec from a Rubrik cluster for a given VM's Id.

      .DESCRIPTION
      The Get-RubrikHvmForceFullSpec cmdlet is used to retrieve the HyperV Virtual Machine force full spec from a Rubrik cluster.
      Below is an example of the response body.
      {
        "vmId": "HypervVirtualMachine:::4d681fd8-e82c-4611-aa33-ec5ffdfb1d66",
        "virtualDiskInfos": [
          {
            "virtualDiskId": "4d681fd8-e82c-4611-aa33-ec5ffdfb1d66-47E7F3D6-2BA6-86F8-061A-858F00000000",
            "shouldDedupe": true
          },
          {
            "virtualDiskId": "4d681fd8-e82c-4611-aa33-ec5ffdfb1d66-42152AF4-4A8D-AE8D-8897-A33E00000000",
            "shouldDedupe": true
          }
        ]
      }

      .NOTES
      Written by Abhinav Prakash for community usage
      github: ab-prakash

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmforcefullspec

      .EXAMPLE
      Get-RubrikHvmForceFullSpec -id HypervVirtualMachine:::4d681fd8-e82c-4611-aa33-ec5ffdfb1d66
      This will return the HyperV Virtual Machine format auto upgrade settings from the connected cluster.
  #>

  [CmdletBinding()]
  Param(
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
