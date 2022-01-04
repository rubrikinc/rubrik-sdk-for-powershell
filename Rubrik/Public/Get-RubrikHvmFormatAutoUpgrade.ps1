#requires -Version 3
function Get-RubrikHvmFormatAutoUpgrade
{
  <#
      .SYNOPSIS
      Retrieves the HyperV Virtual Machine format auto upgrade settings from a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikHvmFormatAutoUpgrade cmdlet is used to retrieve the HyperV Virtual Machine format auto upgrade settings from a Rubrik cluster.
      There are two configurations available:
        - 'migrateFastVirtualDiskBuild' is a boolean flag that controls the use of 
            the fast VHDX builder during Hyper-V virtual machine migration. When
            the flag is 'true', the Hyper-V VM uses the fast VHDX builder the 
            next time, VM is backed up. A value of false disables the fast VHDX
            builder. This flag is used in combination with the 
            maxFullMigrationStoragePercentage value.
        - 'maxFullMigrationStoragePercentage', is an integer which specifies a
            percentage of the total available storage space. When performing a
            full hyperv VM backup operation would bring the total used
            storage space above this threshold, the cluster takes incremental backups
            instead. This value is used in combination with the
            migrateFastVirtualDiskBuild flag.

      .NOTES
      Written by Abhinav Prakash for community usage
      github: ab-prakash

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikhvmformatautoupgrade

      .EXAMPLE
      Get-RubrikHvmFormatAutoUpgrade
      This will return the HyperV Virtual Machine format auto upgrade settings from the connected cluster.
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result
  } # End of process
} # End of function
