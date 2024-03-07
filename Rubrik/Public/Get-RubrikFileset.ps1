#requires -Version 3
function Get-RubrikFileset
{
  <#
      .SYNOPSIS
      Retrieves details on one or more filesets known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikFileset cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of filesets
      A number of parameters exist to help narrow down the specific fileset desired
      Note that a fileset name is not required; you can use params (such as HostName and SLA) to do lookup matching filesets

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/get-rubrikfileset

      .EXAMPLE
      Get-RubrikFileset -Name 'C_Drive'
      This will return details on the fileset named "C_Drive" assigned to any hosts

      .EXAMPLE
      Get-RubrikFileset -Name 'C_Drive' -HostName 'Server1'
      This will return details on the fileset named "C_Drive" assigned to only the "Server1" host

      .EXAMPLE
      Get-RubrikFileset -Name 'C_Drive' -SLA Gold
      This will return details on the fileset named "C_Drive" assigned to any hosts with an SLA Domain matching "Gold"

      .EXAMPLE
      Get-RubrikFileset -NameFilter '_Drive' -SLA Gold
      This will return details on the filesets that contain the string "_Drive" in its name and are assigned to any hosts with an SLA Domain matching "Gold"

      .EXAMPLE
      Get-RubrikFileset -HostName 'mssqlserver01' -SLA Gold
      This will return details on the filesets for the hostname "mssqlserver01" and are assigned to any hosts with an SLA Domain matching "Gold"

      .EXAMPLE
      Get-RubrikFileset -HostNameFilter 'mssql' -SLA Gold
      This will return details on the filesets that contain the string "mssql" in its parent's hostname and are assigned to any hosts with an SLA Domain matching "Gold"

      .EXAMPLE
      Get-RubrikFileset -id 'Fileset:::111111-2222-3333-4444-555555555555'
      This will return the filset matching the Rubrik global id value of "Fileset:::111111-2222-3333-4444-555555555555"

      .EXAMPLE
      Get-RubrikFileset -Relic
      This will return all removed filesets that were formerly protected by Rubrik.

      .EXAMPLE
      Get-RubrikFileset -DetailedObject
      This will return the fileset object with all properties, including additional details such as snapshots taken of the Fileset object. Using this switch parameter negatively affects performance
  #>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Name of the fileset
    [Parameter(
      ParameterSetName='Query',
      Position = 0)]
    [ValidateNotNullOrEmpty()]
    [Alias('Fileset')]
    [String]$Name,
    [Parameter(ParameterSetName='Filter')]
    [ValidateNotNullOrEmpty()]
    [String]$NameFilter,
    # Exact name of the host using a fileset
    [Parameter(ParameterSetName='Query')]
    [Alias('host_name')]
    [ValidateNotNullOrEmpty()]
    # Partial match of hostname, using an 'in fix' search.
    [String]$HostName,
    [Parameter(ParameterSetName='Filter')]
    [ValidateNotNullOrEmpty()]
    [String]$HostNameFilter,
    # Rubrik's fileset id
    [Parameter(ParameterSetName='ID')]
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Filter results to include only relic (removed) filesets
    [Alias('is_relic')]
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='Filter')]
    [Switch]$Relic,
    # DetailedObject will retrieved the detailed VM object, the default behavior of the API is to only retrieve a subset of the full Fileset object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='Filter')]
    [switch]$DetailedObject,
    # SLA Domain policy assigned to the database
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='Filter')]
    [ValidateNotNullOrEmpty()]
    [String]$SLA,
    # Filter the summary information based on the ID of a fileset template.
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='Filter')]
    [Alias('template_id')]
    [ValidateNotNullOrEmpty()]
    [String]$TemplateID,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='Filter')]
    [Alias('primary_cluster_id')]
    [ValidateNotNullOrEmpty()]
    [String]$PrimaryClusterID,
    # Rubrik's Share id
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='Filter')]
    [Alias('share_id')]
    [ValidateNotNullOrEmpty()]
    [String]$ShareID,
    # SLA id value
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='Filter')]
    [Alias('effective_sla_domain_id')]
    [ValidateNotNullOrEmpty()]
    [String]$SLAID,
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='Filter')]
    [Parameter(ParameterSetName='ID')]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='Filter')]
    [Parameter(ParameterSetName='ID')]
    [String]$api = $global:RubrikConnection.api
  )

  # If connected to RSC, redirect to new GQL cmdlet
  if ($global:rubrikConnection.RSCInstance) {
    Write-Verbose -Message "Cluster connected to RSC instance, redirecting to Get-RubrikRSCFileset"
    #$response = Get-RubrikRSCHost @PSBoundParameters
    #return $response
  }
  
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
    Write-Verbose -Message "Load API data for $($resources.URI)"
    Write-Verbose -Message "Description: $($resources.Description)"

    # Set Hostname and Name parameters if the filter parameters are specified. Logic later on in the script will do additional filtering
    if (-not [string]::IsNullOrWhiteSpace($HostNameFilter)) {
      $HostName = $HostNameFilter
    }
    if (-not [string]::IsNullOrWhiteSpace($NameFilter)) {
      $Name = $NameFilter
    }

  }

  Process {
    #region One-off
    # If SLA paramter defined, resolve SLAID
    If ($SLA) {
      $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

    # This block of code will filter results if -Name or -Hostname are used, probably should move to a private function
    if ('Query' -eq $PSCmdlet.ParameterSetName) {
      'Name','HostName' | ForEach-Object {
        if ($null -ne $PSBoundParameters.$_) {
          $result = Select-ExactMatch -Parameter $_ -Result $Result
        }
      }
    }

    # If the Get-RubrikFileset function has been called with the -DetailedObject parameter a separate API query will be performed if the initial query was not based on ID
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      Write-Verbose -Message "DetailedObject detected, requerying for more detailed results"
      $result = Get-RubrikDetailedResult -result $result -cmdlet "$($MyInvocation.MyCommand.Name)"
    }
    return $result

  } # End of process
} # End of function