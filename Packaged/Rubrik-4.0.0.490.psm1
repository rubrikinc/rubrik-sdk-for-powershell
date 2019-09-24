function Convert-APIDateTime {
<#
.SYNOPSIS
Function to convert specific date time format from API endpoint to a datetime object

.EXAMPLE
Convert-APIDateTime "Thu Aug 08 20:31:36 UTC 2019" 

Thursday, August 8, 2019 8:31:36 PM
#>
    [cmdletbinding()]
    param(
        [parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string] $DateTimeString
    )

    begin {
        [System.Globalization.DateTimeFormatInfo]::InvariantInfo.get_abbreviatedmonthnames() | ForEach-Object -Begin {
            $MonthHash = @{}
            $Count = 0
        } -Process {
            $Count++
            if ($_) {
                $MonthHash.$_ = $Count.ToString().Padleft(2,'0')
            }
        }
    }

    process {
        $NewDateTimeString = $DateTimeString.Substring(4) -replace 'UTC '
        $MonthHash.GetEnumerator() | ForEach-Object {
            $NewDateTimeString = $NewDateTimeString -replace $_.Key,$_.Value
        }

        try {
            [DateTime]::ParseExact($NewDateTimeString,'MM dd HH:mm:ss yyyy',$null)
        } catch {
        }
    }
}
<#
Helper function to convert a local format string to datetime
#>
function ConvertFrom-LocalDate()
{

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,HelpMessage = 'Date in your computer local date format',ValueFromPipeline = $true)]
        [ValidateNotNullorEmpty()]
        [String]$Date
    )

    try
    {
        $Date -as [datetime] | Out-Null
    }
    catch
    {
        throw 'You did not enter a valid date and time'
    }

    $DateTimeParts = $Date -split ' '
	
	$DateParts = $DateTimeParts[0] -split '/|-|\.'

	$DateFormatParts = (Get-Culture).DateTimeFormat.ShortDatePattern -split '/|-|\.'
    $Month_Index = ($DateFormatParts | Select-String -Pattern 'M').LineNumber - 1
    $Day_Index = ($DateFormatParts | Select-String -Pattern 'd').LineNumber - 1
    $Year_Index = ($DateFormatParts | Select-String -Pattern 'y').LineNumber - 1	
	
	$TimeParts = $DateTimeParts[1..$($DateTimeParts.Count - 1)]
	
	if (@($TimeParts).Count -eq 2)
	{
		$TimeFormatParts = (Get-Culture).DateTimeFormat.ShortTimePattern -split ' '
	
		$TT_Index = ($TimeFormatParts | Select-String -Pattern 't').LineNumber - 1
		$Time_Index = 1 - $TT_Index
		
		$Time = $TimeParts[$Time_Index,$TT_Index] -join ' '
	}
	else
	{
		$Time = $TimeParts
	}
	
	[datetime]$DateTime = [DateTime] $($($DateParts[$Month_Index,$Day_Index,$Year_Index] -join '/') + ' ' + $Time)

    return $DateTime.AddSeconds(59)

}
<#
SQL DBAs commonly refer to SQL instances as the HOSTNAME (for a default instance of MSSQLSERVER)
or HOSTNAME\NAMEDINSTANCE for a named instance. This returns a hash table of Hostname and InstanceName
to simplify SQL cmdlet calls.
#>
function ConvertFrom-SqlServerInstance([string]$ServerInstance){
    if($ServerInstance.Contains('\')){
        $si = $ServerInstance.Split('\')
        $return = New-Object psobject -Property @{'hostname'= $si[0];'instancename'=$si[1]}
    } else {
        $return = New-Object psobject -Property @{'hostname'= $ServerInstance;'instancename'='MSSQLSERVER'}
    }
    return $return
}
function ConvertTo-EpochMS{
  <#  
      .SYNOPSIS
      Converts a datetime value to a epoch millisecond timestamp

      .DESCRIPTION
      Within Rubrik, recovery points are defined by a epoch millisecond timestamp. This value is
      the number of milliseconds since 1970-01-01. This function will take a datetime value and convert
      it to the epoch millisecond timestamp for use by Rubrik functions.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      https://github.com/rubrikinc/PowerShell-Module

      .EXAMPLE
      ConvertTo-EpochMS -DateTimeValue (Get-Date)
#>
[CmdletBinding()]
param(
    [DateTime]$DateTimeValue
)

    $return = (New-TimeSpan -Start ([datetime]'1970-01-01Z').ToUniversalTime() -End $DateTimeValue.ToUniversalTime()).TotalMilliseconds

    return $return

}
<#
    Helper JSON functions to resolve the ConvertFrom-JSON maxJsonLength limitation, which defaults to 2 MB
    http://stackoverflow.com/questions/16854057/convertfrom-json-max-length/27125027
#>

function ExpandPayload($response) {
<#
.SYNOPSIS
This function use the .Net JSON Serializer in order to 
#>
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Web.Extensions')
  return ParseItem -jsonItem ((New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{
        MaxJsonLength = 67108864
  }).DeserializeObject($response.Content))
}


function ParseItem($jsonItem) {
<#
.SYNOPSIS
Main function that determines the type of object and calls either ParseJsonObject or ParseJsonArray
#>
  if($jsonItem.PSObject.TypeNames -match 'Array') {
    return ParseJsonArray -jsonArray ($jsonItem)
  } elseif($jsonItem.PSObject.TypeNames -match 'Dictionary') {
    return ParseJsonObject -jsonObj ([HashTable]$jsonItem)
  } else  {
    return $jsonItem
  }
}

function ParseJsonObject($jsonObj) {
<#
.SYNOPSIS
Converts JSON to PowerShell Custom objects
#>
  $result = New-Object -TypeName PSCustomObject
  foreach ($key in $jsonObj.Keys) 
  {
    $item = $jsonObj[$key]

    if ($null -ne $item) {
      $parsedItem = ParseItem -jsonItem $item
    } else {
      $parsedItem = $null
    }

    $result | Add-Member -MemberType NoteProperty -Name $key -Value $parsedItem
  }
  return $result
}

function ParseJsonArray($jsonArray) {
<#
.SYNOPSIS
Expands the array and feeds this back into ParseItem, in case of nested arrays this might occur multiple times
#>
  $result = @()
  $jsonArray | ForEach-Object -Process {
    $result += , (ParseItem -jsonItem $_)
  }
  return $result
}
<#
    Helper function to retrieve API data from Rubrik
#>
function Get-RubrikAPIData($endpoint) {
    $api = @{
        Example                        = @{
            '1.0' = @{
                Description = 'Details about the API endpoint'
                URI         = 'The URI expressed as /api/v#/endpoint'
                Method      = 'Method to use against the endpoint'
                Body        = 'Parameters to use in the body'
                Query       = 'Parameters to use in the URI query'
                Result      = 'If the result content is stored in a higher level key, express it here to be unwrapped in the return'
                Filter      = 'If the result content needs to be filtered based on key names, express them here'
                Success     = 'The expected HTTP status code for a successful call'
            }
        }
        'Connect-Rubrik'               = @{
            '3.0' = @{
                Description = 'Create a new login session'
                URI         = '/api/v1/session'
                Method      = 'Post'
                Body        = ''
                Query       = @{
                    organization_id = 'organization_id'
                }
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Disconnect-Rubrik'            = @{
            '1.0' = @{
                Description = 'Closes a user session and invalidates the session token'
                URI         = '/api/v1/session/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Export-RubrikDatabase'        = @{
            '1.0' = @{
                Description = 'Export MSSQL Database from Rubrik to Destination Instance.'
                URI         = '/api/v1/mssql/db/{id}/export'
                Method      = 'Post'
                Body        = @{
                    targetInstanceId   = 'targetInstanceId'
                    targetDatabaseName = 'targetDatabaseName'
                    recoveryPoint      = @{
                        lsnPoint = @{lsn='lsn'}
                        timestampMs = 'timestampMs'
                    }
                    finishRecovery     = 'finishRecovery'
                    maxDataStreams     = 'maxDataStreams'
                    targetDataFilePath = 'targetDataFilePath'
                    targetLogFilePath  = 'targetLogFilePath'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Export-RubrikVM'        = @{
            '1.0' = @{
                Description = 'Export a VMware VM to an existing vSphere environment'
                URI         = '/api/v1/vmware/vm/snapshot/{id}/export'
                Method      = 'Post'
                Body        = @{
                    vmName                  = 'vmName'
                    disableNetwork          = 'disableNetwork'
                    removeNetworkDevices    = 'removeNetworkDevices'
                    powerOn                 = 'powerOn'
                    hostId                  = 'hostId'
                    datastoreId             = 'datastoreId'
                    shouldRecoverTags       = 'shouldRecoverTags'
                    keepMacAddresses        = 'keepMacAddresses'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Export-RubrikReport'          = @{
            '1.0' = @{
                Description = 'Get the link to a CSV file for a report.'
                URI         = '/api/internal/report/{id}/download_csv'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    timezone_offset = 'timezone_offset'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
            '4.1' = @{
                Description = 'Get the link to a CSV file for a report.'
                URI         = '/api/internal/report/{id}/csv_link'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    timezone_offset = 'timezone_offset'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikAPIToken'         = @{
            '5.0' = @{
                Description = 'Retrieves list of generated API tokens from the Rubrik cluster'
                URI         = '/api/internal/session'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    user_id     = 'user_id'
                }
                Result      = 'data'
                Filter      = @{
                    'tag'               = 'tag'
                    'organizationId'    = 'organizationId'
                }
                Success     = '200'
            }
        }       
        'Get-RubrikAPIVersion'         = @{
            '1.0' = @{
                Description = 'Retrieves software version of the Rubrik cluster'
                URI         = '/api/v1/cluster/{id}/api_version'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'apiVersion'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikAvailabilityGroup' = @{
            '1.0' = @{
                Description = 'Get summary information for Microsoft SQL availability groups'
                URI         = '/api/internal/mssql/availability_group'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_database_id     = 'primary_database_id'
                }
                Result      = 'data'
                Filter      = @{
                    'GroupName'     = 'name'
                    'SLA'      = 'effectiveSlaDomainName'
                    'SLAID'    = 'effectiveSlaDomainId'
                }
                Success     = '200'
            }
        }
        'Get-RubrikDatabase'           = @{
            '1.0' = @{
                Description = 'Returns a list of summary information for Microsoft SQL databases.'
                URI         = '/api/v1/mssql/db'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    instance_id             = 'instance_id'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    primary_cluster_id      = 'primary_cluster_id'
                    is_relic                = 'is_relic'
                }
                Result      = 'data'
                Filter      = @{
                    'Name'     = 'name'
                    'SLA'      = 'effectiveSlaDomainName'
                    'Hostname' = 'rootProperties.rootName'
                    'Instance' = 'instanceName'
                }
                Success     = '200'
            }
        }
        'Get-RubrikDatabaseFiles'      = @{
            '1.0' = @{
                Description = 'Returns a list of files for the database.'
                URI         = '/api/internal/mssql/db/{id}/restore_files'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    time = 'time'
                }
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikDatabaseMount'      = @{
            '1.0' = @{
                Description = 'Retrieve information for all live mounts for databases'
                URI         = '/api/v1/mssql/db/mount'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    source_database_id    = 'source_database_id'
                    source_database_name  = 'source_database_name'
                    target_instance_id    = 'target_instance_id'
                    mounted_database_name = 'mounted_database_name'
                    offset                = 'offset'
                    limit                 = 'limit'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikDatabaseRecoverableRange'           = @{
            '1.0' = @{
                Description = 'Returns a list of summary information for Microsoft SQL databases.'
                URI         = '/api/v1/mssql/db/{id}/recoverable_range'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    before_time = 'before_time'
                    after_time = 'after_time'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikEvent'               = @{
            '1.0' = @{
                Description = 'Retrieve information for the latest of related events that match the value specified in any of the following categories: type, status, or ID, and limit events by date.'
                URI         = '/api/internal/event'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    limit = 'limit'
                    after_id = 'after_id'
                    event_series_id = 'event_series_id'
                    status = 'status'
                    event_type = 'event_type'
                    object_ids = 'object_ids'
                    object_name = 'object_name'
                    before_date = 'before_date'
                    after_date = 'after_date'
                    object_type = 'object_type'
                    show_only_latest = 'show_only_latest'
                    filter_only_on_latest = 'filter_only_on_latest'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikFileset'            = @{
            '1.0' = @{
                Description = 'Retrieve summary information for each fileset. Optionally, filter the retrieved information.'
                URI         = '/api/v1/fileset'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_cluster_id      = 'primary_cluster_id'
                    host_id                 = 'host_id'
                    is_relic                = 'is_relic'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    template_id             = 'template_id'
                    limit                   = 'limit'
                    offset                  = 'offset'
                    cached                  = 'cached'
                    name                    = 'name'
                    host_name               = 'host_name'
                    share_id                = 'share_id'
                }
                Result      = 'data'
                Filter      = @{
                    'SLA' = 'effectiveSlaDomainName'
                }
                Success     = '200'
            }
        }
        'Get-RubrikFilesetTemplate'    = @{
            '1.0' = @{
                Description = 'Retrieve summary information for all fileset templates, including: ID and name of the fileset template, fileset template creation timestamp, array of the included filepaths, array of the excluded filepaths.'
                Function    = 'Get-RubrikFilesetTemplate'
                URI         = '/api/v1/fileset_template'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_cluster_id    = 'primary_cluster_id'
                    operating_system_type = 'operating_system_type'
                    name                  = 'name'
                    share_type            = 'share_type'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikHost'               = @{
            '1.0' = @{
                Description = 'Retrieve summary information for all hosts that are registered with a Rubrik cluster'
                URI         = '/api/v1/host'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    operating_system_type = 'operating_system_type'
                    primary_cluster_id    = 'primary_cluster_id'
                    hostname              = 'hostname'
                    name                  = 'name'
                }
                Result      = 'data'
                Filter      = @{
                    Name            = 'name'
                }
                Success     = '200'
            }
        }
        'Get-RubrikHyperVVM'                 = @{
            '1.0' = @{
                Description = 'Get summary of all HyperV VMs'
                URI         = '/api/internal/hyperv/vm'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    is_relic                = 'is_relic'
                    name                    = 'name'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    sla_assignment          = 'sla_assignment'
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                    'SLA'  = 'effectiveSlaDomainName'
                }
                Success     = '200'
            }
        }
        'Get-RubrikLDAP'         = @{
            '1.0' = @{
                Description = 'Retrieves all LDAP settings of the Rubrik cluster'
                URI         = '/api/v1/ldap_service'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = @{
                    DomainType = 'domainType'
                    ID = 'id'
                    InitialRefreshStatus = 'initialRefreshStatus'
                    Name = 'name'
                }
                Success     = '200'
            }
        }
        'Get-RubrikManagedVolume'           = @{
            '1.0' = @{
                Description = 'Returns a list of summary information for Rubrik Managed Volumes'
                URI         = '/api/internal/managed_volume'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    primary_cluster_id      = 'primary_cluster_id'
                    is_relic                = 'is_relic'
                }
                Result      = 'data'
                Filter      = @{
                    'Name'     = 'name'
                    'SLA'      = 'effectiveSlaDomainName'
                }
                Success     = '200'
            }
        }
        'Get-RubrikManagedVolumeExport'           = @{
            '1.0' = @{
                Description = 'Returns a list of summary information for Rubrik Managed Volume Exports'
                URI         = '/api/internal/managed_volume/snapshot/export'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    source_managed_volume_id = 'source_managed_volume_id'
                    source_managed_volume_name = 'source_managed_volume_name'
                }
                Result      = 'data'
                Filter      = @{
                    SourceManagedVolumeID = 'SourceManagedVolumeID'
                    SourceManagedVolumeName = 'SourceManagedVolumeName'
                }
                Success     = '200'
            }
        }
        'Get-RubrikMount'              = @{
            '1.0' = @{
                Description = 'Retrieve information for all live mounts'
                URI         = '/api/v1/vmware/vm/snapshot/mount'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    vm_id  = 'vm_id'
                    offset = 'offset'
                    limit  = 'limit'
                }
                Result      = 'data'
                Filter      = @{
                    id = 'id'
                    vmId = 'vmId'    
                }
                Success     = '200'
            }
        }
        'Get-RubrikNASShare'              = @{
            '1.0' = @{
                Description = 'Retrieve information NAS Shares'
                URI         = '/api/internal/host/share'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    host_id  = 'host_id'
                    share_type = 'share_type'
                    primary_cluster_id  = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    hostName = 'hostName'
                    exportPoint = 'exportPoint'
                }
                Success     = '200'
            }
        }
        'Get-RubrikNutanixVM'                 = @{
            '1.0' = @{
                Description = 'Get summary of all Nutanix VMs'
                URI         = '/api/internal/nutanix/vm'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    is_relic                = 'is_relic'
                    name                    = 'name'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    sla_assignment          = 'sla_assignment'
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                    'SLA'  = 'effectiveSlaDomainName'
                }
                Success     = '200'
            }
        }
        'Get-RubrikOracleDB'                = @{
            '1.0' = @{
                Description = 'Get summary of all the Oracle DBs'
                URI         = '/api/internal/oracle/db'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    is_relic                = 'is_relic'
                    is_live_mount           = 'is_live_mount'
                    name                    = 'name'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    sla_assignment          = 'sla_assignment'
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                    'SLA'  = 'effectiveSlaDomainName'
                }
                Success     = '200'
            }
        }        
        'Get-RubrikOrganization'                 = @{
            '1.0' = @{
                Description = 'Get summary of all Rubrik organizations'
                URI         = '/api/internal/organization'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    is_global                = 'is_global'
                    name                     = 'name'
                }
                Result      = 'data'
                Filter      = @{
                    'name' = 'name'
                }
                Success     = '200'
            }
        }
        'Get-RubrikReport'             = @{
            '1.0' = @{
                Description = 'Retrieve summary information for each report.'
                URI         = '/api/internal/report'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    report_type = 'report_type'
                    search_text = 'search_text'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
            '4.1' = @{
                Description = 'Retrieve summary information for each report.'
                URI         = '/api/internal/report'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    report_type = 'report_type'
                    search_text = 'name'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikReportData'         = @{
            '1.0' = @{
                Description = 'Retrieve table data for a specific report'
                URI         = '/api/internal/report/{id}/table'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    search_value      = 'search_value'
                    sla_domain_id     = 'sla_domain_id'
                    task_type         = 'task_type'
                    task_status       = 'task_status'
                    object_type       = 'object_type'
                    compliance_status = 'compliance_status'
                    cluster_location  = 'cluster_location'
                }
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
            '4.1' = @{
                Description = 'Retrieve table data for a specific report'
                URI         = '/api/internal/report/{id}/table'
                Method      = 'Post'
                Body        = @{
                    limit          = 'limit'
                    sortBy         = 'sortBy'
                    sortOrder      = 'sortOrder'
                    search_value   = 'objectName'
                    cursor         = 'cursor'
                    requestFilters = @{
                        sla_domain_id     = 'slaDomain'
                        task_type         = 'taskType'
                        task_status       = 'taskStatus'
                        object_type       = 'objectType'
                        compliance_status = 'complianceStatus'
                        cluster_location  = 'clusterLocation'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikRequest'            = @{
            '1.0' = @{
                Description = 'Get details about an async request.'
                URI         = '/api/v1/{type}/request/{id}'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikSetting'         = @{
            '1.0' = @{
                Description = 'Retrieves all settings of the Rubrik cluster'
                URI         = '/api/v1/cluster/{id}'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'settings'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikSLA'                = @{
            '1.0' = @{
                Description = 'Retrieve summary information for all SLA Domains'
                URI         = '/api/v1/sla_domain'
                Method      = 'Get'
                Body        = 'Parameters to use in the body'
                Query       = @{
                    primary_cluster_id = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                }
                Success     = '200'
            }
            '5.0' = @{
                Description = 'Retrieve summary information for all SLA Domains'
                URI         = '/api/v2/sla_domain'
                Method      = 'Get'
                Body        = 'Parameters to use in the body'
                Query       = @{
                    primary_cluster_id = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                }
                Success     = '200'
            }
        }
        'Get-RubrikSnapshot'           = @{
            '1.0' = @{
                Description = 'Retrieve information for all snapshots'
                URI         = @{
                    Fileset = '/api/v1/fileset/{id}/snapshot'
                    MSSQL   = '/api/v1/mssql/db/{id}/snapshot'
                    VMware  = '/api/v1/vmware/vm/{id}/snapshot'
                    HyperV  = '/api/internal/hyperv/vm/{id}/snapshot'
                    ManagedVolume = '/api/internal/managed_volume/{id}/snapshot'
                    Nutanix = '/api/internal/nutanix/vm/{id}/snapshot'
                    VolumeGroup = '/api/internal/volume_group/{id}/snapshot'
                    Oracle = '/api/internal/oracle/db/{id}/snapshot'
                }
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'data'
                Filter      = @{
                    'CloudState'       = 'cloudState'
                    'OnDemandSnapshot' = 'isOnDemandSnapshot'
                }
                Success     = '200'
            }
        }
        'Get-RubrikSoftwareVersion'    = @{
            '1.0' = @{
                Description = 'Retrieves software version of the Rubrik cluster'
                URI         = '/api/v1/cluster/{id}/version'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = 'version'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikSQLInstance'        = @{
            '1.0' = @{
                Description = 'Returns a list of summary information for Microsoft SQL instances.'
                URI         = '/api/v1/mssql/instance'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    instance_id = 'instance_id'
                    primary_cluster_id = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name'     = 'name'
                    'SLA'      = 'configuredSlaDomainName'
                    'Hostname' = 'rootProperties.rootName'
                }
                Success     = '200'
            }
        }
        'Get-RubrikSupportTunnel'      = @{
            '1.0' = @{
                Description = 'To be used by Admin to check status of the support tunnel.'
                URI         = '/api/internal/node/me/support_tunnel'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikUnmanagedObject'    = @{
            '1.0' = @{
                Description = 'Get summary of all the objects with unmanaged snapshots'
                URI         = '/api/internal/unmanaged_object'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    search_value     = 'search_value'
                    unmanaged_status = 'unmanaged_status'
                    object_type      = 'object_type'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
       'Get-RubrikVCenter'         = @{
            '1.0' = @{
                Description = 'Retrieves all vCenter settings of the Rubrik cluster'
                URI         = '/api/v1/vmware/vcenter'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      =  @{
                    'Name' = 'name'
                }
                Success     = '200'
            }
        }
        'Get-RubrikVMwareDatastore'         = @{
            '1.0' = @{
                Description = 'Retrieves all datastores known to the Rubrik cluster'
                URI         = '/api/internal/vmware/datastore'
                Method      = 'Get'
                Body        = ''
                Query       = @{}
                Result      = 'data'
                Filter      =  @{
                    'Name' = 'name'
                    'dataStoreType' = 'dataStoreType'
                }
                Success     = '200'
            }
        }
        'Get-RubrikVMwareHost'         = @{
            '1.0' = @{
                Description = 'Retrieves all ESXi hosts known to the Rubrik cluster'
                URI         = '/api/v1/vmware/host'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      =  @{
                    'Name' = 'name'
                }
                Success     = '200'
            }
        }
        'Get-RubrikVersion'            = @{
            '1.0' = @{
                Description = 'Retrieve public information about the Rubrik cluster'
                URI         = '/api/v1/cluster/{id}'
                Method      = 'Get'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikVM'                 = @{
            '1.0' = @{
                Description = 'Get summary of all the VMs'
                URI         = '/api/v1/vmware/vm'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    is_relic                = 'is_relic'
                    name                    = 'name'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    sla_assignment          = 'sla_assignment'
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                    'SLA'  = 'effectiveSlaDomainName'
                }
                Success     = '200'
            }
        }
        'Get-RubrikVolumeGroup'                 = @{
            '1.0' = @{
                Description = 'Get summary of all Volume Groups'
                URI         = '/api/internal/volume_group'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    is_relic                = 'is_relic'
                    name                    = 'name'
                    hostname                = 'hostname'
                    effective_sla_domain_id = 'effective_sla_domain_id'
                    sla_assignment          = 'sla_assignment'
                    primary_cluster_id      = 'primary_cluster_id'
                }
                Result      = 'data'
                Filter      = @{
                    'Name' = 'name'
                    'SLA'  = 'effectiveSlaDomainName'
                }
                Success     = '200'
            }
        }
        'Get-RubrikVolumeGroupMount'                 = @{
            '1.0' = @{
                Description = 'Retrieve information for all Volume mounts'
                URI         = '/api/internal/volume_group/snapshot/mount'
                Method      = 'Get'
                Body        = ''
                Query           = @{
                    id          = 'source_volume_group_id'
                    source_host = 'source_host_name'
                    offset      = 'offset'
                    limit       = 'limit'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Get-RubrikVMSnapshot'                = @{
            '1.0' = @{
                Description = 'Retrieve information of a VM snapshot'
                URI         = '/api/v1/vmware/vm/snapshot/{id}'
                Method      = 'Get'
                Body        = ''
                Query           = @{
                    id          = 'id'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'New-RubrikVCenter'      = @{
            '1.0' = @{
                Description = 'Create VMware vCenter connection'
                URI         = '/api/v1/vmware/vcenter'
                Method      = 'Post'
                Body        = @{
                    hostname = "hostname"
                    username = "username"
                    password = "password"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikVMDKMount'      = @{
            '1.0' = @{
                Description = 'Create a VMDK mount request with given configuration'
                URI         = '/api/internal/vmware/vm/snapshot/{id}/mount_disks'
                Method      = 'Post'
                Body        = @{
                    targetVmId          = 'targetVmId'
                    vmdkIds             = @{}
                    vlan                    = 'vlan'
                    createNewScsiController = 'createNewScsiController'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikVolumeGroupMount'      = @{
            '1.0' = @{
                Description = 'Create a Volume Group mount request with given configuration'
                URI         = '/api/internal/volume_group/snapshot/{id}/mount'
                Method      = 'Post'
                Body        = @{
                    targetHostId              = 'targetHostId'
                    smbValidUsers             = 'smbValidUsers'
                    volumeConfigs             = @{
                        volumeId              = 'volumeId'
                        mountPointOnHost      = 'mountPointOnHost'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Remove-RubrikVolumeGroupMount'           = @{
            '1.0' = @{
                Description = 'Create a request to delete a mounted Volume Group'
                URI         = '/api/internal/volume_group/snapshot/mount/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = @{
                    force = 'force'
                }
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'New-RubrikAPIToken'      = @{
            '5.0' = @{
                Description = 'Create an API Token'
                URI         = '/api/internal/session'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = 'session'
                Filter      = ''
                Success     = '200'
            }
        }
        'New-RubrikDatabaseMount'      = @{
            '1.0' = @{
                Description = 'Create a live mount request with given configuration'
                URI         = '/api/v1/mssql/db/{id}/mount'
                Method      = 'Post'
                Body        = @{
                    targetInstanceId    = 'targetInstanceId'
                    mountedDatabaseName = 'mountedDatabaseName'
                    recoveryPoint       = @{
                        timestampMs = 'timestampMs'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikFileSet'      = @{
            '1.0' = @{
                Description = 'Create a fileset using an existing template along with a host or share'
                URI         = '/api/v1/fileset'
                Method      = 'Post'
                Body        = @{
                    hostId    = 'hostId'
                    shareId = 'shareId'
                    templateId = 'templateId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikFileSetTemplate'      = @{
            '1.0' = @{
                Description = 'Create a new fileset template for fileset backups'
                URI         = '/api/v1/fileset_template'
                Method      = 'Post'
                Body        = @{
                    allowBackupNetworkMounts = 'allowBackupNetworkMounts'
                    allowBackupHiddenFoldersInNetworkMounts = 'allowBackupHiddenFoldersInNetworkMounts'
                    useWindowsVss = 'useWindowsVss'
                    name = 'name'
                    includes = 'includes'
                    excludes = 'excludes'
                    exceptions = 'exceptions'
                    operatingSystemType = 'operatingSystemType'
                    shareType = 'shareType'
                    preBackupScript = 'preBackupScript'
                    postBackupScript = 'postBackupScript'
                    backupScriptTimeout = 'backupScriptTimeout'
                    backupScriptErrorHandling = 'backupScriptErrorHandling'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikHost'               = @{
            '1.0' = @{
                Description = 'Register a host'
                URI         = '/api/v1/host'
                Method      = 'Post'
                Body        = @{
                    hostname = 'hostname'
                    hasAgent = 'hasAgent'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'New-RubrikLDAP'         = @{
            '1.0' = @{
                Description = 'Creates new LDAP server connection on the Rubrik cluster'
                URI         = '/api/v1/ldap_service'
                Method      = 'Post'
                Body        = @{
                    name = "name"
                    dynamicDnsName = "dynamicDnsName"
                    bindUserName = "bindUserName"
                    bindUserPassword = "bindUserPassword"
                    baseDN = "baseDN"
                    authServers = "authServers"
                    advancedOptions = "advancedOptions"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'New-RubrikLogBackup'               = @{
            '1.0' = @{
                Description = 'Takes on demand transaction log backup for SQL Server'
                URI         = '/api/v1/mssql/db/{id}/log_backup'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikManagedVolume' = @{
            '1.0' = @{
                Description = 'Create a new managed volume'
                URI         = '/api/internal/managed_volume'
                Method      = 'Post'
                Body        = @{
                    name = 'name'
                    numChannels = 'numChannels'
                    subnet = 'subnet'
                    volumeSize =  'volumeSize'
                    applicationTag = 'applicationTag'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'New-RubrikManagedVolumeExport'        = @{
            '1.0' = @{
                Description = 'Create a Managed Volume export.'
                URI         = '/api/internal/managed_volume/snapshot/{id}/export'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikMount'              = @{
            '1.0' = @{
                Description = 'Create a live mount request with given configuration'
                URI         = '/api/v1/vmware/vm/snapshot/{id}/mount'
                Method      = 'Post'
                Body        = @{
                    hostId               = 'hostId'
                    vmName               = 'vmName'
                    dataStoreName        = 'dataStoreName'
                    disableNetwork       = 'disableNetwork'
                    removeNetworkDevices = 'removeNetworkDevices'
                    powerOn              = 'powerOn'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikNASShare'              = @{
            '1.0' = @{
                Description = 'Create a new NAS share on an existing host'
                URI         = '/api/internal/host/share'
                Method      = 'Post'
                Body        = @{
                    hostId      = 'hostId'
                    shareType   = 'shareType'
                    exportPoint = 'exportPoint'
                    username    = 'username'
                    password    = 'password'
                    domain      = 'domain'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'New-RubrikReport'             = @{
            '1.0' = @{
                Description = 'Create a new report by specifying one of the report templates'
                URI         = '/api/internal/report'
                Method      = 'Post'
                Body        = @{
                    name           = 'name'
                    reportTemplate = 'reportTemplate'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'New-RubrikSLA'                = @{
            '1.0' = @{
                Description = 'Create a new SLA Domain on a Rubrik cluster by specifying Domain Rules and policies'
                URI         = '/api/v1/sla_domain'
                Method      = 'Post'
                Body        = @{
                    name        = 'name'
                    frequencies = @{
                        timeUnit  = 'timeUnit'
                        frequency = 'frequency'
                        retention = 'retention'
                    }
                    allowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    firstFullAllowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                            dayOfWeek = 'dayOfWeek'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    localRetentionLimit = 'localRetentionLimit'
                    archivalSpecs       = @{
                        locationId        = 'locationId'
                        archivalThreshold = 'archivalThreshold'
                    }
                    replicationSpecs = @{
                        locationId     = 'locationId'
                        retentionLimit = 'retentionLimit'
                    }    
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
            '5.0' = @{
                Description = 'Create a new SLA Domain on a Rubrik cluster by specifying Domain Rules and policies'
                URI         = '/api/v2/sla_domain'
                Method      = 'Post'
                Body        = @{
                    name             = 'name'
                    showAdvancedUi   = 'showAdvancedUi'
                    frequencies      = @{
                        frequency = 'frequency'
                        retention = 'retention'
                    }
                    advancedUiConfig = @{
                        timeUnit      = 'timeUnit'
                        retentionType = 'retentionType'
                    }
                    allowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    firstFullAllowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                            dayOfWeek = 'dayOfWeek'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    localRetentionLimit = 'localRetentionLimit'
                    archivalSpecs       = @{
                        locationId        = 'locationId'
                        polarisManagedId  = 'polarisManagedId'
                        archivalThreshold = 'archivalThreshold'
                    }
                    replicationSpecs = @{
                        locationId     = 'locationId'
                        retentionLimit = 'retentionLimit'
                    }    
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'New-RubrikSnapshot'           = @{
            '1.0' = @{
                Description = 'Create an on-demand snapshot for the given object ID'
                URI         = @{
                    Fileset = '/api/v1/fileset/{id}/snapshot'
                    MSSQL   = '/api/v1/mssql/db/{id}/snapshot'
                    VMware  = '/api/v1/vmware/vm/{id}/snapshot'
                    VolumeGroup = '/api/internal/volume_group/{id}/snapshot'
                    Oracle = '/api/internal/oracle/db/{id}/snapshot'
                }
                Method      = 'Post'
                Body        = @{
                    forceFullSnapshot = 'forceFullSnapshot'
                    slaId             = 'slaId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Protect-RubrikDatabase'       = @{
            '1.0' = @{
                Description = 'Update a Microsoft SQL database with the specified SLA Domain.'
                URI         = '/api/v1/mssql/db/{id}'
                Method      = 'Patch'
                Body        = @{
                    logBackupFrequencyInSeconds = 'logBackupFrequencyInSeconds'
                    logRetentionHours           = 'logRetentionHours'
                    copyOnly                    = 'copyOnly'
                    maxDataStreams              = 'maxDataStreams'
                    configuredSlaDomainId       = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Protect-RubrikFileset'        = @{
            '1.0' = @{
                Description = 'Update a Fileset with the specified SLA Domain.'
                URI         = '/api/v1/fileset/{id}'
                Method      = 'Patch'
                Body        = @{
                    configuredSlaDomainId = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'Protect-RubrikHyperVVM'             = @{
            '1.0' = @{
                Description = 'Update a VM with the specified SLA Domain.'
                URI         = '/api/internal/hyperv/vm/{id}'
                Method      = 'Patch'
                Body        = @{
                    configuredSlaDomainId = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Protect-RubrikNutanixVM'             = @{
            '1.0' = @{
                Description = 'Update a VM with the specified SLA Domain.'
                URI         = '/api/internal/nutanix/vm/{id}'
                Method      = 'Patch'
                Body        = @{
                    configuredSlaDomainId = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Protect-RubrikTag'            = @{
            '1.0' = @{
                Description = 'Assign managed entities to the specified SLA Domain. The assignment event runs synchronously.'
                URI         = '/api/internal/sla_domain/{id}/assign'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Protect-RubrikVM'             = @{
            '1.0' = @{
                Description = 'Update a VM with the specified SLA Domain.'
                URI         = '/api/v1/vmware/vm/{id}'
                Method      = 'Patch'
                Body        = @{
                    configuredSlaDomainId = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Update-RubrikHost'             = @{
            '1.0' = @{
                Description = 'Refresh the properties of a host object when changes on the host are not seen in the Rubrik web UI.'
                URI         = '/api/v1/host/{id}/refresh'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Register-RubrikBackupService'                  = @{
            '1.0' = @{
                Description = 'Register the Rubrik Backup Service.'
                URI         = @{
                    VMware  = '/api/v1/vmware/vm/{id}/register_agent'
                    HyperV  = '/api/internal/hyperv/vm/{id}/register_agent'
                    Nutanix = '/api/internal/nutanix/vm/{id}/register_agent'
                }
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            } 
        }
        'Remove-RubrikAPIToken'   = @{
            '5.0' = @{
                Description = 'Deletes session tokens'
                URI         = '/api/internal/session/bulk_delete'
                Method      = 'Post'
                Body        = @{
                    tokenIds = 'tokenIds'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikDatabaseMount'   = @{
            '1.0' = @{
                Description = 'Create a request to delete a database live mount'
                URI         = '/api/v1/mssql/db/mount/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = @{
                    force = 'force'
                }
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Remove-RubrikFileset'         = @{
            '1.0' = @{
                Description = 'Delete a fileset by specifying the fileset ID'
                URI         = '/api/v1/fileset/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikHost'            = @{
            '1.0' = @{
                Description = 'Delete host by specifying the host ID'
                URI         = '/api/v1/host/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikManagedVolume'            = @{
            '1.0' = @{
                Description = 'Delete a managed volume'
                URI         = '/api/internal/managed_volume/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikManagedVolumeExport'            = @{
            '1.0' = @{
                Description = 'Delete a managed volume'
                URI         = '/api/internal/managed_volume/snapshot/export/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikMount'           = @{
            '1.0' = @{
                Description = 'Create a request to delete a live mount'
                URI         = '/api/v1/vmware/vm/snapshot/mount/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = @{
                    force = 'force'
                }
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Remove-RubrikNASShare'           = @{
            '1.0' = @{
                Description = 'Create a request to delete a NAS share'
                URI         = '/api/internal/host/share/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Remove-RubrikReport'          = @{
            '1.0' = @{
                Description = 'Delete a specific report specified by reportId'
                URI         = '/api/internal/report/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikSLA'             = @{
            '1.0' = @{
                Description = 'Delete an SLA Domain from a Rubrik cluster'
                URI         = '/api/v1/sla_domain/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
            '5.0' = @{
                Description = 'Delete an SLA Domain from a Rubrik cluster'
                URI         = '/api/v2/sla_domain/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikVMSnapshot'        = @{
            '1.0' = @{
                Description = 'Removes an expired VM snapshot available for garbage collection'
                URI         = '/api/v1/vmware/vm/snapshot/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = @{
                    location = 'location'
                }
                Result      = ''
                Success     = '204'
            }
        }
        'Remove-RubrikUnmanagedObject' = @{
            '1.0' = @{
                Description = 'Bulk delete all unmanaged snapshots for the objects specified by objectId/objectType pairings.'
                URI         = '/api/internal/unmanaged_object/snapshot/bulk_delete'
                Method      = 'Post'
                Body        = @{
                    objectDefinitions = @(
                        @{
                            objectId   = 'objectId'
                            objectType = 'objectType'
                        }
                    )
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Remove-RubrikVCenter'         = @{
            '1.0' = @{
                Description = 'Removes a vCenter connection'
                URI         = '/api/v1/vmware/vcenter/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Restore-RubrikDatabase'       = @{
            '1.0' = @{
                Description = 'Export MSSQL Database from Rubrik to Destination Instance.'
                URI         = '/api/v1/mssql/db/{id}/restore'
                Method      = 'Post'
                Body        = @{
                    recoveryPoint      = @{
                        lsnPoint = @{lsn='lsn'}
                        timestampMs = 'timestampMs'
                    }
                    finishRecovery = 'finishRecovery'
                    maxDataStreams = 'maxDataStreams'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Set-RubrikAvailabilityGroup'           = @{
            '1.0' = @{
                Description = 'Update a Microsoft SQL availability group.'
                URI         = '/api/internal/mssql/availability_group/{id}'
                Method      = 'Patch'
                Body        = @{
                    logBackupFrequencyInSeconds = 'logBackupFrequencyInSeconds'
                    logRetentionHours           = 'logRetentionHours'
                    copyOnly                    = 'copyOnly'
                    configuredSlaDomainId       = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikBlackout'           = @{
            '1.0' = @{
                Description = 'Whether to start or stop the global blackout window.'
                URI         = '/api/internal/blackout_window'
                Method      = 'Patch'
                Body        = @{
                    isGlobalBlackoutActive = 'isGlobalBlackoutActive'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikDatabase'           = @{
            '1.0' = @{
                Description = 'Updates Rubrik database settings.'
                URI         = '/api/v1/mssql/db/{id}'
                Method      = 'Patch'
                Body        = @{
                    logBackupFrequencyInSeconds = "logBackupFrequencyInSeconds"
                    logRetentionHours           = "logRetentionHours"
                    copyOnly                    = "copyOnly"
                    maxDataStreams              = "maxDataStreams"
                    configuredSlaDomainId       = "configuredSlaDomainId"
                    preBackupScript             = @{
                        scriptPath              = "scriptPath"
                        timeoutMs               = "timeoutMs"
                        scriptErrorAction       = "scriptErrorAction"
                    }
                    postBackupScript            = @{
                        scriptPath              = "scriptPath"
                        timeoutMs               = "timeoutMs"
                        scriptErrorAction       = "scriptErrorAction"
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikHyperVVM'                 = @{
            '1.0' = @{
                Description = 'Update VM with specified properties'
                URI         = '/api/internal/hyperv/vm/{id}'
                Method      = 'Patch'
                Body        = @{
                    cloudInstantiationSpec = @{
                        imageRetentionInSeconds = 'imageRetentionInSeconds'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikLDAP'         = @{
            '1.0' = @{
                Description = 'Updates all settings of the Rubrik cluster'
                URI         = '/api/v1/ldap_service'
                Method      = 'Patch'
                Body        = @{
                    name = "name"
                    dynamicDnsName = "dynamicDnsName"
                    bindUserName = "bindUserName"
                    bindUserPassword = "bindUserPassword"
                    baseDN = "baseDN"
                    authServers = "authServers"
                    advancedOptions = "advancedOptions"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikManagedVolume' = @{
            '1.0' = @{
                Description = 'Update a managed volume'
                URI         = '/api/internal/managed_volume'
                Method      = 'Patch'
                Body        = @{
                    name = 'name'
                    volumeSize =  'volumeSize'
                    configuredSlaDomainId = 'configuredSlaDomainId'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'Set-RubrikMount'              = @{
            '1.0' = @{
                Description = 'Power given live-mounted vm on/off'
                URI         = '/api/v1/vmware/vm/snapshot/mount/{id}'
                Method      = 'Patch'
                Body        = @{
                    powerStatus = 'powerStatus'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikNASShare'              = @{
            '1.0' = @{
                Description = 'Power given live-mounted vm on/off'
                URI         = '/api/internal/host/share/{id}'
                Method      = 'Patch'
                Body        = @{
                    exportPoint = 'exportPoint'
                    username    = 'username'
                    password    = 'password'
                    domain      = 'domain'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikNutanixVM'                 = @{
            '1.0' = @{
                Description = 'Update VM with specified properties'
                URI         = '/api/internal/nutanix/vm/{id}'
                Method      = 'Patch'
                Body        = @{
                    snapshotConsistencyMandate = 'snapshotConsistencyMandate'
                    isPaused                 = 'isPaused'

                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikReport'             = @{
            '1.0' = @{
                Description = 'Update a specific report. The report''s name, chart parameters, filters and table can be updated. If successful, this will automatically trigger an async job to refresh the report content.'
                URI         = '/api/internal/report/{id}'
                Method      = 'Patch'
                Body        = @{
                    name    = 'name'
                    filters = @{
                        slaDomain        = 'slaDomain'
                        objects          = 'objects'
                        objectType       = 'objectType'
                        objectLocation   = 'objectLocation'
                        clusterLocation  = 'clusterLocation'
                        taskType         = 'taskType'
                        complianceStatus = 'complianceStatus'
                        dateConfig       = @{
                            beforeDate = 'beforeDate'
                            afterDate  = 'afterDate'
                            period     = 'period'
                        }
                    }
                    chart0  = @{
                        id        = 'id'
                        name      = 'name'
                        chartType = 'chartType'
                        attribute = 'attribute'
                        measure   = 'measure'
                    }
                    chart1  = @{
                        id        = 'id'
                        name      = 'name'
                        chartType = 'chartType'
                        attribute = 'attribute'
                        measure   = 'measure'
                    }
                    table   = @{
                        columns = 'columns'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikSetting'         = @{
            '1.0' = @{
                Description = 'Updates all settings of the Rubrik cluster'
                URI         = '/api/v1/cluster/{id}'
                Method      = 'Patch'
                Body        = @{
                    name = "name"
                    timezone = "timezone"
                    geolocation = "geolocation"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikSLA'             = @{
            '1.0' = @{
                Description = 'Update an existing SLA Domain on a Rubrik cluster by specifying Domain Rules and policies'
                URI         = '/api/v1/sla_domain'
                Method      = 'Patch'
                Body        = @{
                    name                 = 'name'
                    frequencies          = @{
                        timeUnit  = 'timeUnit'
                        frequency = 'frequency'
                        retention = 'retention'
                    }
                    allowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    firstFullAllowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                            dayOfWeek = 'dayOfWeek'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    localRetentionLimit = 'localRetentionLimit'
                    archivalSpecs       = @{
                        locationId        = 'locationId'
                        archivalThreshold = 'archivalThreshold'
                    }
                    replicationSpecs = @{
                        locationId     = 'locationId'
                        retentionLimit = 'retentionLimit'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
            '5.0' = @{
                Description = 'Update an existing SLA Domain on a Rubrik cluster by specifying Domain Rules and policies'
                URI         = '/api/v2/sla_domain'
                Method      = 'Patch'
                Body        = @{
                    name             = 'name'
                    showAdvancedUi   = 'showAdvancedUi'
                    frequencies      = @{
                        frequency = 'frequency'
                        retention = 'retention'
                    }
                    advancedUiConfig = @{
                        timeUnit      = 'timeUnit'
                        retentionType = 'retentionType'
                    }
                    allowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    firstFullAllowedBackupWindows = @{
                        startTimeAttributes = @{
                            minutes   = 'minutes'
                            hour      = 'hour'
                            dayOfWeek = 'dayOfWeek'
                        }
                        durationInHours  = 'durationInHours'
                    }
                    localRetentionLimit = 'localRetentionLimit'
                    archivalSpecs       = @{
                        locationId        = 'locationId'
                        polarisManagedId  = 'polarisManagedId'
                        archivalThreshold = 'archivalThreshold'
                    }
                    replicationSpecs = @{
                        locationId     = 'locationId'
                        retentionLimit = 'retentionLimit'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikSQLInstance'        = @{
            '1.0' = @{
                Description = 'Updates Rubrik database settings.'
                URI         = '/api/v1/mssql/instance/{id}'
                Method      = 'Patch'
                Body        = @{
                    logBackupFrequencyInSeconds = "logBackupFrequencyInSeconds"
                    logRetentionHours           = "logRetentionHours"
                    copyOnly                    = "copyOnly"
                    maxDataStreams              = "maxDataStreams"
                    configuredSlaDomainId       = "configuredSlaDomainId"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikSupportTunnel'      = @{
            '1.0' = @{
                Description = 'To be used by Admin to open or close a SSH tunnel for support.'
                URI         = '/api/internal/node/me/support_tunnel'
                Method      = 'Patch'
                Body        = @{
                    isTunnelEnabled            = "isTunnelEnabled"
                    inactivityTimeoutInSeconds = "inactivityTimeoutInSeconds"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikVM'                 = @{
            '1.0' = @{
                Description = 'Update VM with specified properties'
                URI         = '/api/v1/vmware/vm/{id}'
                Method      = 'Patch'
                Body        = @{
                    snapshotConsistencyMandate = 'snapshotConsistencyMandate'
                    maxNestedVsphereSnapshots  = 'maxNestedVsphereSnapshots'
                    isVmPaused                 = 'isVmPaused'
                    preBackupScript            = @{
                        scriptPath      = 'scriptPath'
                        timeoutMs       = 'timeoutMs'
                        failureHandling = 'failureHandling'
                    }
                    postSnapScript             = @{
                        scriptPath      = 'scriptPath'
                        timeoutMs       = 'timeoutMs'
                        failureHandling = 'failureHandling'
                    }
                    postBackupScript           = @{
                        scriptPath      = 'scriptPath'
                        timeoutMs       = 'timeoutMs'
                        failureHandling = 'failureHandling'
                    }
                    isArrayIntegrationEnabled  = 'isArrayIntegrationEnabled'
                    cloudInstantiationSpec = @{
                        imageRetentionInSeconds = 'imageRetentionInSeconds'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikVCenter'         = @{
            '1.0' = @{
                Description = 'Updates settings of a vCenter connection'
                URI         = '/api/v1/vmware/vcenter/{id}'
                Method      = 'Put'
                Body        = @{
                    hostname = "hostname"
                    username = "username"
                    password = "password"
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Set-RubrikVolumeFilterDriver'      = @{
            '1.0' = @{
                Description = 'Installs or Uninstalls the Rubrik Volume Filter Driver'
                URI         = '/api/internal/host/bulk/volume_filter_driver'
                Method      = 'Post'
                Body        = @{
                    hostIds = 'hostIds'
                    install = 'install'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
            '5.0' = @{
                Description = 'Installs or Uninstalls the Rubrik Volume Filter Driver'
                URI         = '/api/internal/host/bulk/volume_filter_driver'
                Method      = 'Post'
                Body        = @{
                    hostIds = 'hostIds'
                    install = 'install'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'Start-RubrikManagedVolumeSnapshot' = @{
            '1.0' = @{
                Description = 'Open a Rubrik Managed Volume for read/write'
                URI         = '/api/internal/managed_volume/{id}/begin_snapshot'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'Stop-RubrikManagedVolumeSnapshot' = @{
            '1.0' = @{
                Description = 'Close a Rubrik Managed Volume for read/write'
                URI         = '/api/internal/managed_volume/{id}/end_snapshot'
                Method      = 'Post'
                Body        = @{
                    retentionConfig  = @{
                        slaID = 'slaID'
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '201'
            }
        }
        'Get-RubrikLogShipping' = @{
            '1.0' = @{
                Description = 'Retrieves all log shipping configuration objects. Results can be filtered and sorted'
                URI         = '/api/v1/mssql/db/log_shipping'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    primary_database_id     = 'primary_database_id'
                    primary_database_name   = 'primary_database_name'
                    secondary_database_name = 'secondary_database_name'
                    location                = 'location'
                    status                  = 'status'
                    limit                   = 'limit'
                    offset                  = 'offset'
                    sort_by                 = 'sort_by'
                    sort_order              = 'sort_order'
                }
                Result      = 'data'
                Filter      = ''
                Success     = '200'
            }
        }
        'New-RubrikLogShipping' = @{
                '1.0' = @{
                    Description = 'Create a log shipping configuration'
                    URI         = '/api/v1/mssql/db/{id}/log_shipping'
                    Method      = 'Post'
                    Body        = @{
                        state                             = 'state'
                        shouldDisconnectStandbyUsers      = 'shouldDisconnectStandbyUsers'
                        maxDataStreams                    = 'maxDataStreams'
                        targetDatabaseName                = 'targetDatabaseName'
                        targetDataFilePath                = 'targetDataFilePath'
                        targetFilePaths = @{
                            logicalName       = 'logicalName'
                            exportPath        = 'exportPath'
                            newLogicalName    = 'newLogicalName'
                            newFilename       = 'newFilename'
                        }
                        targetInstanceId                  = 'targetInstanceId'
                        targetLogFilePath                 = 'targetLogFilePath'
                    }
                    Result      = ''
                    Filter      = ''
                    Success     = '202'
                }
        }
        'Remove-RubrikLogShipping' = @{
            '1.0' = @{
                Description = 'Delete a specified log shipping configuration'
                URI         = '/api/v1/mssql/db/log_shipping/{id}'
                Method      = 'Delete'
                Body        = ''
                Query       = @{
                    delete_secondary_database = 'delete_secondary_database'
                }
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Set-RubrikLogShipping' = @{
            '1.0' = @{
                Description = 'Update a specified log shipping configuration'
                URI         = '/api/v1/mssql/db/log_shipping/{id}'
                Method      = 'Patch'
                Body        = @{
                    state = 'state'
                    shouldDisconnectStandbyUsers = 'shouldDisconnectStandbyUsers'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Reset-RubrikLogShipping' = @{
            '1.0' = @{
                Description = 'Reseed a secondary database'
                URI         = '/api/v1/mssql/db/log_shipping/{id}/reseed'
                Method      = 'Post'
                Body        = @{
                    state = 'state'
                    shouldDisconnectStandbyUsers = 'shouldDisconnectStandbyUsers'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Update-RubrikVCenter'         = @{
            '1.0' = @{
                Description = 'Refresh the metadata for the specified vCenter Server'
                URI         = '/api/v1/vmware/vcenter/{id}/refresh'
                Method      = 'Post'
                Body        = ''
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
        'Update-RubrikVMwareVM'         = @{
            '1.0' = @{
                Description = 'Refresh the metadata for the specified VMware VM'
                URI         = '/api/internal/vmware/vcenter/{id}/refresh_vm'
                Method      = 'Post'
                Body        = @{
                    vmMoid = 'vmMoid'
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '204'
            }
        }
        'Get-RubrikBootStrap'         = @{
            '1.0' = @{
                Description = 'Status of the bootstrap request'
                URI         = '/api/internal/cluster/{id}/bootstrap'
                Method      = 'Get'
                Body        = ''
                Query       = @{
                    request_id    = 'request_id'
                }
                Result      = ''
                Filter      = ''
                Success     = '200'
            }
        }
        'New-RubrikBootStrap'      = @{
            '1.0' = @{
                Description = 'New Bootstrap Request'
                URI         = '/api/internal/cluster/{id}/bootstrap'
                Method      = 'Post'
                Body        = @{
                    name   = 'name'
                    dnsNameservers = 'dnsNameservers'
                    dnsSearchDomains = 'dnsSearchDomains'
                    ntpServerConfigs      = @{
                        server = 'ntpServerConfigs'
                    }
                    enableSoftwareEncryptionAtRest = 'enableSoftwareEncryptionAtRest'
                    adminUserInfo      = @{
                        emailAddress = 'emailAddress'
                        id = 'id'
                        password = 'password'
                    }
                    #change to a foreach loop and accept object
                    #needs to be depth 3 to work
                    nodeConfigs      = @{
                        node1      = @{
                            managementIpConfig      = @{
                            address = 'address'
                            gateway = 'management_gateway'
                            netmask = 'management_netmask'
                            }
                        }
                    }
                }
                Query       = ''
                Result      = ''
                Filter      = ''
                Success     = '202'
            }
        }
    } # End of API

    # Determine which version of RCDM is running
    # Note: Disregard for Software and API version; these do not require authentication
    if ($endpoint -eq 'Get-RubrikSoftwareVersion' -or $endpoint -eq 'Get-RubrikAPIVersion') {$key = '1.0'}

    else {
        # Take the first three values (major.minor) and convert to a float
        # If there is no version yet, we're probably connecting to the cluster for the first time (Connect-Rubrik)
        if (!$global:RubrikConnection.version) {
            $ver = [float](Get-RubrikSoftwareVersion -Server $Server).substring(0, 3)
        }
        # If there is a stored version, we'll use that to avoid more traffic to the cluster
        else {
            $ver = [float]$global:RubrikConnection.version.substring(0, 3)
        }
        # Parse through the keys to find a match (less or equal), pick the last one in the case of an array of values
        # Example: We're using RCDM 4.0 and an endpoint has details for 1.0 and 4.0. Both are less/equal to 4.0. We'll want the last value (4.0).
        # Example: We're using RCDM 4.0 and an endpoint has details for 1.0 and 4.1. 4.1 is not less/equal to 4.0, as such, we'll want the only matching value (1.0).
        $key = $api.$endpoint.Keys | Sort-Object | Where-Object {[float]$_ -le $ver} | Select-Object -Last 1
    }

    Write-Verbose -Message "Selected $key API Data for $endpoint"
    return $api.$endpoint.$key
} # End of function
function Invoke-RubrikWebRequest {
<#
.SYNOPSIS
Custom wrapper for Invoke-WebRequest, implemented to provide different parameter sets depending on PowerShell version
#>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        $Uri,
        $Headers,
        $Method,
        $Body
    )
    
    if (Test-PowerShellSix) {
        $result = Invoke-WebRequest -UseBasicParsing -SkipCertificateCheck @PSBoundParameters
    } else {
        $result = Invoke-WebRequest -UseBasicParsing @PSBoundParameters
    }
    
    Write-Verbose -Message "Received HTTP Status $($result.StatusCode)"

    return $result
}
function New-BodyString($bodykeys,$parameters)
{
  # The New-BodyString function is used to create a valid body payload
  # $bodykeys = All of the body options available to the endpoint
  # $parameters = All of the parameter options available within the parent function

  # If sending a GET request, no body is needed
  if ($resources.Method -eq 'Get') 
  {
    return $null
  }

  # Look at the list of parameters that were set by the invocation process
  # This is how we know which params were actually set by the call, versus defaulting to some zero, null, or false value
  # We can also add any custom variables here, such as SLAID which is populated after the invocation resolves the name
  if ($slaid -and $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('SLAID'))
  {
    $PSCmdlet.MyInvocation.BoundParameters.SLAID = $slaid
  } 
  elseif($slaid)
  {
    $PSCmdlet.MyInvocation.BoundParameters.Add('SLAID',$slaid)
  }
  
  # Now that custom params are added, let's inventory all invoked params
  $setParameters = $pscmdlet.MyInvocation.BoundParameters
  Write-Verbose -Message "List of set parameters: $($setParameters.GetEnumerator())"

  Write-Verbose -Message 'Build the body parameters'
  $bodystring = @{}
  # Walk through all of the available body options presented by the endpoint
  # Note: Keys are used to search in case the value changes in the future across different API versions
  foreach ($body in $bodykeys)
  {
    Write-Verbose "Adding $body..."
    # Array Object
    if ($resources.Body.$body.GetType().BaseType.Name -eq 'Array')
    {
      $bodyarray = $resources.Body.$body.Keys
      $arraystring = @{}
      foreach ($arrayitem in $bodyarray) 
      {
        # Walk through all of the parameters defined in the function
        # Both the parameter name and parameter alias are used to match against a body option
        # It is suggested to make the parameter name "human friendly" and set an alias corresponding to the body option name
        foreach ($param in $parameters)
        {
          # If the parameter name or alias matches the body option name, build a body string
          
          if ($param.Name -eq $arrayitem -or $param.Aliases -eq $arrayitem)
          {
            # Switch variable types
            if ((Get-Variable -Name $param.Name).Value.GetType().Name -eq 'SwitchParameter')
            {
              $arraystring.Add($arrayitem,(Get-Variable -Name $param.Name).Value.IsPresent)
            }
            # All other variable types
            elseif ($null -ne (Get-Variable -Name $param.Name).Value)
            {
              $arraystring.Add($arrayitem,(Get-Variable -Name $param.Name).Value)
            }
          }
        }
      }
      $bodystring.Add($body,@($arraystring))
    }

    # Non-Array Object
    else 
    {
      # Walk through all of the parameters defined in the function
      # Both the parameter name and parameter alias are used to match against a body option
      # It is suggested to make the parameter name "human friendly" and set an alias corresponding to the body option name
      foreach ($param in $parameters)
      {
        # If the parameter name or alias matches the body option name, build a body string
        if (($param.Name -eq $body -or $param.Aliases -eq $body) -and $setParameters.ContainsKey($param.Name))
        {
          # Switch variable types
          if ((Get-Variable -Name $param.Name).Value.GetType().Name -eq 'SwitchParameter')
          {
            $bodystring.Add($body,(Get-Variable -Name $param.Name).Value.IsPresent)
          }     
          # All other variable types
          elseif ($null -ne (Get-Variable -Name $param.Name).Value -and (Get-Variable -Name $param.Name).Value.Length -gt 0)
          {
            $bodystring.Add($body,(Get-Variable -Name $param.Name).Value)
          }
        }
      }
    }
  }

  # Store the results into a JSON string
  if (0 -ne $bodystring.count) {
    $bodystring = ConvertTo-Json -InputObject $bodystring
    Write-Verbose -Message "Body = $bodystring"
  } else {
    Write-Verbose -Message 'No body for this request'
  }
  return $bodystring
}

function New-QueryString($query,$uri,$nolimit)
{
  # The New-QueryString function is used to collect an array of query values and combine them into a valid URI
  # $params = An array of query values that are added based on which $objects have been passed by the user
  # $uri = The entire URI without any query values added
  # $nolimit = A switch for adding an inflated limit query to retrieve more than one page of results. Set to $true to activate.

  if ($nolimit -eq $true) 
  {
    # When $nolimit is set to $true the limit query value is added to the $params array as the final item
    Write-Verbose -Message 'Query = Found limit flag'
    $query += 'limit=9999'
  }

  # TODO: It seems like there's a more elegant way to do this logic, but this code is stable and functional.
  foreach ($_ in $query)
  {
    # The query begins with a "?" character, which is appended to the $uri after determining that at least one $params was collected
    if ($_ -eq $query[0]) 
    {
      $uri += '?'+$_
    }
    # Subsequent queries are separated by a "&" character
    else 
    {
      $uri += '&'+$_
    }
  }
  return $uri
}
function New-URIString($server,$endpoint,$id)
{
  # The New-URIString function is used to build a valid URI
  # $server = The Rubrik cluster IP or FQDN
  # $endpoint = The endpoint path
  # $id = An id value to be planted into the path or optionally at the end of the URI to retrieve a single object

  Write-Verbose -Message 'Build the URI'
  # If we find {id} in the path, replace it with the $id value  
  if ($endpoint.Contains('{id}'))
  {
    $uri = ('https://'+$server+$endpoint) -replace '{id}', $id
  }
  # Otherwise, only add the $id value at the end if it exists (for single object retrieval)
  else
  {
    $uri = 'https://'+$server+$endpoint
    if ($id) 
    {
      $uri += "/$id"
    }
  }
  Write-Verbose -Message "URI = $uri"
    
  return $uri
}

function Select-ExactMatch {
<#
.SYNOPSIS
Helper function, filters API data when infix search is used to provide an exact match

.DESCRIPTION
This function only selects exact matches based on the name provided in $Parameter

.NOTES
Written by Jaap Brasser for community usage
Twitter: @jaap_brasser
GitHub: jaapbrasser

.EXAMPLE
$result = Select-ExactMatch -Parameter Name -Result $Result

Filters based on the Name parameter, only exact matches will be returned. Additional results supplied by the API endpoints will be filtered out
#>
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string] $Parameter,
        [parameter(Mandatory)]
        $Result
    )

    begin {
        $Value = (Get-Variable -Name $Parameter).Value
    }

    process {
        $OldCount = @($Result).count

        $result = $result | Where-Object {$Value -eq $_.$Parameter}

        Write-Verbose ('Excluded results not matching -{0} ''{1}'' {2} object(s) filtered, {3} object(s) remaining' -f $Parameter,$Value,($OldCount-@($Result).count),@($Result).count)

        return $result
    }
}


function Submit-Request {
    [cmdletbinding(supportsshouldprocess=$true)]
    param(
        $uri,
        $header,
        $method = $($resources.Method),
        $body
    )
    # The Submit-Request function is used to send data to an endpoint and then format the response for further use
    # $uri = The endpoint's URI
    # $header = The header containing authentication details
    # $method = The action (method) to perform on the endpoint
    # $body = Any optional body data being submitted to the endpoint

    if ($PSCmdlet.ShouldProcess($id, $resources.Description)) {
        try {
            Write-Verbose -Message 'Submitting the request'
            if ($resources.method -eq 'Delete') {
                # Delete operations generally have no response body, skip JSON formatting and store the response from Invoke-WebRequest
                if (Test-PowerShellSix) {
                    # Uses the improved ConvertFrom-Json cmdlet as provided in PowerShell 6.1
                    $result = if ($null -ne ($WebResult = Invoke-RubrikWebRequest -Uri $uri -Headers $header -Method $method -Body $body)) {
                        ConvertFrom-Json -InputObject $WebResult
                    }
                } else {
                    # Because some calls require more than the default payload limit of 2MB, ExpandPayload dynamically adjusts the payload limit
                    $result = ExpandPayload -response ($WebResult = Invoke-RubrikWebRequest -Uri $uri -Headers $header -Method $method -Body $body)
                }
                # If $result is null, build a $result object to return to the user. Otherwise, $result will be returned.
                if ($null -eq $result) {   
                    # If if HTTP status code matches our expected result, build a PSObject reflecting success
                    if($WebResult.StatusCode -eq $resources.Success) {
                        $result = [pscustomobject]@{
                            Status = 'Success'
                            HTTPStatusCode = $WebResult.StatusCode
                            HTTPStatusDescription = $WebResult.StatusDescription
                        }
                    } else {
                    # If a different HTTP status is returned, surface that information to the user
                    # This code may never run due to non-200 HTTP codes throwing an HttpResponseException
                        $result = [pscustomobject]@{
                            Status = 'Error'
                            HTTPStatusCode = $WebResult.StatusCode
                            HTTPStatusDescription = $WebResult.StatusDescription
                        }
                    }
                }
            }
            else {
                if (Test-PowerShellSix) {
                    # Uses the improved ConvertFrom-Json cmdlet as provided in PowerShell 6.1
                    $result = ConvertFrom-Json -InputObject (Invoke-RubrikWebRequest -Uri $uri -Headers $header -Method $method -Body $body)
                } else {
                    # Because some calls require more than the default payload limit of 2MB, ExpandPayload dynamically adjusts the payload limit
                    $result = ExpandPayload -response (Invoke-RubrikWebRequest -Uri $uri -Headers $header -Method $method -Body $body)
                }
            }
        }
        catch {
            switch -Wildcard ($_) {
                'Route not defined.' {
                    Write-Warning -Message "The endpoint supplied to Rubrik is invalid. Likely this is due to an incompatible version of the API or references pointing to a non-existent endpoint. The URI passed was: $uri" -Verbose
                    throw $_.Exception 
                }
                'Invalid ManagedId*' {
                    Write-Warning -Message "The endpoint supplied to Rubrik is invalid. Likely this is due to an incompatible version of the API or references pointing to a non-existent endpoint. The URI passed was: $uri" -Verbose
                    throw $_.Exception 
                }
                '{"errorType":*' {
                    # Parses the Rubrik generated JSON warning into something a bit more human readable
                    # Fields are: errorType, message, and cause
                    [Array]$rubrikWarning = ConvertFrom-Json $_.ErrorDetails.Message
                    if ($rubrikWarning.errorType) {Write-Warning -Message $rubrikWarning.errorType}
                    if ($rubrikWarning.message) {Write-Warning -Message $rubrikWarning.message}
                    if ($rubrikWarning.cause) {Write-Warning -Message $rubrikWarning.cause}
                    throw $_.Exception
                }
                '{"message":*' {
                    [Array]$rubrikWarning = ConvertFrom-Json $_.ErrorDetails.Message
                    if ($rubrikWarning.errorType) {Write-Warning -Message $rubrikWarning.errorType}
                    if ($rubrikWarning.message) {Write-Warning -Message $rubrikWarning.message}
                    if ($rubrikWarning.cause) {Write-Warning -Message $rubrikWarning.cause}
                    throw $_.Exception
                }
                default {
                    throw $_
                }
            }
        }

        return $result 

    }
}

function Test-DateDifference([array]$date,[datetime]$compare,[int]$range)
{
  # The Test-DateDifference function is used to compare a series of dates against a desired date to find the closest matching date/time
  # The Rubrik API returns snapshot dates down to the millisecond, but the user may not provide this much detail in their Date argument
  # A snapshot date may be in the future by milliseconds, but this is considered valid since that is most likely the intent of the user
  # $date = An array of ISO 8601 style dates (e.g. YYYY-MM-DDTHH:MM:SSZ)
  # $compare = A single ISO 8601 style date to compare against the $date array
  
  # A simple hashtable is created to compare each date value against one another
  # The value that is closest to 0 (e.g. least distance away from the $compare date) is stored
  # $range defines how many days away from $compare to search for the closest match. Ex: $range = 3 will look within a 3 day period to find a match
  # Otherwise, the date of $null is returned meaning no match
  Write-Verbose -Message "Finding closest matching date"
  $datematrix = @{
    date  = $null
    value = $range
  }
 
  foreach ($_ in $date)
  {
    # The $c is just a check variable used to hold the total number of days between the current $date item and the $compare value
    $c = (New-TimeSpan -Start $_ -End $compare).TotalDays
    # Should we find a value that is less than the existing winning value, store it
    # Note: 0 would be a perfect match (e.g. 0 days different between what we found and what the user wants in $compare)
    # Note: Negative values indicate a future (e.g. supply yesterday for $compare but finding a $date from today)
    # Absolute values are used so negatives are ignored and we find the closest actual match. 
    if ([Math]::Abs($c) -lt $datematrix.value)
    {
      $datematrix.date = $_
      $datematrix.value = [Math]::Abs($c)
    }

    # If $c = 0, a perfect match has been found
    if ($datematrix.value -eq 0) { break }
  }
  
  If ($null -ne $datematrix.date) {
    Write-Verbose -Message "Using date $($datematrix.date)"
  }
  else {
    Write-Verbose -Message "Could not find matching date within one day of $($compare.ToString())"
  }
  return $datematrix.date
}

function Test-FilterObject($filter,$result)
{
  # The Test-FilterObject function is used to filter data that has been returned from an endpoint for specific objects important to the user
  # $filter = The list of parameters that the user can use to filter response data. Each key is the parameter name without the "$" and each value corresponds to the response data's key
  # $result = The formatted API response content

  Write-Verbose -Message 'Filter the results'
  foreach ($param in $filter.Keys)
  {
    if ((Get-Variable -Name $param -ErrorAction SilentlyContinue).Value -ne $null)
    {
      Write-Verbose -Message "Filter match = $param"
      $result = Test-ReturnFilter -object (Get-Variable -Name $param).Value -location $filter[$param] -result $result
    }
  }
    
  return $result
}

function Test-PowerShellSix {
<#
.SYNOPSIS
Test if the PowerShell version is 6 or higher, this is to provide backwards compatibility for older version of PowerShell
#>
    $PSVersionTable.PSVersion.Major -ge 6
}
function Test-QueryObject($object,$location,$query)
{
  # The Test-QueryObject function is used to build a custom query string for supported endpoints
  # $object = The parent function's variable holding the user generated query data
  # $location = The key/value pair that contains the correct query name value
  # $params = An array of query values that are added based on which $objects have been passed by the user
  Write-Debug -Message ($PSBoundParameters | Out-String)

  if ((-not [string]::IsNullOrWhiteSpace($object)) -and ($location)) {
    # This builds the individual query item for the endpoint
    # Example: /vmware/vm?search_value=SE-CWAHL-WIN&limit=9999 contains 2 queries - search_value and limit
    return "$location=$object"
  }
}
function Test-QueryParam($querykeys,$parameters,$uri)
{
  # The Submit-Request function is used to send data to an endpoint and then format the response for further use
  # $querykeys = All of the query options available to the endpoint
  # $parameters = All of the parameter options available within the parent function
  # $uri = The endpoint's URI
  
  # For functions that can address multiple different endpoints based on the $id value
  # If there are multiple URIs referenced in the API resources, we know this is true
  if (($resources.URI).count -ge 2)
  {  
    Write-Verbose -Message "Multiple URIs detected. Selecting URI based on $id"
    Switch -Wildcard ($id)
    {
      'Fileset:::*'
      {
        Write-Verbose -Message 'Loading Fileset API data'
        $uri = ('https://'+$Server+$resources.URI.Fileset) -replace '{id}', $id
      }
      'MssqlDatabase:::*'
      {
        Write-Verbose -Message 'Loading MSSQL API data'
        $uri = ('https://'+$Server+$resources.URI.MSSQL) -replace '{id}', $id
      }
      'VirtualMachine:::*'
      {
        Write-Verbose -Message 'Loading VMware API data'
        $uri = ('https://'+$Server+$resources.URI.VMware) -replace '{id}', $id
      }
      'HypervVirtualMachine:::*'
      {
        Write-Verbose -Message 'Loading HyperV API data'
        $uri = ('https://'+$Server+$resources.URI.HyperV) -replace '{id}', $id
      }
      'ManagedVolume:::*'
      {
        Write-Verbose -Message 'Loading Managed Volume API data'
        $uri = ('https://'+$Server+$resources.URI.ManagedVolume) -replace '{id}', $id
      }
      'NutanixVirtualMachine:::*'
      {
        Write-Verbose -Message 'Loading Nutanix API data'
        $uri = ('https://'+$Server+$resources.URI.Nutanix) -replace '{id}', $id
      }
      'VolumeGroup:::*'
      {
        Write-Verbose -Message 'Loading VolumeGroup API data'
        $uri = ('https://'+$Server+$resources.URI.VolumeGroup) -replace '{id}', $id
      }
      'OracleDatabase:::*'
      {
        Write-Verbose -Message 'Loading OracleDatabase API data'
        $uri = ('https://'+$Server+$resources.URI.Oracle) -replace '{id}', $id
      }
      default
      {
        throw 'The supplied id value has no matching endpoint'
      }
    }
    
    # This ends the logic statement without running the rest of this private function
    return $uri
  }

  Write-Verbose -Message "Build the query parameters for $($querykeys -join ',')"
  $querystring = @()
  # Walk through all of the available query options presented by the endpoint
  # Note: Keys are used to search in case the value changes in the future across different API versions
  foreach ($query in $querykeys)
  {
    # Walk through all of the parameters defined in the function
    # Both the parameter name and parameter alias are used to match against a query option
    # It is suggested to make the parameter name "human friendly" and set an alias corresponding to the query option name
    foreach ($param in $parameters)
    {
      # If the parameter name matches the query option name, build a query string
      if ($param.Name -eq $query)
      {
        $querystring += Test-QueryObject -object (Get-Variable -Name $param.Name).Value -location $resources.Query[$param.Name] -params $querystring
      }
      # If the parameter alias matches the query option name, build a query string
      elseif ($param.Aliases -eq $query)
      {
        $querystring += Test-QueryObject -object (Get-Variable -Name $param.Name).Value -location $resources.Query[$param.Aliases] -params $querystring
      }
    }
  }
  # After all query options are exhausted, build a new URI with all defined query options
  
  if ($parameters.name -contains 'limit') {
    $uri = New-QueryString -query $querystring -uri $uri
  } else {  
    $uri = New-QueryString -query $querystring -uri $uri -nolimit $true
  }
  Write-Verbose -Message "URI = $uri"
    
  return $uri
}

function Test-ReturnFilter($object,$location,$result)
{
  # The Test-ReturnFilter function is used to perform a search across response content for a particular value
  # $object = The parent function's variable holding the user generated query data
  # $location = The key/value pair that contains the name of the key holding the data to filter through
  # $result = The unfiltered API response content
  
  # For when a location is one layer deep
  if ($object -and $location.split('.').count -eq 1)
  {
    # The $object check assumes that not all filters will be used in each call
    # If it does exist, the results are filtered using the $object's value against the $location's key name
    # Example: Filtering an SLA Domain Name based on the "effectiveSlaDomainName" key/value pair
    return $result | Where-Object -FilterScript {
      $_.$location -eq $object
    }
  }
  # For when a location is two layers deep
  elseif ($object -and $location.split('.').count -eq 2)
  {
    # The $object check assumes that not all filters will be used in each call
    # If it does exist, the results are filtered using the $object's value against the $location's key name
    # Example: Filtering an SLA Domain Name based on the "effectiveSlaDomainName" key/value pair
    return $result | Where-Object -FilterScript {
      $_.($location.split('.')[0]).($location.split('.')[-1]) -eq $object
    }
  }
  else
  {
    # When no $location is found, return the original $result
    return $result
  }
}

function Test-ReturnFormat($api,$result,$location)
{
  # The Test-ReturnFormat function is used to remove any parent variables surrounding return data, such as encapsulating results in a "data" key
  # $api = The API version
  # $result = The unformatted API response content
  # $location = The key/value pair that contains the name of the key holding the response content's data

  Write-Verbose -Message 'Formatting return value'
  if ($location -and ($null -ne ($result).$location))
  {
    # The $location check assumes that not all endpoints will require findng (and removing) a parent key
    # If one does exist, this extracts the value so that the $result data is consistent across API versions
    return ($result).$location
  }
  else
  {
    # When no $location is found, return the original $result
    return $result
  }
}

function Test-RubrikConnection() 
{
  # Test to see if a session has been established to the Rubrik cluster
  # If no token is found, this will throw an error and halt the script
  # Otherwise, the token is loaded into the script's $Header var
  
  Write-Verbose -Message 'Validate the Rubrik token exists'
  if (-not $global:RubrikConnection.token) 
  {
    Write-Warning -Message 'Please connect to only one Rubrik Cluster before running this command.'
    throw 'A single connection with Connect-Rubrik is required.'
  }
  Write-Verbose -Message 'Found a Rubrik token for authentication'
  $script:Header = $global:RubrikConnection.header
}
function Test-RubrikCredential($Username,[SecureString]$Password,$Credential)
{
  Write-Verbose -Message 'Validate credential'  
  if ($Credential)
  {
    return $Credential
  }
  Write-Verbose -Message 'Validate username and password'
  if ($Username -eq $null -or $Password -eq $null)
  {
    Write-Warning -Message 'You did not submit a username, password, or credentials.'
    return Get-Credential -Message 'Please enter administrative credentials for your Rubrik cluster'
  }
  else
  {
    Write-Verbose -Message 'Store username and password into credential object'
    return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password
  }
}

function Test-RubrikLDAPCredential($BindUserName,[SecureString]$BindUserPassword,$BindCredential)
{
  Write-Verbose -Message 'Validate credential'  
  if ($BindCredential)
  {
    return $BindCredential
  }
  Write-Verbose -Message 'Validate username and password'
  if ($BindUserName -eq $null -or $BindUserPassword -eq $null)
  {
    Write-Warning -Message 'You did not submit a username, password, or credentials.'
    return Get-Credential -Message 'Please enter administrative credentials for your LDAP server'
  }
  else
  {
    Write-Verbose -Message 'Store username and password into credential object'
    return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $BindUserName, $BindUserPassword
  }
}

Function Test-RubrikSLA($SLA,$Inherit,$DoNotProtect,$Mandatory,$PrimaryClusterID='local')
{
  Write-Verbose -Message 'Determining the SLA Domain id'
  if ($SLA) 
  {
    $slaid = (Get-RubrikSLA -SLA $SLA -PrimaryClusterID $PrimaryClusterID).id
    if ($slaid -eq $null) 
    {
      throw "No SLA Domains were found that match $SLA for $PrimaryClusterID"
    }
    return $slaid
  }
  if ($Inherit) 
  {
    return 'INHERIT'
  }
  if ($DoNotProtect) 
  {
    return 'UNPROTECTED'
  }
  if ($Mandatory)
  {
    throw 'No SLA information was entered.'
  }
}
    

function Test-VMwareConnection()
{
  # Must have only one vCenter connection open
  # Potential future work: loop through all vCenter connections
  # Code snipet blatantly stolen from Vester :)

  if ((Get-Module -ListAvailable -Name VMware.PowerCLI) -eq $null) {
    Write-Warning -Message 'Please install VMware PowerCli PowerShell module before running this command.'
    throw 'VMware.PowerCli module is required.'
  } ElseIf ($DefaultVIServers.Count -lt 1) 
  {
    Write-Warning -Message 'Please connect to vCenter before running this command.'
    throw 'A single connection with Connect-VIServer is required.'
  } ElseIf ($DefaultVIServers.Count -gt 1) {
    Write-Warning -Message 'Please connect to only one vCenter before running this command.'
    Write-Warning -Message "Current connections:  $($DefaultVIServers -join ' / ')"
    throw 'A single connection with Connect-VIServer is required.'
  }
  Write-Verbose -Message "vCenter: $($DefaultVIServers.Name)"
}

<#
    Helper function to allow self-signed certificates for HTTPS connections
    This is required when using RESTful API calls over PowerShell
#>
function Unblock-SelfSignedCert() 
{
  Write-Verbose -Message 'Allowing self-signed certificates'
    
  if ([System.Net.ServicePointManager]::CertificatePolicy -notlike 'TrustAllCertsPolicy') 
  {
    Add-Type -TypeDefinition @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
	    public bool CheckValidationResult(
	        ServicePoint srvPoint, X509Certificate certificate,
	        WebRequest request, int certificateProblem) {
	        return true;
	    }
    }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object -TypeName TrustAllCertsPolicy
  }
}

#Requires -Version 3
function Connect-Rubrik {
    <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves a token value for authentication

      .DESCRIPTION
      The Connect-Rubrik function is used to connect to the Rubrik RESTful API and supply credentials to the /login method.
      Rubrik then returns a unique token to represent the user's credentials for subsequent calls.
      Acquire a token before running other Rubrik cmdlets.
      Note that you can pass a username and password or an entire set of credentials.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Connect-Rubrik.html

      .EXAMPLE
      Connect-Rubrik -Server 192.168.1.1 -Username admin
      This will connect to Rubrik with a username of "admin" to the IP address 192.168.1.1.
      The prompt will request a secure password.

      .EXAMPLE
      Connect-Rubrik -Server 192.168.1.1 -Username admin -Password (ConvertTo-SecureString "secret" -asplaintext -force)
      If you need to pass the password value in the cmdlet directly, use the ConvertTo-SecureString function.

      .EXAMPLE
      Connect-Rubrik -Server 192.168.1.1 -Credential (Get-Credential)
      Rather than passing a username and secure password, you can also opt to submit an entire set of credentials using the -Credentials parameter.

      .EXAMPLE
      Connect-Rubrik -Server 192.168.1.1 -Token "token key provided by Rubrik"
      Rather than passing a username and secure password, you can now generate an API token key in Rubrik. This key can then be used to authenticate instead of a credential or user name and password. 
      
  #>
    [cmdletbinding(SupportsShouldProcess=$true,DefaultParametersetName='UserPassword')]
    Param(
        # The IP or FQDN of any available Rubrik node within the cluster
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullorEmpty()]
        [String]$Server,
        # Username with permissions to connect to the Rubrik cluster
        # Optionally, use the Credential parameter    
        [Parameter(ParameterSetName='UserPassword',Mandatory=$true, Position = 1)]
        [String]$Username,
        # Password for the Username provided
        # Optionally, use the Credential parameter
        [Parameter(ParameterSetName='UserPassword',Mandatory=$true, Position = 2)]
        [SecureString]$Password,
        # Credentials with permission to connect to the Rubrik cluster
        # Optionally, use the Username and Password parameters
        [Parameter(ParameterSetName='Credential',Mandatory=$true, Position = 1)]
        [System.Management.Automation.CredentialAttribute()]$Credential,
        # Provide the Rubrik API Token instead, these are specificially created API token for authentication.
        [Parameter(ParameterSetName='Token',Mandatory=$true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$Token,
        #Organization to connect with, assuming the user has multiple organizations
        [Alias('organization_id')]
        [String]$OrganizationID


    )

    Begin {
        
        if (-not (Test-PowerShellSix)) {
            Unblock-SelfSignedCert

            #Force TLS 1.2
            try {
                if ([Net.ServicePointManager]::SecurityProtocol -notlike '*Tls12*') {
                    Write-Verbose -Message 'Adding TLS 1.2'
                    [Net.ServicePointManager]::SecurityProtocol = ([Net.ServicePointManager]::SecurityProtocol).tostring() + ', Tls12'
                }
            }
            catch {
                Write-Verbose -Message $_
                Write-Verbose -Message $_.Exception.InnerException.Message
            }
        }

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

        # Create User Agent string
        $UserAgent = "Rubrik-Powershell-SDK/$($MyInvocation.MyCommand.ScriptBlock.Module.Version.ToString())"
        Write-Verbose -Message "Using User Agent $($UserAgent)"

        if($Token) {
            $head = @{'Authorization' = "Bearer $($Token)";'User-Agent' = $UserAgent}
            Write-Verbose -Message 'Storing all connection details into $global:rubrikConnection'
            $global:rubrikConnection = @{
                id      = $null
                userId  = $null
                token   = $Token
                server  = $Server
                header  = $head
                time    = (Get-Date)
                api     = Get-RubrikAPIVersion -Server $Server
                version = Get-RubrikSoftwareVersion -Server $Server
                authType = 'Token'
            }

            try {
                $RestSplat = @{
                    Endpoint = 'user/me'
                    Method = 'get'
                    Api = 'internal'
                }
                $global:rubrikConnection.userid = (Invoke-RubrikRESTCall @RestSplat -ErrorAction Stop).id -replace '.*?:::'

            } catch {
                Write-Verbose -Message 'Removing API token from $RubrikConnection using Disconnect-Rubrik'
                Disconnect-Rubrik
                throw 'Invalid API Token provided, please provide correct token'
            }
        } else {
            $Credential = Test-RubrikCredential -Username $Username -Password $Password -Credential $Credential

            $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
            $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
            $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    

            # Standard Basic Auth Base64 encoded header with username:password
            $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
            $head = @{
                'Authorization' = "Basic $auth"
                'User-Agent' = $UserAgent
            }          
            $content = Submit-Request -uri $uri -header $head -method $($resources.Method)

            # Final throw for when all versions of the API have failed
            if ($content.token -eq $null) {
                throw 'No token found. Unable to connect with any available API version. Check $Error for details or use the -Verbose parameter.'
            }

            # For API version v1 or greater, use Bearer and token
            $head = @{'Authorization' = "Bearer $($content.token)";'User-Agent' = $UserAgent}

            Write-Verbose -Message 'Storing all connection details into $global:rubrikConnection'
            $global:rubrikConnection = @{
                id      = $content.id
                userId  = $content.userId
                token   = $content.token
                server  = $Server
                header  = $head
                time    = (Get-Date)
                api     = Get-RubrikAPIVersion -Server $Server
                version = Get-RubrikSoftwareVersion -Server $Server
                authType = 'Basic'
            }
        }
        Write-Verbose -Message 'Adding connection details into the $global:RubrikConnections array'
        [array]$global:RubrikConnections += $rubrikConnection
    
        $global:rubrikConnection.GetEnumerator() | Where-Object -FilterScript {
            $_.name -notmatch 'token'
        }

    } # End of process
} # End of function
#requires -Version 3
function Disconnect-Rubrik
{
  <#  
      .SYNOPSIS
      Disconnects from a Rubrik cluster

      .DESCRIPTION
      The Disconnect-Rubrik function is used to disconnect from a Rubrik cluster.
      This is done by supplying the bearer token and requesting that the session be deleted.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Disconnect-Rubrik.html

      .EXAMPLE
      Disconnect-Rubrik -Confirm:$false
      This will close the current session and invalidate the current session token without prompting for confirmation

      .EXAMPLE
      $rubrikConnection = $RubrikConnections[1]
      Disconnect-Rubrik
      This will close the second session and invalidate the second session token
      Note: The $rubrikConnections variable holds session details on all established sessions
            The $rubrikConnection variable holds the current, active session
            If you wish to change sessions, simply update the value of $rubrikConnection to another session held within $rubrikConnections
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Session id
    [Parameter(ValueFromPipelineByPropertyName = $true)]    
    [String]$id = 'me',    
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
    
    # if token was used to authenticate, remove variable and exit
    if ($global:RubrikConnection.authType -eq 'Token') {
      Write-Verbose -Message "Detected token authentication - Disconnecting without deleting token."
      
      # Remove from RubrikConnections global Variable
      $global:RubrikConnections = $RubrikConnections | Where-Object {$_.Token -ne $RubrikConnection.Token}
      
      # Remove Global variable, RubrikConnection
      Remove-Variable -Name RubrikConnection -Scope Global
      $result = $null
    }
    else {
      $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
      $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
      $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
      $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
      $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
      $result = Test-FilterObject -filter ($resources.Filter) -result $result
    }

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Export-RubrikDatabase
{
  <#
      .SYNOPSIS
      Connects to Rubrik exports a database to a MSSQL instance

      .DESCRIPTION
      The Export-RubrikDatabase command will request a database export from a Rubrik Cluster to a MSSQL instance

      .NOTES
      Written by Pete Milanese for community usage
      Twitter: @pmilano1
      GitHub: pmilano1

      Modified by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .EXAMPLE
      Export-RubrikDatabase -id MssqlDatabase:::c5ecf3ef-248d-4bb2-8fe1-4d3c820a0e38 -targetInstanceId MssqlInstance:::0085b247-e718-4177-869f-e3ae1f7bb503 -targetDatabaseName ReportServer -finishRecovery -maxDataStreams 4 -timestampMs 1492661627000
      
      .EXAMPLE
      Export-RubrikDatabase -id $db.id -recoveryDateTime (Get-Date (Get-RubrikDatabase $db).latestRecoveryPoint) -targetInstanceId $db2.instanceId -targetDatabaseName 'BAR_EXP' -targetFilePaths $targetfiles -maxDataStreams 1

      Restore the $db (where $db is the output of a Get-RubrikDatabase call) to the most recent recovery point for that database. New file paths are 
      in the $targetfiles array. Each individual file declaration (logicalName, exportPath,newFilename) will be a hashtable, so what gets passed to the
      cmdlet is an array of hashtables
      
      $targetfiles = @()
      $targetfiles += @{logicalName='BAR_1';exportPath='E:\SQLFiles\Data\BAREXP\'}
      $targetfiles += @{logicalName='BAR_LOG';exportPath='E:\SQLFiles\Log\BAREXP\'}
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Export-RubrikDatabase.html
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik identifier of database to be exported
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$Id,
    # Number of parallel streams to copy data
    [int]$MaxDataStreams,
    # Recovery Point desired in the form of Epoch with Milliseconds
    [Parameter(ParameterSetName='Recovery_timestamp')]
    [int64]$TimestampMs,
    # Recovery Point desired in the form of DateTime value
    [Parameter(ParameterSetName='Recovery_DateTime')]
    [datetime]$RecoveryDateTime,
    # Recovery Point desired in the form of an LSN (Log Sequence Number)
    [Parameter(ParameterSetName='Recovery_LSN')]
    [string]$RecoveryLSN,
    # Take database out of recovery mode after export
    [Switch]$FinishRecovery,
    # Rubrik identifier of MSSQL instance to export to
    [string]$TargetInstanceId,
    # Name to give database upon export
    [string]$TargetDatabaseName,
    [Switch]$Overwrite,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api,
    #Simple Mode - Data File Path 
    [Alias('DataFilePath')]   
    [string]$TargetDataFilePath,
    #Simple Mode - Data File Path
    [Alias('LogFilePath')]    
    [string]$TargetLogFilePath,
    #Advanced Mode - Array of hash tables for file reloaction.
    [PSCustomObject[]] $TargetFilePaths
  )

    Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section

    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection

    #If recoveryDateTime, convert to epoch milliseconds
    if($recoveryDateTime){  
      $TimestampMs = ConvertTo-EpochMS -DateTimeValue $RecoveryDateTime
    } 
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $Id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri

    #region One-off
    Write-Verbose -Message "Build the body"
    $body = @{
      $resources.Body.targetInstanceId = $TargetInstanceId
      $resources.Body.targetDatabaseName = $TargetDatabaseName
      $resources.Body.finishRecovery = $FinishRecovery.IsPresent
      recoveryPoint = @()
    }

    if($MaxDataStreams){
      $body.Add($resources.Body.maxDataStreams,$MaxDataStreams)
    }

    if($TargetFilePaths){
      Write-Verbose "Adding Advanced Mode File Paths"
      if($TargetDataFilePath -or $TargetLogFilePath) {Write-Warning 'Use of -TargetFilePaths overrides -TargetDataFilePath and -TargetLogFilePath.'}
      $body.Add('targetFilePaths',$TargetFilePaths)
    } else {
      Write-Verbose "Adding Simple Mode File Paths"
      if($TargetDataFilePath){ $body.Add('targetDataFilePath',$TargetDataFilePath) }
      if($TargetLogFilePath){ $body.Add('targetLogFilePath',$TargetLogFilePath) }
    }

    if($RecoveryLSN){
      $body.recoveryPoint += @{lsnPoint=@{lsn=$RecoveryLSN}}
    } else {
      $body.recoveryPoint += @{timestampMs = $TimestampMs}
    }

    if($Overwrite){
      $body.add('allowOverwrite',$true)
    }

    $body = ConvertTo-Json $body -Depth 10
    Write-Verbose -Message "Body = $body"
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#requires -Version 3
function Export-RubrikReport
{
  <#  
      .SYNOPSIS
      Retrieves link to a CSV file for a Rubrik Envision report

      .DESCRIPTION
      The Export-RubrikReport cmdlet is used to pull the link to a CSV file for a Rubrik Envision report

      .NOTES
      Written by Bas Vinken for community usage
      Twitter: @bvinken
      GitHub: basvinken

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Export-RubrikReport.html

      .EXAMPLE
      Export-RubrikReport -id '11111111-2222-3333-4444-555555555555' -timezone_offset 120
      This will return the link to a CSV file for report id "11111111-2222-3333-4444-555555555555"

      .EXAMPLE
      Get-RubrikReport -Name 'Protection Tasks Details' | Export-RubrikReport
      This will return the link to a CSV file for report named "Protection Tasks Details"
  #>

  [CmdletBinding()]
  Param(
    # ID of the report.	
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Timezone offset from UTC in minutes.	
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [Alias('timezone_offset')]
    [String]$TimezoneOffset = 0,
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

#Requires -Version 3
function Export-RubrikVM
{
  <#  
      .SYNOPSIS
      Exports a given snapshot for a VMware VM
      
      .DESCRIPTION
      The Export-RubrikVM cmdlet is used to restore a snapshot from a protected VM, copying all data to a given datastore and running the VM in an existing vSphere environment.
      
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Export-RubrikVM.html

      .EXAMPLE
      Export-RubrikVM -id '7acdf6cd-2c9f-4661-bd29-b67d86ace70b' -HostId (Get-RubrikVMwareHost -name esxi01 -PrimaryClusterID local).id -DatastoreId (Get-RubrikVMwareDatastore -name vSAN).id
      This will mount the snapshot with an id of 7acdf6cd-2c9f-4661-bd29-b67d86ace70b to the specified host and datastore
      
      .EXAMPLE
      Get-RubrikVM 'server01' -PrimaryClusterID local | Get-RubrikSnapshot | Sort-Object -Property Date -Descending | Select -First 1 | Export-RubrikVM -HostId (Get-RubrikVMwareHost -name esxi01 -PrimaryClusterID local).id -DatastoreId (Get-RubrikVMwareDatastore -name vSAN).id
      This will retreive the latest snapshot from the given VM 'server01' and export to the specified host and datastore.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik id of the snapshot to export
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Rubrik id of the vSphere datastore to store exported VM. (Use "Invoke-RubrikRESTCall -Endpoint 'vmware/datastore' -Method 'GET' -api 'internal'" to retrieve a list of available VMware datastores)
    [Parameter(Mandatory = $true)]
    [String]$DatastoreId,
    # ID of host for the export to use (Use "Invoke-RubrikRESTCall -Endpoint 'vmware/host' -Method 'GET' -api '1'" to retrieve a list of available VMware hosts.)
    [Parameter(Mandatory = $true)]
    [String]$HostID,
    # Name of the exported VM 
    [String]$VMName,
    # Whether the network should be disabled upon restoration. This should be set true to avoid ip conflict if source VM still exists. 
    [Bool]$DisableNetwork,
    # Whether to remove network interfaces from the restored virtual machine. Default is false.
    [Bool]$RemoveNetworkDevices,
    # Whether to assign MAC addresses from source virtual machine to exported virtual machine. Default is false.
    [Bool]$KeepMACAddresses,
    # Whether the newly restored virtual machine is unregistered from vCenter. Default is false.
    [Bool]$UnregisterVM,
    # Whether the VM should be powered on after restoration. Default is true.
    [Bool]$PowerOn,
    # Whether to recover vSphere tags
    [Alias('shouldRecoverTags')]
    [Bool]$RecoverTags,
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
#requires -Version 3
function Get-RubrikAPIToken
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves a list of generated API tokens

      .DESCRIPTION
      The Get-RubrikAPIToken cmdlet is used to pull a list of generated API tokens from the Rubrik cluster.

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
     http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikAPIToken.html

      .EXAMPLE
      Get-RubrikAPIToken
      This will return all generated API tokens belonging to the currently logged in user.

      .EXAMPLE
      Get-RubrikAPIToken -tag roxie
      This will return all generated API tokens belonging to the currently logged in user with a 'roxie' tag.

      .EXAMPLE
      Get-RubrikAPIToken -organizationId 1111-2222-3333
      This will return all generated API tokens assigned to the currently logged in user with the specified organization id.
  #>

  [CmdletBinding()]
  Param(
    # UserID to retrieve tokens from - defaults to currently logged in user
    [ValidateNotNullorEmpty()]
    [Alias('user_id')]
    [String]$UserId = $rubrikconnection.userId,
    # Tag assigned to the API Token
    [String]$Tag,
    # Organization ID the API Token belongs to.
    [String]$OrganizationId,
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

    # Remove any api tokens generated for usage with web
    $result = $result | Where-Object {$_.sessionType -ne 'Web'}
    
    if ($null -ne $result) {
      @($result).ForEach{$_.PSObject.TypeNames.Insert(0,'Rubrik.APIToken')}
    }
    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Get-RubrikAPIVersion
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves the current API version
            
      .DESCRIPTION
      The Get-RubrikVersion cmdlet will retrieve the API version actively running on the system. This does not require authentication.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikAPIVersion.html
            
      .EXAMPLE
      Get-RubrikAPIVersion -Server 192.168.1.100
      This will return the running API version on the Rubrik cluster reachable at the address 192.168.1.100
  #>

  [CmdletBinding()]
  Param(
    # Rubrik server IP or FQDN
    [Parameter(Mandatory = $true)]    
    [String]$Server,
    # ID of the Rubrik cluster or me for self
    [String]$id = 'me',
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = 'v1'
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
  
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#requires -Version 3
function Get-RubrikAvailabilityGroup
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more Avaialbility Group known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikAvailabilityGroup cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of Availability Groups.
      To narrow down the results, use the group name or SLA limit your search to a smaller group of objects.
      Alternatively, supply the Rubrik database ID to return only one specific database.

      .NOTES
      Written by Chris Lumnah for community usage
      Twitter: @lumnah
      GitHub: clumnah

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikAvailabilityGroup -GroupName 'am1-sql16ag-1ag'
      This will return details on the Availability Group
  #>

  [CmdletBinding()]
  Param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    
    # Name of the availability group
    [Alias('name')]
    [String]$GroupName,
    
    # SLA Domain policy assigned to the database
    [Alias('effectiveSlaDomainName')]
    [String]$SLA,
    
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,    

    [Alias('effectiveSlaDomainId')]
    [String]$SLAID,     
    
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

    Begin 
    {

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

#Requires -Version 3
function Get-RubrikBootStrap
{
  <#  
      .SYNOPSIS
      Connects to Rubrik cluster and retrieves the bootstrap process progress.
            
      .DESCRIPTION
      This function is created to pull the status of a cluster bootstrap request.
      
      .LINK
      https://github.com/nshores/rubrik-sdk-for-powershell/tree/bootstrap
            
      .EXAMPLE
      Get-RubrikBootStrap -server 169.254.11.25 -requestid 1
      This will return the bootstrap status of the job with the requested ID.
  #>

  [CmdletBinding()]
  Param(
    # ID of the Rubrik cluster or me for self
    [ValidateNotNullOrEmpty()]
    [String] $id = 'me',
    # Rubrik server IP or FQDN
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String] $Server,
    # Bootstrap Request ID
    [ValidateNotNullOrEmpty()]
    [Alias('request_id')]
    [string] $RequestId = '1'
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

#requires -Version 3
function Get-RubrikDatabase
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more databases known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikDatabase cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of databases.
      To narrow down the results, use the host and instance parameters to limit your search to a smaller group of objects.
      Alternatively, supply the Rubrik database ID to return only one specific database.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikDatabase.html

      .EXAMPLE
      Get-RubrikDatabase -Name 'DB1' -SLA Gold
      This will return details on all databases named DB1 protected by the Gold SLA Domain on any known host or instance.

      .EXAMPLE
      Get-RubrikDatabase -Name 'DB1' -DetailedObject
      This will return the Database object with all properties, including additional details such as snapshots taken of the database and recovery point date/time information. Using this switch parameter negatively affects performance 

      .EXAMPLE
      Get-RubrikDatabase -Name 'DB1' -Host 'Host1' -Instance 'MSSQLSERVER'
      This will return details on a database named "DB1" living on an instance named "MSSQLSERVER" on the host named "Host1".

      .EXAMPLE
      Get-RubrikDatabase -Relic
      This will return all removed databases that were formerly protected by Rubrik.

      .EXAMPLE
      Get-RubrikDatabase -Relic:$false
      This will return all databases that are currently protected by Rubrik.

      .EXAMPLE
      Get-RubrikDatabase
      This will return all databases that are currently or formerly protected by Rubrik.

      .EXAMPLE
      Get-RubrikDatabase -id 'MssqlDatabase:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      This will return details on a single database matching the Rubrik ID of "MssqlDatabase:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
      Note that the database ID is globally unique and is often handy to know if tracking a specific database for longer workflows,
      whereas some values are not unique (such as nearly all hosts having one or more databases named "model") and more difficult to track by name.
  
      .EXAMPLE
      Get-RubrikDatabase -InstanceID MssqlInstance:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee
      This will return details on a single SQL instance matching the Rubrik ID of "MssqlInstance:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
  #>

  [CmdletBinding()]
  Param(
    # Rubrik's database id value
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()] 
    [String]$id,
    # Name of the database
    [Alias('Database')]
    [Parameter(ParameterSetName='Query')]
    [String]$Name,
    # Filter results to include only relic (removed) databases
    [Alias('is_relic')]
    [Switch]$Relic,
    # SLA Domain policy assigned to the database
    [String]$SLA,
    # Name of the database instance
    [String]$Instance,    
    # Name of the database host
    [String]$Hostname,
    #ServerInstance name (combined hostname\instancename)
    [String]$ServerInstance,
    #SQL InstanceID, used as a unique identifier
    [Alias('instance_id')]
    [string]$InstanceID,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,    
    # SLA id value
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,
    # DetailedObject will retrieved the detailed database object, the default behavior of the API is to only retrieve a subset of the database object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
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

    #region one-off
    if($ServerInstance){

      $SIobj = ConvertFrom-SqlServerInstance $ServerInstance
      $Hostname = $SIobj.hostname
      $Instance = $SIobj.instancename
    }
      
   if($Hostname.Length -gt 0 -and $Instance.Length -gt 0 -and $InstanceID.Length -eq 0){
      $InstanceID = (Get-RubrikSQLInstance -Hostname $Hostname -Name $Instance).id
    }
    #endregion
  }

  Process {

    #region One-off
    # If SLA paramter defined, resolve SLAID
    If ($SLA) {
      $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    }
    #endregion

    # If the switch parameter was not explicitly specified remove from query params 
    if(-not $PSBoundParameters.ContainsKey('Relic')) {
      $Resources.Query.Remove('is_relic')
    }

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    
    # If the Get-RubrikDatabase function has been called with the -DetailedObject parameter a separate API query will be performed if the initial query was not based on ID
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      for ($i = 0; $i -lt @($result).Count; $i++) {
        $Percentage = [int]($i/@($result).count*100)
        Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
        Get-RubrikDatabase -id $result[$i].id
      }
    } else {
      return $result
    }

  } # End of process
} # End of function

#Requires -Version 3
function Get-RubrikDatabaseFiles
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves all the data files for a SQL Server Database snapshot
            
      .DESCRIPTION
      The Get-RubrikDatabaseFiles cmdlet will return all the available databasem files for a database 
      snapshot. This is based on the recovery time for the database, as file locations could change
      between snapshots and log backups. If no date time is provided, the database's latest recovery
      point will be used

      ***WARNING***
      This is based on an internal endpoint and is subject to change by the REST API team.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikDatabaseFiles.html
            
      .EXAMPLE
      Get-RubrikDatabaseFiles -id '11111111-2222-3333-4444-555555555555'
      This will return files for database id  "11111111-2222-3333-4444-555555555555".

      .EXAMPLE
      Get-RubrikDatabaseMount -id '11111111-2222-3333-4444-555555555555' -RecoveryDateTime (Get-Date).AddDays(-1)
      This will return details on mount id "11111111-2222-3333-4444-555555555555" from a recovery point one day ago, assuming that recovery point exists.

      .EXAMPLE
      Get-RubrikDatabaseMount -id '11111111-2222-3333-4444-555555555555' -time '2017-08-08T01:15:00Z'
      This will return details on mount id "11111111-2222-3333-4444-555555555555" from UTC '2017-08-08 01:15:00', assuming that recovery point exists.
  #>

  [CmdletBinding()]
  Param(
    # Rubrik's id of the mount
    [Parameter(
      ParameterSetName='Time',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [Parameter(
      ParameterSetName='RecoveryDateTime',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$Id,
    # Recovery Point desired in the form of DateTime value
    [Parameter(ParameterSetName='RecoveryDateTime')]
    [ValidateNotNullOrEmpty()]
    [datetime]$RecoveryDateTime,
    # Recovery Point desired in the form of a UTC string (yyyy-MM-ddTHH:mm:ss)
    [Parameter(ParameterSetName='Time')]
    [ValidateNotNullOrEmpty()]
    [string]$time,
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName='Time')]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(ParameterSetName='Time')]
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

    Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    if($RecoveryDateTime){$time = $RecoveryDateTime.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')}

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

    # Recovery Point desired in the form of Epoch with Milliseconds


    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $Id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#Requires -Version 3
function Get-RubrikDatabaseMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on mounts for a SQL Server Database
            
      .DESCRIPTION
      The Get-RubrikMount cmdlet will accept one of several different query parameters
      and retireve the database Live Mount information for that criteria.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikDatabaseMount.html
            
      .EXAMPLE
      Get-RubrikDatabaseMount
      This will return details on all mounted databases.

      .EXAMPLE
      Get-RubrikDatabaseMount -id '11111111-2222-3333-4444-555555555555'
      This will return details on mount id "11111111-2222-3333-4444-555555555555".

      .EXAMPLE
      Get-RubrikDatabaseMount -source_database_id (Get-RubrikDatabase -HostName FOO -Instance MSSQLSERVER -Database BAR).id
      This will return details for any mounts found using the id value from a database named BAR on the FOO default instance.
                  
      .EXAMPLE
      Get-RubrikDatabaseMount -source_database_name BAR
      This returns any mounts where the source database is named BAR.

      .EXAMPLE
      Get-RubrikDatabaseMount -mounted_database_name BAR_LM
      This returns any mounts with the name BAR_LM
  #>

  [CmdletBinding()]
  Param(
    # Rubrik's id of the mount
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$Id,
    # Filters live mounts by database source id
    [Alias('Source_Database_Id')]
    [String]$SourceDatabaseId,
    # Filters live mounts by database source name
    [Alias('Source_Database_Name')]
    [String]$SourceDatabaseName, 
    # Filters live mounts by database source name
    [Alias('Target_Instance_Id')]
    [String]$TargetInstanceId, 
    # Filters live mounts by database source name
    [Alias('mounted_database_name')]
    [String]$MountedDatabaseName,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $Id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#requires -Version 3
function Get-RubrikDatabaseRecoverableRange
{
  <#  
      .SYNOPSIS
      Retrieves recoverable ranges for SQL Server databases.

      .DESCRIPTION
      The Get-RubrikDatabaseRecoverableRange cmdlet retrieves recoverable ranges for
      SQL Server databases protected by Rubrik. 

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikDatabase -Hostname FOO -Database BAR | Get-RubrikDatabaseRecoverableRange

      Retrieve all recoverable ranges for the BAR database on the FOO host.

      .EXAMPLE
      Get-RubrikDatabase -Hostname FOO -Database BAR | Get-RubrikDatabaseRecoverableRange -BeforeTime '2018-03-31T00:00:00.000Z'

      Retrieve all recoverable ranges for the BAR database on the FOO host after '2018-03-31T00:00:00.000Z'.

      .EXAMPLE
      Get-RubrikDatabase -Hostname FOO -Database BAR | Get-RubrikDatabaseRecoverableRange -EndDateTime '2018-04-01'

      Retrieve all recoverable ranges for the BAR database on the FOO host before '2018-04-01' after it's converted to UTC.

  #>

  [CmdletBinding()]
  Param(
    # Rubrik's database id value
    [Parameter(
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    #Range Start as datetime
    [datetime]$StartDateTime,
    #Range End as datetime
    [datetime]$EndDateTime,
    # After time/Start time of range in ISO8601 format (2016-01-01T01:23:45.678Z)
    [Alias('after_time')]
    [String]$AfterTime,
    # Before time/end time of range in ISO8601 format (2016-01-01T01:23:45.678Z)
    [Alias('before_time')]
    [String]$BeforeTime,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {
    #region oneoff
    if($StartDateTime){$AfterTime = $StartDateTime.ToUniversalTime().ToString('O')}
    if($EndDateTime){$BeforeTime = $EndDateTime.ToUniversalTime().ToString('O')}

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

    #region oneoff
    
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#requires -Version 3
function Get-RubrikEvent
{
  <#  
      .SYNOPSIS
      Retrieve information for events that match the value specified in any of the following categories: type, status, or ID, and limit events by date.

      .DESCRIPTION
      The Get-RubrikEvent cmdlet is used to pull a event data set from a Rubrik cluster. There are a vast number of arguments 
      that can be supplied to narrow down the event query. 

      .NOTES
      Written by J.R. Phillips for community usage
      GitHub: JayAreP     

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikEvent.html

      .EXAMPLE
      Get-RubrikEvent -ObjectName "vm-foo" -EventType Backup
      This will query for any 'Backup' events on the Rubrik VM object named 'vm-foo'

      .EXAMPLE
      Get-RubrikVM -Name jbrasser-win | Get-RubrikEvent -Limit 10
      Queries the Rubrik Cluster for any vms named jbrasser-win and return the last ten events for each VM found

      .EXAMPLE
      Get-RubrikEvent -EventType Archive -Limit 100
      This qill query the latest 100 Archive events on the currently logged in Rubrik cluster

      .EXAMPLE
      Get-RubrikHost -Name SQLFoo.demo.com | Get-RubrikEvent -EventType Archive
      This will feed any Archive events against the Rubrik Host object 'SQLFoo.demo.com' via a piped query. 

  #>

  [CmdletBinding()]
  Param(
    # Maximum number of events retrieved, default is to return 50 objects
    [parameter()]
    [int]$Limit = 50,
    # Earliest event retrieved
    [Alias('after_id')]
    [parameter()]
    [string]$AfterId,
    # Filter by Event Series ID 
    [Alias('event_series_id')]
    [parameter()]
    [string]$EventSeriesId,
    # Filter by Status. Enter any of the following values: 'Failure', 'Warning', 'Running', 'Success', 'Canceled', 'Canceling’.
    [ValidateSet('Failure', 'Warning', 'Running', 'Success', 'Canceled', 'Canceling', IgnoreCase = $false)]
    [parameter()]
    [string]$Status,
    # Filter by Event Type.
    [ValidateSet('Archive', 'Audit', 'AuthDomain', 'Backup', 'CloudNativeSource', 'Configuration', 'Diagnostic', 'Discovery', 'Instantiate', 'Maintenance', 'NutanixCluster', 'Recovery', 'Replication', 'StorageArray', 'StormResource', 'System', 'Vcd', 'VCenter', IgnoreCase = $false)]
    [Alias('event_type')]
    [parameter()]
    [string]$EventType,
    # Filter by a comma separated list of object IDs.
    [Alias('object_ids')]
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [array]$id,
    # Filter all the events according to the provided name using infix search for resources and exact search for usernames. 
    [Alias('object_name')]
    [parameter()]
    [string]$ObjectName,
    # Filter all the events before a date.
    [Alias('before_date')]
    [parameter()]
    [System.DateTime]$BeforeDate,
    # Filter all the events after a date.
    [Alias('after_date')]
    [parameter()]
    [System.DateTime]$AfterDate,
    # Filter all the events by object type. Enter any of the following values: 'VmwareVm', 'Mssql', 'LinuxFileset', 'WindowsFileset', 'WindowsHost', 'LinuxHost', 'StorageArrayVolumeGroup', 'VolumeGroup', 'NutanixVm', 'Oracle', 'AwsAccount', and 'Ec2Instance'. WindowsHost maps to both WindowsFileset and VolumeGroup, while LinuxHost maps to LinuxFileset and StorageArrayVolumeGroup.
    [Alias('object_type')]
    [parameter()]
    [string]$ObjectType,
    # A Boolean value that determines whether to show only on the most recent event in the series. When 'true' only the most recent event in the series are shown. When 'false' all events in the series are shown. The default value is 'true'.
    [Alias('show_only_latest')]
    [parameter()]
    [bool]$ShowOnlyLatest,
    # A Boolean value that determines whether to filter only on the most recent event in the series. When 'true' only the most recent event in the series are filtered. When 'false' all events in the series are filtered. The default value is 'true'.
    [Alias('filter_only_on_latest')]
    [parameter()]
    [bool]$FilterOnlyOnLatest,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI)
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    # Add 'date' property to the output by converting 'time' property to datetime object
    if (($null -ne $result) -and ($null -ne ($result | Select-Object -First 1).time)) {
      $result = $result | ForEach-Object {
        Select-Object -InputObject $_ -Property *,@{
          name = 'date'
          expression = {Convert-APIDateTime -DateTimeString $_.time}
        }
      }
    }
    
    return $result

  } # End of process
} # End of function
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
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikFileset.html

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
      Position = 0,
      ValueFromPipelineByPropertyName = $true)]
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
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
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
      for ($i = 0; $i -lt @($result).Count; $i++) {
        $Percentage = [int]($i/@($result).count*100)
        Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
        Get-RubrikFileset -id $result[$i].id
      }
    } else {
      return $result
    }

  } # End of process
} # End of function
#requires -Version 3
function Get-RubrikFilesetTemplate
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more fileset templates known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikFilesetTemplate cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of fileset templates

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikFilesetTemplate.html

      .EXAMPLE
      Get-RubrikFilesetTemplate -Name 'Template1'
      This will return details on all fileset templates named "Template1"

      .EXAMPLE
      Get-RubrikFilesetTemplate -OperatingSystemType 'Linux'
      This will return details on all fileset templates that can be used against a Linux operating system type

      .EXAMPLE
      Get-RubrikFilesetTemplate -id '11111111-2222-3333-4444-555555555555'
      This will return details on the fileset template matching id "11111111-2222-3333-4444-555555555555"
  #>

  [CmdletBinding()]
  Param(
    # Retrieve fileset templates with a name matching the provided name. The search is performed as a case-insensitive infix search.
    [Alias('FilesetTemplate')]
    [String]$Name,
    # Filter the summary information based on the operating system type of the fileset. Accepted values: 'Windows', 'Linux'
    [ValidateSet('Windows', 'Linux')]
    [Alias('operating_system_type')]
    [String]$OperatingSystemType,
    # Filter the summary information based on the share type of the fileset. Accepted values: 'NFS', 'SMB'
    [ValidateSet('NFS', 'SMB')]
    [Alias('share_type')]
    [String]$shareType,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,    
    # The ID of the fileset template
    [Parameter(ValueFromPipelineByPropertyName = $true)]    
    [String]$id,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#requires -Version 3
function Get-RubrikHost
{
  <#  
      .SYNOPSIS
      Retrieve summary information for all hosts that are registered with a Rubrik cluster.

      .DESCRIPTION
      The Get-RubrikHost cmdlet is used to retrive information on one or more hosts that are being protected with the Rubrik Backup Service or directly as with the case of NAS shares.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikHost.html

      .EXAMPLE
      Get-RubrikHost
      This will return all known hosts

      .EXAMPLE
      Get-RubrikHost -Hostname 'Server1'
      This will return details on any hostname matching "Server1"

      .EXAMPLE
      Get-RubrikHost -Type 'Windows' -PrimaryClusterID 'local'
      This will return details on all Windows hosts that are being protected by the local Rubrik cluster

      .EXAMPLE
      Get-RubrikHost -id 'Host:::111111-2222-3333-4444-555555555555'
      This will return details specifically for the host id matching "Host:::111111-2222-3333-4444-555555555555"
  
      .EXAMPLE
      Get-RubrikHost -Name myserver01 -DetailedObject
      This will return the Host object with all properties, including additional details such as information around the Volume Filter Driver if applicable. Using this switch parameter may negatively affect performance
  
      #>

  [CmdletBinding()]
  Param(
    # Retrieve hosts with a host name matching the provided name. The search type is infix
    [Alias('Hostname')]
    [String]$Name, 
    # Filter the summary information based on the operating system type. Accepted values are 'Windows', 'Linux', 'ANY', 'NONE'. Use NONE to only return information for hosts templates that do not have operating system type set. Use ANY to only return information for hosts that have operating system type set.
    [ValidateSet('Windows','Linux','Any','None')]
    [Alias('operating_system_type')]
    [String]$Type,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
    # ID of the registered host
    [String]$id,
    # DetailedObject will retrieved the detailed VM object, the default behavior of the API is to only retrieve a subset of the full VM object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
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
    # If the Get-RubrikHost function has been called with the -DetailedObject parameter a separate API query will be performed if the initial query was not based on ID
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      for ($i = 0; $i -lt @($result).count; $i++) {
        $Percentage = [int]($i/@($result).count*100)
        Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
        Get-RubrikHost -id $result[$i].id
      }
    } else {
      return $result
    }

  } # End of process
} # End of function
#requires -Version 3
function Get-RubrikHyperVVM
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more Hyper-V virtual machines known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikHyperVVM cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of Hyper-V virtual machines

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikHyperVVM -Name 'Server1'
      This will return details on all Hyper-V virtual machines named "Server1".

      .EXAMPLE
      Get-RubrikHyperVVM -Name 'Server1' -SLA Gold
      This will return details on all Hyper-V virtual machines named "Server1" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikHyperVVM -Relic
      This will return all removed Hyper-V virtual machines that were formerly protected by Rubrik.
  #>

  [CmdletBinding()]
  Param(
    # Name of the Hyper-V virtual machine
    [Parameter(
      ParameterSetName='Query',
      Position = 0,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('VM')]
    [String]$Name,
    # Filter results to include only relic (removed) virtual machines
    [Parameter(ParameterSetName='Query')]
    [Alias('is_relic')]    
    [Switch]$Relic,
    # SLA Domain policy assigned to the virtual machine
    [Parameter(ParameterSetName='Query')]
    [String]$SLA, 
    # Filter by SLA Domain assignment type
    [Parameter(ParameterSetName='Query')]
    [ValidateSet('Derived', 'Direct','Unassigned')]
    [String]$SLAAssignment,     
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Parameter(ParameterSetName='Query')]    
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,        
    # Virtual machine id
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # SLA id value
    [Parameter(ParameterSetName='Query')]
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,    
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
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

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Get-RubrikLDAP
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves the current Rubrik LDAP settings
            
      .DESCRIPTION
      The Get-RubrikLDAP cmdlet will retrieve the LDAP settings actively running on the system. This does require authentication.
            
      .NOTES
      Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Get-RubrikLDAP
      This will return the running LDAP settings on the currently connected Rubrik cluster
  #>

  [CmdletBinding()]
  Param(
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#requires -Version 3
function Get-RubrikLogShipping
{
  <#  
      .SYNOPSIS
      Retrieves all log shipping configuration objects. Results can be filtered and sorted.

      .DESCRIPTION
      Retrieves all log shipping configuration objects. Results can be filtered and sorted.

      .NOTES
      Written by Chris Lumnah
      Twitter: @lumnah
      GitHub: clumnah
      Any other links you'd like here

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get all log shipping configurations
        Get-RubrikLogShipping
        
      .EXAMPLE
      Get all log shipping configurations for a given database
        Get-RubrkLogShipping -PrimaryDatabase 'AdventureWorks2014' 

      .EXAMPLE
      Get all log shipping configurations for a given location (log shipping secondary server)
        Get-RubrkLogShipping -location am1-chrilumn-w1.rubrikdemo.com\MSSQLSERVER
  #>

  [CmdletBinding()]
  Param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
       
    [Alias('primary_database_id')]
    [String]$PrimaryDatabaseId,
    
    [Alias('primary_database_name')]
    [String]$PrimaryDatabaseName,
    
    [Alias('secondary_database_name')]
    [String]$SecondaryDatabaseName,
    
    #Log Shipping Target Server
    [String]$location,
    
    [ValidateSet("OK", "Broken", "Initializing", "Stale")]
    [String]$status,
    
    [String]$limit,
    
    [String]$offset,

    [ValidateSet("secondaryDatabaseName", "primaryDatabaseName", "lastAppliedPoint", "location")]
    [String]$sort_by,
    
    [ValidateSet("asc", "desc")]
    [String]$sort_order,

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

#requires -Version 3
function Get-RubrikManagedVolume
{
  <#  
      .SYNOPSIS
      Gets data on a Rubrik managed volume 

      .DESCRIPTION
      The Get-RubrikManagedVolume cmdlet is used to retrive information 
      on one or more managed volumes that are being protected 
      with Rubrik.

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikManagedVolume
      
      Retrieves all Rubrik Managed Volumes, active and relics

      .EXAMPLE
      Get-RubrikManagedVolume -Relic
      
      Retrieves all Rubrik Managed Volumes that are relics

      .EXAMPLE
      Get-RubrikManagedVolume -Relic:$false
      
      Retrieves all Rubrik Managed Volumes that are not relics

      .EXAMPLE
      Get-RubrikManagedVolume -name sqltest

      Get a managed volume named sqltest

      .EXAMPLE
      Get-RubrikManagedVolume -SLA 'Foo'

      Get all managed volumes protected by the 'Foo' SLA domain.

      .EXAMPLE
      Get-RubrikManagedVolume -Name 'Bar'
      
      Get the managed volume named 'Bar'.
  #>

  [CmdletBinding(DefaultParameterSetName = 'Name')]
  Param(
    # id of managed volume
    [Parameter(
      ParameterSetName='ID',
      Mandatory = $true,
      Position = 0,
      ValueFromPipelineByPropertyName = $true
    )]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Name of managed volume
    [Parameter(
      ParameterSetName='Name',
      Position = 0,
      ValueFromPipelineByPropertyName = $true
    )]
    [ValidateNotNullOrEmpty()]
    [String]$Name,
    # SLA name that the managed volume is protected under
    [Parameter(ParameterSetName='Name')]
    [Parameter(ParameterSetName='ID')]
    [ValidateNotNullOrEmpty()]
    [String]$SLA,
    # SLA id that the managed volume is protected under
    [Parameter(ParameterSetName='Name')]
    [Parameter(ParameterSetName='ID')]
    [Alias('effective_sla_domain_id')]
    [ValidateNotNullOrEmpty()]
    [String]$SLAID,
    # Filter results to include only relic (removed) databases
    [Parameter(ParameterSetName='Name')]
    [Parameter(ParameterSetName='ID')]
    [Alias('is_relic')]
    [Switch]$Relic,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use local as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [Parameter(ParameterSetName='Name')]
    [Parameter(ParameterSetName='ID')]
    [ValidateNotNullOrEmpty()]
    [String]$PrimaryClusterID,
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
  
    # If the switch parameter was not explicitly specified remove from query params 
    if(-not $PSBoundParameters.ContainsKey('Relic')) {
      $Resources.Query.Remove('is_relic')
    }
  }

  Process {

    #region One-off
    if($SLA){
      $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#requires -Version 3
function Get-RubrikManagedVolumeExport
{
  <#  
      .SYNOPSIS
      Gets data on a Rubrik managed volume 

      .DESCRIPTION
      The Get-RubrikManagedVolumeExport cmdlet is used to retrive information 
      on one or more managed volume exports.

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikManagedVolumeExport

      Return all managed volume exports (live mounts).

      .EXAMPLE
      Get-RubrikManagedVolumeExport -SourceManagedVolumeName 'foo'

      Return all managed volume exports (live mounts) for the 'foo' managed volume.      
  #>

  [CmdletBinding()]
  Param(
    # id of managed volume
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    #ID of the source managed volume
    [Alias('$source_managed_volume_id')]
    [String]$SourceManagedVolumeID,
    #Name of the source managed volume
    [Alias('$source_managed_volume_name')]
    [String]$SourceManagedVolumeName,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
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
#Requires -Version 3
function Get-RubrikMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on mounts for a VM
            
      .DESCRIPTION
      The Get-RubrikMount cmdlet will accept a VM id and return details on any mount operations that are active within Rubrik
      Due to the nature of names not being unique
      Note that this function requires the VM ID value, not the name of the virtual machine, since virtual machine names are not unique.
      It is suggested that you first use Get-RubrikVM to narrow down the one or more virtual machines you wish to query, and then pipe the results to Get-RubrikMount.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikMount.html
            
      .EXAMPLE
      Get-RubrikMount
      This will return details on all mounted virtual machines.

      .EXAMPLE
      Get-RubrikMount -id '11111111-2222-3333-4444-555555555555'
      This will return details on mount id "11111111-2222-3333-4444-555555555555".

      .EXAMPLE
      Get-RubrikMount -VMID (Get-RubrikVM -VM 'Server1').id
      This will return details for any mounts found using the id value from a virtual machine named "Server1" as a base reference.
                  
      .EXAMPLE
      Get-RubrikMount -VMID 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
      This will return details for any mounts found using the virtual machine id of 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345' as a base reference.
  #>

  [CmdletBinding()]
  Param(
    # Rubrik's id of the mount
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Filters live mounts by VM ID
    [Alias('vm_id')]
    [String]$VMID,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#requires -Version 3
function Get-RubrikNASShare
{
  <#  
      .SYNOPSIS
      Get information on NAS shares.

      .DESCRIPTION
      Get all information for NAS shares configured within Rubrik.

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikNASShare -ShareType 'SMB'

      Get all SMB NAS Shares

      .EXAMPLE
      Get-RubrikHost -name 'FOO'  | Get-RubrikNASShare

      Get all NAS Shares attached to host 'FOO'.
  #>

  [CmdletBinding()]
  Param(
    # NAS Share ID
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$ID,
    # Host ID associated with the share
    [Alias('host_id')]
    [string]$HostID,
    #Share type (NFS or SMB)
    [ValidateSet('NFS','SMB')]
    [Alias('share_type')]
    [String]$ShareType,
    #Host name
    [String]$HostName,
    #export point
    [String]$exportPoint,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,
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
#requires -Version 3
function Get-RubrikNutanixVM
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more Nutanix (AHV) virtual machines known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikNutanixVM cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of Nutanix (AHV) virtual machines

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikNutanixVM -Name 'Server1'
      This will return details on all Nutanix (AHV) virtual machines named "Server1".

      .EXAMPLE
      Get-RubrikNutanixVM -Name 'Server1' -SLA Gold
      This will return details on all Nutanix (AHV) virtual machines named "Server1" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikNutanixVM -Relic
      This will return all removed Nutanix (AHV) virtual machines that were formerly protected by Rubrik.
  #>

  [CmdletBinding()]
  Param(
    # Name of the Nutanix (AHV) virtual machine
    [Parameter(
      ParameterSetName='Query',
      Position = 0,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('VM')]
    [String]$Name,
    # Filter results to include only relic (removed) virtual machines
    [Parameter(ParameterSetName='Query')]
    [Alias('is_relic')]    
    [Switch]$Relic,
    # SLA Domain policy assigned to the virtual machine
    [Parameter(ParameterSetName='Query')]
    [String]$SLA, 
    # Filter by SLA Domain assignment type
    [Parameter(ParameterSetName='Query')]
    [ValidateSet('Derived', 'Direct','Unassigned')]
    [String]$SLAAssignment,     
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Parameter(ParameterSetName='Query')]    
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,        
    # Virtual machine id
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # SLA id value
    [Parameter(ParameterSetName='Query')]
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,    
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
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

    return $result

  } # End of process
} # End of function

#requires -Version 3
function Get-RubrikOracleDB
{
  <#  
    .SYNOPSIS
    Retrieves details on one or more Oracle DBs known to a Rubrik cluster

    .DESCRIPTION
    The Get-RubrikOracleDB cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of Oracle DBs
    
    .NOTES
    Written by Jaap Brasser for community usage
    Twitter: @jaap_brasser
    GitHub: jaapbrasser
    
    .LINK
    http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikOracleDB.html
    
    .EXAMPLE
    Get-RubrikOracleDB -Name 'OracleDB1'
    This will return details on all Oracle DBs named "OracleDB1".
    
    .EXAMPLE
    Get-RubrikOracleDB -Name 'OracleDB1' -SLA Gold
    This will return details on all Oracle DBs named "OracleDB1" that are protected by the Gold SLA Domain.
    
    .EXAMPLE
    Get-RubrikOracleDB -Relic
    This will return all removed Oracle DBs that were formerly protected by Rubrik.
    
    .EXAMPLE
    Get-RubrikOracleDB -Name OracleDB1 -DetailedObject
    This will return the Oracle DB object with all properties, including additional details such as snapshots taken of the Oracle DB. Using this switch parameter negatively affects performance as more API queries will be performed.
  #>

  [CmdletBinding()]
  Param(
    # Name of the Oracle DB
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [String]$Name,
    # Filter results to include only relic (removed) Oracle DBs
    [Alias('is_relic')]    
    [Switch]$Relic,
    [Alias('is_live_mount')]    
    [Switch]$LiveMount,
    # DetailedObject will retrieved the detailed VM object, the default behavior of the API is to only retrieve a subset of the full VM object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Switch]$DetailedObject,
    # SLA Domain policy assigned to the Oracle DB
    [String]$SLA, 
    # Filter by SLA Domain assignment type
    [Alias('sla_assignment')]
    [ValidateSet('Derived', 'Direct','Unassigned')]
    [String]$SLAAssignment,     
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,        
    # Oracle DB id
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # SLA id value
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,    
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

    #region One-off
    if ($SLAID.Length -eq 0 -and $SLA.Length -gt 0) {
      $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    # If the Get-RubrikOracleDB function has been called with the -DetailedObject parameter a separate API query will be performed if the initial query was not based on ID
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      for ($i = 0; $i -lt @($result).count; $i++) {
        $Percentage = [int]($i/@($result).count*100)
        Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
        Get-RubrikOracleDB -id $result[$i].id
      }
    } else {
      return $result
    }

  } # End of process
} # End of function

#requires -Version 3
function Get-RubrikOrganization
{
  <#  
      .SYNOPSIS
      Returns a list of all organizations.

      .DESCRIPTION
      This cmdlet returns all the organizations within Rubrik. Organizations are used to support
      Rubrik's multi-tenancy feature. 

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikOrganization

      Returns a complete list of all Rubrik organizations.
  #>

  [CmdletBinding()]
  Param(
    # Organization ID
    [String]$id,
    # Organization Name
    [String]$name,
    # Filter results on if the org is global or not
    [Alias('is_global')]
    [bool]$isGlobal,    
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
#requires -Version 3
function Get-RubrikReport
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more reports created in Rubrik Envision

      .DESCRIPTION
      The Get-RubrikReport cmdlet is used to pull information on any number of Rubrik Envision reports

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikReport.html

      .EXAMPLE
      Get-RubrikReport
      This will return details on all reports
      
      .EXAMPLE
      Get-RubrikReport -Name 'SLA' -Type Custom
      This will return details on all custom reports that contain the string "SLA"

      .EXAMPLE
      Get-RubrikReport -id '11111111-2222-3333-4444-555555555555'
      This will return details on the report id "11111111-2222-3333-4444-555555555555"
  #>

  [CmdletBinding()]
  Param(
    # Filter the returned reports based off their name.
    [Alias('search_text')]
    [String]$Name,
    # Filter the returned reports based off the reports type. Options are Canned and Custom.
    [ValidateSet('Canned', 'Custom')]
    [Alias('report_type')]
    [String]$Type,
    # The ID of the report.
    [Parameter(ValueFromPipelineByPropertyName = $true)]    
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

#requires -Version 3
function Get-RubrikReportData
{
  <#  
      .SYNOPSIS
      Retrieve table data for a specific Envision report

      .DESCRIPTION
      The Get-RubrikReportData cmdlet is used to pull table data from a specific Envision report

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikReportData.html

      .EXAMPLE
      Get-RubrikReport -Name 'SLA Compliance Summary' | Get-RubrikReportData
      This will return table data from the "SLA Compliance Summary" report

      .EXAMPLE
      Get-RubrikReport -Name 'SLA Compliance Summary' | Get-RubrikReportData -ComplianceStatus 'NonCompliance'
      This will return table data from the "SLA Compliance Summary" report when the compliance status is "NonCompliance"

      .EXAMPLE
      Get-RubrikReport -Name 'SLA Compliance Summary' | Get-RubrikReportData -ComplianceStatus 'NonCompliance' -Limit 10
      This will return table data from the "SLA Compliance Summary" report when the compliance status is "NonCompliance", only returns the first 10 results.
  #>

  [CmdletBinding()]
  Param(
    # The ID of the report
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]    
    [String]$id,
    # Search table data by object name
    [Alias('search_value')]
    [String]$Name,
    # Filter table data on task type
    [Alias('task_type')]
    [String]$TaskType,
    # Filter table data on task status
    [Alias('task_status')]
    [String]$TaskStatus,
    # Filter table data on object type
    [Alias('object_type')]
    [String]$ObjectType,
    # Filter table data on compliance status
    [Alias('compliance_status')]
    [ValidateSet('InCompliance','NonCompliance')]
    [String]$ComplianceStatus,  
    #limit the number of rows returned, defaults to maximum pageSize of 9999
    [int]$limit,
    #cursor start (if necessary)
    [string]$cursor,
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
  
    # Set limit to default of 9999 if not set, both limit and psboundparameters are set, this is because New-BodyString builds the query using both variables
    if ($null -eq $PSBoundParameters.limit) {
      $PSBoundParameters.Add('limit',9999) | Out-Null
      $limit = 9999
    }
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

#Requires -Version 3
function Get-RubrikRequest 
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on an async request
            
      .DESCRIPTION
      The Get-RubrikRequest cmdlet will pull details on a request that was submitted to the distributed task framework.
      This is helpful for tracking the state (success, failure, running, etc.) of a request.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikRequest.html
            
      .EXAMPLE
      Get-RubrikRequest -id 'MOUNT_SNAPSHOT_123456789:::0' -Type 'vmware/vm'
      Will return details about an async VMware VM request named "MOUNT_SNAPSHOT_123456789:::0"
  #>

  [CmdletBinding()]
  Param(
    # ID of an asynchronous request
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # The type of request
    [Parameter(Mandatory = $true)]
    [ValidateSet('fileset','mssql','vmware/vm','hyperv/vm','managed_volume')]
    [String]$Type,    
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

    #region one-off
    $uri = $uri -replace '{type}', $Type
    #Place any internal API request calls into this collection, the replace will fix the URI
    $internaltypes = @('managed_volume')
    if($internaltypes -contains $Type){
      $uri = $uri -replace 'v1', 'internal'
    }
    #endregion

    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Get-RubrikSetting
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves the current Rubrik cluster settings
            
      .DESCRIPTION
      The Get-RubrikSetting cmdlet will retrieve the cluster settings actively running on the system. This does require authentication.
            
      .NOTES
      Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Get-RubrikSetting
      This will return the running cluster settings on the currently connected Rubrik cluster
  #>

  [CmdletBinding()]
  Param(
    # ID of the Rubrik cluster or me for self
    [String]$id = 'me',
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

#Requires -Version 3
function Get-RubrikSLA 
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on SLA Domain(s)
            
      .DESCRIPTION
      The Get-RubrikSLA cmdlet will query the Rubrik API for details on all available SLA Domains.
      Information on each domain will be reported to the console.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikSLA.html
            
      .EXAMPLE
      Get-RubrikSLA
      Will return all known SLA Domains
            
      .EXAMPLE
      Get-RubrikSLA -Name 'Gold'
      Will return details on the SLA Domain named Gold
  #>

  [CmdletBinding()]
  Param(
    # Name of the SLA Domain
    [Parameter(
      ParameterSetName='Query',
      Position = 0,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('SLA')]
    [String]$Name,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,    
    # SLA Domain id
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]    
    [String]$id, 
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
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
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikSnapshot.html
      
      .EXAMPLE
      Get-RubrikSnapshot -id 'VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345'
      This will return all snapshot (backup) data for the virtual machine id of "VirtualMachine:::aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-vm-12345"

      .EXAMPLE
      Get-RubrikSnapshot -id 'Fileset:::01234567-8910-1abc-d435-0abc1234d567'
      This will return all snapshot (backup) data for the fileset with id of "Fileset:::01234567-8910-1abc-d435-0abc1234d567"

      .EXAMPLE
      Get-Rubrikvm 'Server1' | Get-RubrikSnapshot -Date '03/21/2017'
      This will return the closest matching snapshot, within 1 day, to March 21st, 2017 for any virtual machine named "Server1"

      .EXAMPLE
      Get-Rubrikvm 'Server1' | Get-RubrikSnapshot -Date '03/21/2017' -Range 3
      This will return the closest matching snapshot, within 3 days, to March 21st, 2017 for any virtual machine named "Server1"

      .EXAMPLE
      Get-Rubrikvm 'Server1' | Get-RubrikSnapshot -Date '03/21/2017' -Range 3 -ExactMatch
      This will return the closest matching snapshot, within 3 days, to March 21st, 2017 for any virtual machine named "Server1". -ExactMatch specifies that no results are returned if a match is not found, otherwise all snapshots are returned.

      .EXAMPLE
      Get-Rubrikvm 'Server1' | Get-RubrikSnapshot -Date (Get-Date)
      This will return the closest matching snapshot to the current date and time for any virtual machine named "Server1"

      .EXAMPLE
      Get-Rubrikvm 'Server1' | Get-RubrikSnapshot -Latest
      This will return the latest snapshot for the virtual machine named "Server1"

      .EXAMPLE
      Get-RubrikDatabase 'DB1' | Get-RubrikSnapshot -OnDemandSnapshot
      This will return the details on any on-demand (user initiated) snapshot to for any database named "DB1"
  #>

  [CmdletBinding()]
  Param(
    # Rubrik id of the protected object
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true,ParameterSetName='Query')]
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true,ParameterSetName='Date')]
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true,ParameterSetName='Latest')]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Filter results based on where in the cloud the snapshot lives
    [Int]$CloudState,
    # Filter results to show only snapshots that were created on demand
    [Switch]$OnDemandSnapshot,
    # Date of the snapshot
    [Parameter(Mandatory = $true,ParameterSetName='Date')]
    [ValidateNotNullOrEmpty()]
    [Datetime]$Date,
    # Range of how many days away from $Date to search for the closest matching snapshot. Defaults to one day.
    [Parameter(ParameterSetName='Date')]
    [Int]$Range = 1,
    # Return no results if a matching date isn't found. Otherwise, all snapshots are returned if no match is made.
    [Parameter(ParameterSetName='Date')]
    [Switch]$ExactMatch,    
    # Return the latest snapshot
    [Parameter(Mandatory = $true,ParameterSetName='Latest')]
    [Switch]$Latest,
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

    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    
    # Exclusion for FileSet because limited API endpoint functionality, using expanded properties to gather snapshot details
    if ($uri -match 'v1/fileset') {
      $result = (Get-RubrikFileset -Id $Id).snapshots
    } else {
      $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
      $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    }    

    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    
    #region One-off
    if ($Date) 
    {
      $datesearch = Test-DateDifference -Date $($result.date) -Compare $Date -Range $Range
      # If $datesearch is $null, a matching date was not found. If $ExactMatch is specified in this case, return $null
      if($null -eq $datesearch -and $ExactMatch) {
        $result = $null
      }
      else {
        $result = Test-ReturnFilter -Object $datesearch -Location 'date' -result $result
      }
    } 
    elseif ($Latest) {
      $datesearch = Test-DateDifference -Date $($result.date) -Compare (Get-Date) -Range 999999999
      # If $datesearch is $null, a matching date was not found, so return $null
      if($null -eq $datesearch) {
        $result = $null
      }
      else {
        $result = Test-ReturnFilter -Object $datesearch -Location 'date' -result $result
      }
    } 
    #endregion
    
    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Get-RubrikSoftwareVersion
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves the current software version
            
      .DESCRIPTION
      The Get-RubrikVersion cmdlet will retrieve the version of code that is actively running on the system. This does not require authentication.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikSoftwareVersion.html
            
      .EXAMPLE
      Get-RubrikSoftwareVersion -Server 192.168.1.100
      This will return the running software version on the Rubrik cluster reachable at the address 192.168.1.100
  #>

  [CmdletBinding()]
  Param(
    # Rubrik server IP or FQDN
    [Parameter(Mandatory = $true)]    
    [String]$Server,
    # ID of the Rubrik cluster or me for self
    [String]$id = 'me',
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = 'v1'
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
  
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#requires -Version 3
function Get-RubrikSQLInstance
{
<#  
    .SYNOPSIS
    Gets internal Rubrik object that represents a SQL Server instance

    .DESCRIPTION
    Returns internal Rubrik object that represents a SQL Server instance. This 

    .NOTES
    Written by Mike Fal for community usage
    Twitter: @Mike_Fal
    GitHub: MikeFal

    .LINK
    http://rubrikinc.github.io/rubrik-sdk-for-powershell/

    .EXAMPLE
    Get-RubrikSQLInstance -Name MSSQLSERVER
    Retrieve all default SQL instances managed by Rubrik

    .EXAMPLE
    Get-RubrikSQLInstance -ServerInstance msf-sql2016
    Retrieve the default SQL instance on host msf-sql2016

    .EXAMPLE
    Get-RubrikSQLInstance -Hostname msf-sql2016
    Retrieves all the SQL instances on host msf-sql2016

    .EXAMPLE
    Get-RubrikSQLInstance -PrimaryClusterID local
    Only return SQLInstances of the Rubrik cluster that is hosting the current REST API session.

    .EXAMPLE
    Get-RubrikSQLInstance -PrimaryClusterID 8b4fe6f6-cc87-4354-a125-b65e23cf8c90
    Only return SQLInstances of the specified id of the Rubrik cluster that is hosting the current REST API session.
#>

  [CmdletBinding()]
  Param(
       # Name of the instance
       [Alias('InstanceName')]
       [String]$Name,
       # SLA Domain policy assigned to the database
       [String]$SLA,  
       # Name of the database host
       [String]$Hostname,
       #ServerInstance name (combined hostname\instancename)
       [String]$ServerInstance,
       # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use: local as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
       [Alias('primary_cluster_id')]
       [String]$PrimaryClusterID,    
       # Rubrik's database id value
       [Parameter(ValueFromPipelineByPropertyName = $true)]
       [String]$id,
       # SLA id value
       [String]$SLAID,     
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
  
    #region one-off
    if($ServerInstance){
        $SIobj = ConvertFrom-SqlServerInstance $ServerInstance
        $Hostname = $SIobj.hostname
        $Name = $SIobj.instancename
    }
    #endregion
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

#requires -Version 3
function Get-RubrikSupportTunnel
{
  <#  
      .SYNOPSIS
      Checks the status of the Support Tunnel

      .DESCRIPTION
      The Get-RubrikSupportTunnel cmdlet is used to query the Rubrik cluster to determine the status of the Support Tunnel
      This tunnel is used by Rubrik's support team for providing remote assistance and is toggled on or off by the cluster administrator

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikSupportTunnel
      This will return details on the configuration of the Support Tunnel for the currently connected Rubrik cluster
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
#requires -Version 3
function Get-RubrikUnmanagedObject
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more unmanaged objects known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikUnmanagedObject cmdlet is used to pull details on any unmanaged objects that has been stored in the cluster
      In most cases, this will be on-demand snapshots that are associated with an object (virtual machine, fileset, database, etc.)

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikUnmanagedObject.html

      .EXAMPLE
      Get-RubrikUnmanagedObject -Type 'WindowsFileset'
      This will return details on any filesets applied to Windows Servers that have unmanaged snapshots associated

      .EXAMPLE
      Get-RubrikUnmanagedObject -Status 'Unprotected' -Name 'Server1'
      This will return details on any objects named "Server1" that are currently unprotected and have unmanaged snapshots associated
  #>

  [CmdletBinding()]
  Param(
    # Search object by object name.
    [Alias('search_value')]
    [String]$Name,
    # Filter by the type of the object. If not specified, will return all objects. Valid attributes are Protected, Relic and Unprotected
    [Alias('unmanaged_status')]
    [ValidateSet('Protected','Relic','Unprotected')]
    [String]$Status,
    # The type of the unmanaged object. This may be VirtualMachine, MssqlDatabase, LinuxFileset, or WindowsFileset.
    [Alias('object_type')]
    [ValidateSet('VirtualMachine','MssqlDatabase','LinuxFileset','WindowsFileset')]
    [String]$Type,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Get-RubrikVCenter
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves the current Rubrik vCenter settings
            
      .DESCRIPTION
      The Get-RubrikVCenter cmdlet will retrieve the all vCenter settings actively running on the system. This does require authentication.
            
      .NOTES
      Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Get-RubrikVCenter
      This will return the vCenter settings on the currently connected Rubrik cluster
  #>

  [CmdletBinding()]
  Param(
    # vCenter Name
    [String]$Name,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,  
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Get-RubrikVersion
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves the current version
            
      .DESCRIPTION
      The Get-RubrikVersion cmdlet will retrieve the version of code that is actively running on the system.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikVersion.html
            
      .EXAMPLE
      Get-RubrikVersion
      This will return the running version on the Rubrik cluster
  #>

  [CmdletBinding()]
  Param(
    # ID of the Rubrik cluster or me for self
    [String]$id = 'me',
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#requires -Version 3
function Get-RubrikVM
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more virtual machines known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikVM cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of virtual machines

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikVM.html

      .EXAMPLE
      Get-RubrikVM -Name 'Server1'
      This will return details on all virtual machines named "Server1".

      .EXAMPLE
      Get-RubrikVM -Name 'Server1' -SLA Gold
      This will return details on all virtual machines named "Server1" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikVM -Relic
      This will return all removed virtual machines that were formerly protected by Rubrik.

      .EXAMPLE
      Get-RubrikVM -Name myserver01 -DetailedObject
      This will return the VM object with all properties, including additional details such as snapshots taken of the VM. Using this switch parameter negatively affects performance 
  #>

  [CmdletBinding(DefaultParameterSetName = 'Query')]
  Param(
    # Name of the virtual machine
    [Parameter(
      ParameterSetName='Query',
      Position = 0,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('VM')]
    [String]$Name,
    # Virtual machine id
    [Parameter(
      ParameterSetName='ID',
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Filter results to include only relic (removed) virtual machines
    [Parameter(ParameterSetName='Query')]
    [Alias('is_relic')]    
    [Switch]$Relic,
    # DetailedObject will retrieved the detailed VM object, the default behavior of the API is to only retrieve a subset of the full VM object unless we query directly by ID. Using this parameter does affect performance as more data will be retrieved and more API-queries will be performed.
    [Parameter(ParameterSetName='Query')]
    [Switch]$DetailedObject,
    # SLA Domain policy assigned to the virtual machine
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [String]$SLA, 
    # Filter by SLA Domain assignment type
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Derived', 'Direct','Unassigned')]
    [Alias('sla_assignment')]
    [String]$SLAAssignment,     
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,        
    # SLA id value
    [Parameter(ParameterSetName='Query')]
    [ValidateNotNullOrEmpty()]
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,    
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [Parameter(ParameterSetName='Query')]
    [Parameter(ParameterSetName='ID')]
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
    if ($SLAID.Length -eq 0 -and $SLA.Length -gt 0) {
      $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    # If the Get-RubrikVM function has been called with the -DetailedObject parameter a separate API query will be performed if the initial query was not based on ID
    if (($DetailedObject) -and (-not $PSBoundParameters.containskey('id'))) {
      for ($i = 0; $i -lt @($result).Count; $i++) {
        $Percentage = [int]($i/@($result).count*100)
        Write-Progress -Activity "DetailedObject queries in Progress, $($i+1) out of $(@($result).count)" -Status "$Percentage% Complete:" -PercentComplete $Percentage
        Get-RubrikVM -id $result[$i].id
      }
    } else {
      return $result
    }

  } # End of process
} # End of function

#requires -Version 3
function Get-RubrikVMSnapshot
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more virtual machines known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikVMSnapshot cmdlet is used to pull a detailed information from a VM snapshot

      .NOTES
      Written by Pierre Flammer for community usage
      Twitter: @PierreFlammer

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikVMSnapshot -id 'cc1b363a-a0d4-40b7-9b09-7b8f3a805b27'
      This will return details on the specific snapshot.
  #>

  [CmdletBinding()]
  Param(
    [Parameter(ValueFromPipelineByPropertyName = $true)]
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

#Requires -Version 3
function Get-RubrikVMwareDatastore
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves a list of VMware datastores
            
      .DESCRIPTION
      The Get-RubrikVMwareDatastore cmdlet will retrieve VMware datastores known to an authenticated Rubrik cluster.
            
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikVMwareDatastore.html
            
      .EXAMPLE
      Get-RubrikVMwareDatastore
      This will return a listing of all of the datastores known to a connected Rubrik cluster
      
      .EXAMPLE
      Get-RubrikVMwareDatastore -Name 'vSAN'
      This will return a listing of all of the datastores named 'vSAN' known to a connected Rubrik cluster
      
      .EXAMPLE
      Get-RubrikVMwareDatastore -DatastoreType 'NFS'
      This will return a listing of all of the NFS datastores known to a connected Rubrik cluster
  #>

  [CmdletBinding()]
  Param(
    # Datastore Name
    [String]$Name,
    # Filter Datastore type
    [ValidateSet('VMFS', 'NFS','vSAN')]
    [String]$DatastoreType,     
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Get-RubrikVMwareHost
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves a list of ESXi hosts registered
            
      .DESCRIPTION
      The Get-RubrikVMwareHost cmdlet will retrieve all of the registered ESXi hosts within the authenticated Rubrik cluster.
            
      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Get-RubrikVMwareHost.html
            
      .EXAMPLE
      Get-RubrikVMwareHost
      This will return a listing of all of the ESXi hosts known to the connected Rubrik cluster

      Get-RubrikVMwareHost -PrimarClusterId local
      This will return a listing of all of the ESXi hosts whose primary cluster is that of the connected Rubrik cluster.

      .EXAMPLE
      Get-RubrikVMwareHost -Name 'esxi01'
      This will return a listing of all of the ESXi hosts named 'esxi01' registered with the connected Rubrik cluster
  #>

  [CmdletBinding()]
  Param(
    # ESXi Host Name
    [String]$Name,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use 'local' as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,  
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#requires -Version 3
function Get-RubrikVolumeGroup
{
  <#  
      .SYNOPSIS
      Retrieves details on one or more volume groups known to a Rubrik cluster

      .DESCRIPTION
      The Get-RubrikVolumeGroup cmdlet is used to pull a detailed data set from a Rubrik cluster on any number of volume groups

      .NOTES
      Written by Pierre Flammer for community usage
      Twitter: @PierreFlammer

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikVolumeGroup -Name 'Server1'
      This will return details on all volume groups from host "Server1".

      .EXAMPLE
      Get-RubrikVolumeGroup -Name 'Server1' -SLA Gold
      This will return details on all volume groups of "Server1" that are protected by the Gold SLA Domain.

      .EXAMPLE
      Get-RubrikVolumeGroup -Relic
      This will return all removed volume groups that were formerly protected by Rubrik.
  #>

  [CmdletBinding()]
  Param(
    # Name of the volume group
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [Alias('VolumeGroup')]
    [String]$name,
    # Filter results to include only relic (removed) volume groups
    [Alias('is_relic')]    
    [Switch]$Relic,
    # SLA Domain policy assigned to the volume group
    [String]$SLA, 
    # Filter the summary information based on the primarycluster_id of the primary Rubrik cluster. Use **_local** as the primary_cluster_id of the Rubrik cluster that is hosting the current REST API session.
    [Alias('primary_cluster_id')]
    [String]$PrimaryClusterID,        
    # Volume group id
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # SLA id value
    [Alias('effective_sla_domain_id')]
    [String]$SLAID,    
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

    return $result

  } # End of process
} # End of function

#Requires -Version 3
function Get-RubrikVolumeGroupMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and retrieves details on mounts of volume groups
            
      .DESCRIPTION
      The Get-RubrikVolumeGroupMount cmdlet will accept a volume group id or the name of the source_host.
      It returns details on any mount operations that are active within Rubrik.
            
      .NOTES
      Written by Pierre Flammer for community usage
      Twitter: @PierreFlammer
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/
            
      .EXAMPLE
      Get-RubrikVolumeGroupMount
      This will return details on all mounted volume groups.

      .EXAMPLE
      Get-RubrikVolumeGroupMount -id '11111111-2222-3333-4444-555555555555'
      This will return details on mount id "11111111-2222-3333-4444-555555555555".

      .EXAMPLE
      Get-RubrikVolumeGroupMount -source_host win-server01
      This will return details for any mounts found where the source host is win-server01
                  
      .EXAMPLE
      Get-RubrikVolumeGroupMount | Where-Object {$_.targetHostName -eq 'recover-01'}
      This will return details for any mounts found that are mounted on the server recover-01
  #>

  [CmdletBinding()]
  Param(
    # Rubrik's id of the mount
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Filters live mounts by VM ID
    [String]$source_host,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

function Invoke-RubrikRESTCall {
<#
      .SYNOPSIS
      Provides generic interface to make Rubrik REST API calls

      .DESCRIPTION
      The Invoke-RubrikRESTCall allows users to make raw API endpoint calls to the Rubrik REST interface. The user
      will need to manage the format of both the endpoint call(including resource ids) and body, but provides the
      option to make cmdlet independent API calls for automating Rubrik actions through PowerShell. The Rubrik API
      reference is found on the Rubrik device at:
        <Rubrik IP>/docs/v1
        <Rubrik IP>/docs/v1/playground

      .NOTES
      Written by Matt Altimar & Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: mikefal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Invoke-RubrikRESTCall.html

      .EXAMPLE
      Invoke-RubrikRESTCall -Endpoint 'vmware/vm' -Method GET

      Retrieve the raw output for all VMWare VMs being managed by the Rubrik device.

      .EXAMPLE
      Invoke-RubrikRESTCall -Endpoint 'vmware/vm' -Method GET -Query @{'name'='msf-sql2016'}

      Retrieve the raw output for the VMWare VM msf-sql2016 using a query parameter.

      .EXAMPLE
      $body = New-Object -TypeName PSObject -Property @{'slaID'='INHERIT';'ForceFullSnapshot'='FALSE'}
      Invoke-RubrikRESTCall -Endpoint 'vmware/vm/VirtualMachine:::fbcb1f51-9520-4227-a68c-6fe145982f48-vm-649/snapshot' -Method POST -Body $body

      Execute an on-demand snapshot for the VMWare VM where the id is part of the endpoint.
  #>

  [cmdletbinding()]
  Param (
      #Rubrik API endpoint, DO NOT USE LEADING '/'
      [Parameter(Mandatory = $true,HelpMessage = 'REST Endpoint')]
      [ValidateNotNullorEmpty()]
      [System.String]$Endpoint,
      #REST API method
      [Parameter(Mandatory = $true,HelpMessage = 'REST Method')]
      [ValidateSET('GET','PUT','PATCH','DELETE','POST','HEAD','OPTIONS')]
      [System.String]$Method,
      #Hash table body to pass to API call
      [Parameter(Mandatory = $false,HelpMessage = 'REST Content')]
      [ValidateNotNullorEmpty()]
      [psobject]$Query,
      #Hash table body to pass to API call
      [Parameter(Mandatory = $false,HelpMessage = 'REST Content')]
      [ValidateNotNullorEmpty()]
      [psobject]$Body,
      # Rubrik server IP or FQDN
      [String]$Server = $global:RubrikConnection.server,
      # API version
      [ValidateNotNullorEmpty()]
      [String]$api = $global:RubrikConnection.api
  )
  BEGIN
  {
    #connect to Rubrik if not already connected
    Test-RubrikConnection
  }

  PROCESS
  {
    #execute REST operation
    try {

        if($api -ne 'internal')
        {
            $api = "v$api"
        }

        #construct uri
        [string]$uri = New-URIString -server $Server -endpoint "/api/$api/$Endpoint"

        #If query object, add query parameters to URI
        if($query)
        {
            $querystring = @()
            foreach($q in $query.Keys)
            {
                $querystring += "$q=$($query[$q])"
            }
            $uri = New-QueryString -query $querystring -uri $uri
        }

        #If Method is not a GET call and a REST Body is passed, build the JSON body
        if($Method -ne 'GET' -and $body){
            [string]$JsonBody = $Body | ConvertTo-Json -Depth 10
        }
        Write-Verbose "URI string: $uri"

        $result = Submit-Request -uri $uri -header $Header -method $Method -body $JsonBody
    }
    catch {
        throw $_
    }

    return $result
  }
}
#Requires -Version 3
function Move-RubrikMountVMDK
{
  <#  
      .SYNOPSIS
      Moves the VMDKs from a Live Mount to another VM

      .DESCRIPTION
      The Move-RubrikMountVMDK cmdlet is used to attach VMDKs from a Live Mount to another VM, typically for restore or testing purposes.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Move-RubrikMountVMDK.html

      .EXAMPLE
      Move-RubrikMountVMDK -SourceVMID (Get-RubrikVM -Name 'SourceVM').id -TargetVM 'TargetVM'
      This will create a Live Mount using the latest snapshot of the VM named "SourceVM", using the VM's Rubrik ID.
      The Live Mount's VMDKs would then be presented to the VM named "TargetVM"

      .EXAMPLE
      Move-RubrikMountVMDK -SourceVM 'SourceVM' -TargetVM 'TargetVM'
      This will create a Live Mount using the latest snapshot of the VM named "SourceVM"
      The Live Mount's VMDKs would then be presented to the VM named "TargetVM"

      .EXAMPLE
      Move-RubrikMountVMDK -SourceVM 'SourceVM' -TargetVM 'TargetVM' -Date '01/30/2016 08:00'
      This will create a Live Mount using the January 30th 08:00AM snapshot of the VM named "SourceVM"
      The Live Mount's VMDKs would then be presented to the VM named "TargetVM"
      Note: The Date parameter will start at the time specified (in this case, 08:00am) and work backwards in time until it finds a snapshot.
      Precise timing is not required.
    
      .EXAMPLE
      Move-RubrikMountVMDK -SourceVM 'SourceVM' -TargetVM 'TargetVM' -ExcludeDisk @(0,1)
      This will create a Live Mount using the latest snapshot of the VM named "SourceVM"
      Disk 0 and 1 (the first and second disks) would be excluded from presentation to the VM named "TargetVM"
      Note: that for the "ExcludeDisk" array, the format is @(#,#,#,...) where each # represents a disk starting with 0.
      Example: To exclude the first and third disks, the value would be @(0,2).
      Example: To exclude just the first disk, use @(0).

      .EXAMPLE
      Move-RubrikMountVMDK -Cleanup 'C:\Users\Person1\Documents\SourceVM_to_TargetVM-1234567890.txt'
      This will remove the disk(s) and live mount, effectively reversing the initial request
      This file is created each time the command is run and stored in the $HOME path as a text file
      The file contains the TargetVM name, MountID value, and a list of all presented disks
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Source virtual machine Rubrik ID to use as a live mount
    [Parameter(ParameterSetName = 'Create')]
    [String]$SourceVMID,
    # Source virtual machine to use as a Live Mount based on a previous backup
    [Parameter(ParameterSetName = 'Create')]
    [Alias('Name','VM')]
    [String]$SourceVM,
    # Target virtual machine to attach the Live Mount disk(s)
    [Parameter(Mandatory=$true,ParameterSetName = 'Create')]
    [String]$TargetVM,
    # Backup date to use for the Live Mount
    # Will use the current date and time if no value is specified
    [Parameter(ParameterSetName = 'Create')]
    [String]$Date,
    # An array of disks to exclude from presenting to the target virtual machine
    # By default, all disks will be presented
    [Parameter(ParameterSetName = 'Create')]
    [Array]$ExcludeDisk,
    # The path to a cleanup file to remove the live mount and presented disks
    # The cleanup file is created each time the command is run and stored in the $HOME path as a text file with a random number value
    # The file contains the TargetVM name, MountID value, and a list of all presented disks
    [Parameter(ParameterSetName = 'Destroy')]
    [String]$Cleanup,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
    Test-VMwareConnection

  }

  Process {
    try{
    if (!$Cleanup)
    {
      if (!$Date) 
      {
        Write-Verbose -Message 'No date entered. Taking current time.'
        $Date = Get-Date
      }
      else {
        # Strip training Z from $Date. Using a date directly from an API response will cause PowerShell to create an inaccurate datetime object
        $Date = $Date.TrimEnd("Z")

        # Validate provided date
        try {
          $Date = [datetime]$Date
        }
        catch {
          throw "Invalid Date"
        }
      }

      Write-Verbose -Message "Validating Source and Target VMs"
      if($SourceVM -and !$SourceVMID){
        Write-Warning -Message "-SourceVM has been deprecated as a parameter. The code will attempt to match the correct Rubrik VM ID, but please use -SourceVMID."
        $SourceVMID = (Get-RubrikVM -Name $SourceVM -PrimaryClusterID local).id
        if(!$SourceVMID){
          throw "$SourceVM is invalid. Please use a valid VM."
        } elseif ($SourceVMID.Count -gt 1) {
          throw "$souceVM has mutliple results. Please use -SourceVMID to specific the VM you want to use."
        }
      }

      $HostID = (Get-RubrikVM -VM $TargetVM -PrimaryClusterID local).hostId
      if(!$HostID){
        throw "$targetvm is invalid."
      }
      Write-Verbose -Message "Creating a powered off Live Mount of $SourceVMID"
      $mount = Get-RubrikSnapshot -id $SourceVMID -Date $Date | New-RubrikMount -HostID $HostID
      
      if(-not $mount) {throw 'No mounts were created. Check that you have declared a valid VM.'}

      Write-Verbose -Message "Waiting for request $($mount.id) to complete"
      while ((Get-RubrikRequest -ID $mount.id -Type "vmware/vm").status -ne 'SUCCEEDED')
      {
        Start-Sleep -Seconds 5
      }
    
      Write-Verbose -Message 'Live Mount is now available'
      Write-Verbose -Message 'Gathering Live Mount ID value'

      foreach ($link in ((Get-RubrikRequest -ID $mount.id -Type "vmware/vm").links))
      {
        # There are two links - the request (self) and result
        # This will filter the values to just the result
        if ($link.rel -eq 'result')
        {
          # We just want the very last part of the link, which contains the ID value
          $MountID = $link.href.Split('/')[-1]
          Write-Verbose -Message "Found Live Mount ID $MountID"
        }
      }

      Write-Verbose -Message "Gathering details on Live Mount ID $MountID"
      $MountVM = Get-RubrikVM -id (Get-RubrikMount -id $MountID).mountedVmId
      
      Write-Verbose -Message 'Migrating the Mount VMDKs to VM'
      if ($PSCmdlet.ShouldProcess($TargetVM,'Migrating Live Mount VMDK(s)'))
      {
        [array]$MountVMdisk = Get-HardDisk $MountVM.name
        $MountedVMdiskFileNames = @()
        [int]$j = 0
        foreach ($_ in $MountVMdisk)
        {
          if ($ExcludeDisk -contains $j)
          {
            Write-Verbose -Message "Skipping Disk $j" -Verbose
          }
          else 
          {
            try
            {
              Remove-HardDisk -HardDisk $_ -DeletePermanently:$false -Confirm:$false | Out-Null
              New-HardDisk -VM $TargetVM -DiskPath $_.Filename | Out-Null
              $MountedVMdiskFileNames += $_.Filename
              Write-Verbose -Message "Migrated $($_.Filename) to $TargetVM"
            }
            catch
            {
              throw $_
            }
          }
          $j++
        }
      }

      $Diskfile = "$Home\Documents\"+$SourceVM+'_to_'+$TargetVM+'-'+(Get-Date).Ticks+'.txt'
      $TargetVM | Out-File -FilePath $Diskfile -Encoding utf8 -Force
      $MountID | Out-File -FilePath $Diskfile -Encoding utf8 -Append -Force      
      $MountedVMdiskFileNames | Out-File -FilePath $Diskfile -Encoding utf8 -Append -Force
      
      # Return information needed to cleanup the mounted disks and Live Mount
      $response = [pscustomobject]@{
        'Status' = 'Success'
        'CleanupFile' = $Diskfile
        'TargetVM' = $TargetVM
        'MountID' = $MountID
        'MountedVMdiskFileNames' = $MountedVMdiskFileNames
        'Example' = "Move-RubrikMountVMDK -Cleanup '$Diskfile'"
      }
      return $response
    }

    elseif ($Cleanup) 
    {
      if ((Test-Path $Cleanup) -ne $true) 
      {
        throw 'File does not exist'
      }
      $TargetVM = (Get-Content -Path $Cleanup -Encoding UTF8)[0]
      $MountID = (Get-Content -Path $Cleanup -Encoding UTF8)[1]
      $MountedVMdiskFileNames = (Get-Content -Path $Cleanup -Encoding UTF8) | Select-Object -Skip 2
      Write-Verbose -Message 'Removing disks from the VM'
      [array]$SourceVMdisk = Get-HardDisk $TargetVM
      foreach ($_ in $SourceVMdisk)
      {
        if ($MountedVMdiskFileNames -contains $_.Filename)
        {
          Write-Verbose -Message "Removing $_ from $TargetVM"
          Remove-HardDisk -HardDisk $_ -DeletePermanently:$false -Confirm:$false
        }
      }
        
      Write-Verbose -Message "Deleting the Live Mount named $($MountVM.name)"
      Remove-RubrikMount -id $MountID -Confirm:$false
    }
    } #end Try
    catch {
      #IF any error occurs, bail out of the script before any damage is done.
      throw $_
      break

    } #end Catch

  } # End of process
} # End of function

#requires -Version 3
function New-RubrikAPIToken
{
  <#
      .SYNOPSIS
      Creates a new Rubrik API Token.

      .DESCRIPTION
      The New-RubrikAPIToken cmdlet is used to generate a new API Token for the Rubrik cluster using the role and permissions of the currently logged in session. The token can then be used in making API requests without having to resort to basic authorization.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikAPIToken.html

      .EXAMPLE
      New-RubrikAPIToken
      This will generate a new API Token named "API Token" that lasts for 60 minutes (1 hour).

      .EXAMPLE
      New-RubrikAPIToken -Expiration 2880 -Tag "2-Day Token"
      This will generate a new API Token named "2-Day Token" that lasts for 2880 minutes (48 hours / 2 days).

      .EXAMPLE
      New-RubrikAPIToken -Expiration 10080 -Tag "Dev Org Weekly Token" -OrganizationId "Organization:::11111111-2222-3333-4444-555555555555"
      This will generate a new API Token named "Dev Org Weekly Token" that lasts for 10080 minutes (7 days) in the organization matching id value "Organization:::11111111-2222-3333-4444-555555555555".
      This assumes that the current session that is requested the token has authority in that organization.
  #>

  [CmdletBinding()]
  Param(
    # Bind the new session to the specified organization. When this parameter is not specified, the session will be bound to an organization chosen according to the user's preferences and authorizations.
    [ValidateNotNullOrEmpty()]
    [String]$OrganizationId,
    # This value specifies an interval in minutes. The token expires at the end of the interval. By default, this value is 60 (1 hour). This value cannot exceed 525600 (365 days).
    [ValidateRange(1,525600)]
    [Int]$Expiration = 60,
    # Name assigned to the token. The default value is "API Token".
    [Alias("Name")]
    [String]$Tag,
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

    #region one-off
    # Because this payload has 2-layers of nested body objects, the body is written out here as of 5.0 CDM.
    $body = @{
      initParams = @{
        apiToken = @{
          expiration = $Expiration
        }
      }
    }
    # The Organization ID is an optional param and takes on the default org of the calling session if left empty. Sending over null is not valid.
    if ($OrganizationId) {$body.initParams.Add("organizationId", $OrganizationId)}
    # The Tag is an optional param and takes on the value of "API Token" if nothing is supplied.
    if ($Tag) {$body.initParams.apiToken.Add("tag", $Tag)}
    $body = ConvertTo-Json -InputObject $body
    Write-Verbose -Message "Body = $body"
    #endregion

    #$body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
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
          
      .EXAMPLE
      $BootStrapHash = @{
        Server = 169.254.11.25
        name = 'rubrik-edge' 
        dnsNameservers = @('192.168.11.1')
        dnsSearchDomains = @('corp.us','branch.corp.us')
        ntpserverconfigs = @(@{server = 'pool.ntp.org'})
        adminUserInfo = @{emailAddress = 'nick@shoresmedia.com'; id ='admin'; password = 'P@SSw0rd!'}
        nodeconfigs = @{node1 = @{managementIpConfig = @{address = '192.168.11.1'; gateway = '192.168.11.100'; netmask = '255.255.255.0'}}}
      }
      
      New-RubrikBootStrap @BootStrapHash      
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
      if ('HashTable' -ne $_.GetType().Name) {
        Throw "node configuration should be a hashtable, refer to the documentation on how to structure a bootstrap request"
      }
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
    if([string]::IsNullOrEmpty($dnsNameServers)) {
      $dnsNameServers = @(
        '8.8.8.8'
      )
    }

    # Default DNS search domains to an empty array
    if([string]::IsNullOrEmpty($dnsSearchDomains)) {
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
    $result = Submit-Request -uri $uri -Header @{"content-type"="application/json"} -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#Requires -Version 3
function New-RubrikDatabaseMount
{
  <#  
      .SYNOPSIS
      Create a new Live Mount from a protected database
      
      .DESCRIPTION
      The New-RubrikDatabaseMount cmdlet is used to create a Live Mount (clone) of a protected database and run it in an existing database environment.
      
      .NOTES
      Written by Mike Fal for community usage from New-RubrikMount
      Twitter: @Mike_Fal
      GitHub: MikeFal
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikDatabaseMount.html

      .EXAMPLE
      New-RubrikDatabaseMount -id $db.id -targetInstanceId $db.instanceId -mountedDatabaseName 'BAR-LM' -recoveryDateTime (Get-date (Get-RubrikDatabase -id $db.id).latestRecoveryPoint)
      Creates a new database mount named BAR on the same instance as the source database, using the most recent recovery time for the database. 
      
      $db=Get-RubrikDatabase -HostName FOO -Instance MSSQLSERVER -Database BAR

  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik id of the database
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # ID of Instance to use for the mount
    [Alias('InstanceId')]
    [String]$TargetInstanceId,
    # Name of the mounted database
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('DatabaseName','MountName')]
    [String]$MountedDatabaseName,
    # Recovery Point desired in the form of Epoch with Milliseconds
    [Parameter(ParameterSetName='Recovery_timestamp')]
    [int64]$TimestampMs,
    # Recovery Point desired in the form of DateTime value
    [Parameter(ParameterSetName='Recovery_DateTime')]
    [datetime]$RecoveryDateTime,
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
    
    #Set epoch for recovery time calculations


    #If recoveryDateTime, convert to epoch milliseconds
    if($recoveryDateTime){  
      $TimestampMs = ConvertTo-EpochMS -DateTimeValue $RecoveryDateTime
    } 

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
        
    #region One-off
    Write-Verbose -Message "Build the body"
    $body = @{
      $resources.Body.targetInstanceId = $targetInstanceId
      $resources.Body.mountedDatabaseName = $mountedDatabaseName
      recoveryPoint = @()
    }
    $body.recoveryPoint += @{
          $resources.Body.recoveryPoint.timestampMs = $timestampMs
          }
    $body = ConvertTo-Json $body
    Write-Verbose -Message "Body = $body"
    #endregion


    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#requires -Version 3
function New-RubrikFileset
{
  <#  
      .SYNOPSIS
      {required: high level overview}

      .DESCRIPTION
      {required: more detailed description of the function's purpose}

      .NOTES
      Written by {required}
      Twitter: {optional}
      GitHub: {optional}
      Any other links you'd like here

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      New-RubrikFileset -TemplateID '1111-1111-1111-1111' -HostID 'Host::::2222-2222-2222-2222'

      Creates a new fileset on the specified host, using the selected template.

      .EXAMPLE
      New-RubrikFileset -TemplateID (Get-RubrikFilesetTemplate -Name 'FOO').id -ShareID (Get-RubrikNASShare -name 'BAR').id

      Creates a new fileset for the BAR NAS, using the FOO template.
  #>

  [CmdletBinding()]
  Param(
    #Fileset Template ID to use for the new fileset
    [Parameter(Mandatory=$true)]
    [String]$TemplateID,
    # HostID - Used for Windows or Linux Filesets
    [String]$HostID,
    # ShareID - used for NAS shares
    [String]$ShareID,   
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
#requires -Version 3
function New-RubrikFilesetTemplate
{
  <#  
      .SYNOPSIS
      Creates a new fileset template.

      .DESCRIPTION
      Create a new fileset template for Linux hosts, Windows hosts, and NAS shares. This must be
      done before creating a new fileset, as filesets are defined by the templates. Some caveats that
      are defined by the Rubrik GUI but not applied here:
       - If creating a Windows Fileset Template, you should declare UseWindowsVSS equal to true
       - If you define a pre or post backup script, you need to define error handling
       - If you define a pre or post backup script, you should definte the backup script timeout value to 14400

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      New-RubrikFilesetTemplate -Name 'FOO' -UseWindowsVSS -OperatingSystemType 'Windows' -Includes 'C:\*.mp3','C:\*.csv'

      Create a Windows Fileset Template to backup .mp3 and .csv on the C:\.

      .EXAMPLE
      New-RubrikFilesetTemplate -Name 'BAR' -ShareType 'SMB' -Includes '*' -Excludes '*.pdf'

      Create a new NAS FilesetTemplate named BAR to backup a NAS SMB share, backing up everything byt excluding all .pdf files.
    #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    #Name of fileset template
    [String]$Name,
    #Boolean - Allow Backup Network Mounts
    [Switch]$AllowBackupNetworkMounts,
    # Boolean - Allow Backup Hidden Folders in Network Mounts
    [Switch]$AllowBackupHiddenFoldersInNetworkMounts,    
    # Enable Windows VSS
    [switch]$UseWindowsVSS,
    #Include naming patterns
    [String[]]$Includes,
    #Exclude naming patterns
    [String[]]$Excludes,
    #Exceptions for exclude naming patterns
    [String[]]$Exceptions,
    #Operating System Type
    [Parameter(ParameterSetName='OSType')]
    [ValidateSet('Linux','Windows')]
    [String]$OperatingSystemType,
    #Share Type
    [Parameter(ParameterSetName='ShareType')]
    [ValidateSet('NFS','SMB')]
    [String]$ShareType,
    #Path to pre-backup script
    [String]$PreBackupScript,
    #Path to post-backup script
    [String]$PostBackupScript,
    #Backup script timeout
    [Int]$BackupScriptTimeout,
    #Error handling for backup script
    [ValidateSet('abort','continue')]
    [String]$BackupScriptErrorHandling,
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
#requires -Version 3
function New-RubrikHost
{
  <#  
      .SYNOPSIS
      Registers a host with a Rubrik cluster.

      .DESCRIPTION
      The New-RubrikHost cmdlet is used to register a host with the Rubrik cluster. This could be a host leveraging the Rubrik Backup Service or directly as with the case of NAS shares.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikHost.html

      .EXAMPLE
      New-RubrikHost -Name 'Server1.example.com'
      This will register a host that resolves to the name "Server1.example.com"

      .EXAMPLE
      New-RubrikHost -Name 'NAS.example.com' -HasAgent $false
      This will register a host that resolves to the name "NAS.example.com" without using the Rubrik Backup Service
      In this case, the example host is a NAS share.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The IPv4 address of the host or the resolvable hostname of the host
    [Parameter(Mandatory = $true)]
    [Alias('Hostname')]
    [String]$Name,
    # Set to $false to register a host that will be accessed through network shares
    [Bool]$HasAgent,
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
#Requires -Version 3
function New-RubrikLDAP
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and sets Rubrik cluster settings
            
      .DESCRIPTION
      The New-RubrikLDAP cmdlet will set the cluster settings on the system. This does require authentication.
            
      .NOTES
      Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      New-RubrikLDAP -Name "Test LDAP Settings" -baseDN "DC=domain,DC=local" -authServers "192.168.1.8"
      This will create LDAP settings on the Rubrik cluster defined by Connect-Rubrik function
  #>

  [cmdletbinding(SupportsShouldProcess=$true,DefaultParametersetName='UserPassword')]
  Param(
    # Human friendly name
    [Parameter(Mandatory=$True)]
    [string]$Name,
    # Bind credentials with permission to connect to the LDAP server
    # Optionally, use the BindUserName and BindUserPassword parameters
    [Parameter(ParameterSetName='Credential',Mandatory=$true)]
    [System.Management.Automation.CredentialAttribute()]$BindCredential,
    # Dynamic DNS name for locating authentication servers.
    [Parameter(Mandatory=$True)]
    [string]$DynamicDNSName,
    # The path to the directory where searches for users begin.
    [string]$BaseDN,
    # An ordered list of authentication servers. Servers on this list have priority over servers discovered using dynamic DNS.
    [array]$AuthServers,
    # Bind username with permissions to connect to the LDAP server
    # Optionally, use the BindCredential parameter    
    [Parameter(ParameterSetName='UserPassword',Mandatory=$true, Position = 1)]
    [String]$BindUserName,
    # Password for the Username provided
    # Optionally, use the Credential parameter
    [Parameter(ParameterSetName='UserPassword',Mandatory=$true, Position = 2)]
    [SecureString]$BindUserPassword,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # ID of the Rubrik cluster or me for self
    [String]$id = '',
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection

    # Check to ensure that we have credentials for the LDAP server
    $BindCredential = Test-RubrikLDAPCredential -BindUserName $BindUserName -BindUserPassword $BindUserPassword -Credential $BindCredential
    
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

    #region One-off
    # This section is here to place the LDAP bind credentials into the API request prior to being encrypted and sent to the Rubrik API endpoint
    # Because the New-BodyString private function has already created a JSON payload, we must convert back to a hashtable before updating the credentials
    # Once that's done, we restore the $body var into a proper JSON payload and continue along.
    # See this PR for more information: https://github.com/rubrikinc/rubrik-sdk-for-powershell/pull/263
    Write-Verbose 'Passing $BindCredential username and password into the API request'
    $bodyHash = ConvertFrom-Json $body
    $bodyHash.bindUserName = $BindCredential.UserName
    $bodyHash.bindUserPassword = $BindCredential.GetNetworkCredential().Password
    $body = ConvertTo-Json $bodyHash
    #endregion    

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#requires -Version 3
function New-RubrikLogBackup
{
  <#  
      .SYNOPSIS
      Runs an on demand log backup for the specified database id.

      .DESCRIPTION
      This cmdlet initiates an on-demand transaction log backup for a specific SQL Server database.

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      New-RubrikLogBackup -id MssqlDatabase:::c5ecf3ef-248d-4bb2-8fe1-4d3c820a0e38 

      .EXAMPLE
      Get-RubrikDatabase -ServerInstance FOO -Name BAR | New-RubrikLogBackup

      Iniitaite a log backup for the BAR database on the FOO instance.
  #>

  [CmdletBinding()]
  Param(
    # Rubrik's id of the object
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
#requires -Version 3
function New-RubrikLogShipping
{
  <#  
  .SYNOPSIS
  Create a log shipping configuration within Rubrik

  .DESCRIPTION
  Create a log shipping configuration within Rubrik

  .NOTES
  Written by Chris Lumnah
  Twitter: lumnah
  GitHub: clumnah
  
  .LINK
  http://rubrikinc.github.io/rubrik-sdk-for-powershell/

  .EXAMPLE
  $RubrikDatabase = Get-RubrikDatabase -Name 'AthenaAM1-SQL16-1-2016' -Hostname am1-sql16-1
  $RubrikSQLInstance = Get-RubrikSQLInstance -Hostname am1-chrilumn-w1 -instance MSSQLSERVER
  New-RubrikLogShipping -id $RubrikDatabase.id -state 'STANDBY' -targetDatabaseName 'AthenaAM1-SQL16-1-2016' -targetDataFilePath 'c:\sqldata' -targetLogFilePath 'c:\sqldata' -targetInstanceId $RubrikSQLInstance.id -Verbose
  #>

  [CmdletBinding()]
  Param(
    # Rubrik identifier of database to be exported
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,

    [ValidateSet("RESTORING", "STANDBY")]
    [String]$state,

    [Alias('shouldDisconnectStandbyUsers')]
    [switch]$DisconnectStandbyUsers,

    [Parameter(Mandatory = $true)]
    [String]$targetDatabaseName, 

    [Parameter(Mandatory = $false)]
    [String]$targetDataFilePath, 

    [Parameter(Mandatory = $false)]
    [String]$targetLogFilePath,    
    
    [Parameter(Mandatory = $true)]
    [String]$targetInstanceId,  

    #Advanced Mode - Array of hash tables for file reloaction.
    [PSCustomObject[]] $TargetFilePaths,  

    # Number of parallel streams to copy data
    [int]$MaxDataStreams,

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
    #region One-off
    Write-Verbose -Message "Build the body"
    $body = @{
      $resources.Body.targetInstanceId = $TargetInstanceId
      $resources.Body.targetDatabaseName = $TargetDatabaseName
      $resources.Body.state = $state
    }

    if($DisconnectStandbyUsers){
      $body.Add($resources.Body.shouldDisconnectStandbyUsers,$DisconnectStandbyUsers)
    }

    if($MaxDataStreams){
      $body.Add($resources.Body.maxDataStreams,$MaxDataStreams)
    }

    if($TargetFilePaths) {
      if($TargetDataFilePath -or $TargetLogFilePath) {Write-Warning 'Use of -TargetFilePaths overrides -TargetDataFilePath and -TargetLogFilePath.'}
      $body.Add('targetFilePaths',$TargetFilePaths)
    } else {
      if($TargetDataFilePath){ $body.Add('targetDataFilePath',$TargetDataFilePath) }
      if($TargetLogFilePath){ $body.Add('targetLogFilePath',$TargetLogFilePath) }
    }
    
    $body = ConvertTo-Json $body
    Write-Verbose -Message "Body = $body"
    #endregion
    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    #$body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#requires -Version 3
function New-RubrikManagedVolume
{
  <#  
      .SYNOPSIS
      Creates a new Rubrik Managed Volume 

      .DESCRIPTION
      The New-RubrikManagedVolume cmdlet is used to create
      a new Managed Volume

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      New-RubrikManagedVolume -Name foo -Channels 4 -VolumeSize 1073741824000

      Creates a new managed volume named 'foo' with 4 channels and 1073741824000 bytes (1TB) in size

      .EXAMPLE
      New-RubrikManagedVolume -Name foo -Channels 2 -VolumeSize (500 * 1GB) -Subnet 172.21.10.0/23

      Creates a new managed volume named 'foo' with 2 channels, 536870912000 bytes (500 GB) in size, on the 172.21.10.0/23 subnet

      .EXAMPLE
      New-RubrikManagedVolume -Name foo -Channels 2 -VolumeSize (500 * 1GB) -ApplicationTag "PostgreSql"

      Creates a new managed volume named 'foo' with 2 channels, 536870912000 bytes (500 GB) in size, configured for PostreSQL backups
      Valid ApplicationTag values are 'Oracle', 'OracleIncremental', 'MsSql', 'SapHana', 'MySql', 'PostgreSql', and 'RecoverX'
  #>

  [CmdletBinding()]
  Param(
    # Name of managed volume
    [Parameter(Mandatory=$true)]
    [String]$Name,
    #Number of channels in the Managed Volume
    [Parameter(Mandatory=$true)]
    [Alias('numChannels')]
    [int]$Channels,
    #Subnet Managed Volume is placed on
    [String]$Subnet,
    #Size of the Managed Volume in Bytes
    [int64]$VolumeSize,
    #Application whose data will be stored in managed volume
    [ValidateSet('Oracle', 'OracleIncremental', 'MsSql', 'SapHana', 'MySql', 'PostgreSql', 'RecoverX')]
    [string]$applicationTag,
    #Export config, such as host hints and host name patterns
    [PSCustomObject[]]$exportConfig,
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
#Requires -Version 3
function New-RubrikManagedVolumeExport
{
  <#
      .SYNOPSIS
      Creates an export of a Managed Volume snapshot

      .DESCRIPTION
      The New-RubrikManagedVolumeExport command will request the creation of
      a Managed Volume export of the specified Managed Volume snapshot

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikSnapshot -id ManagedVolume:::f68ecd45-bdb9-46dd-aea4-8f041fb2dec2 | Select-Object -First 1 | New-RubrikManagedVolumeExport

      Create an export (live mount) of the most recent snapshot for the specified managed volume.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik identifier of Managed Volume snapshot to be exported
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$Id,
    #Source Managed Volume Name
    [String]$SourceManagedVolumeName,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $Id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri

    #region One-off
    #API call uses only GUID for ID, not ManagedVolume:::+GUID
    $uri = $uri.Replace('ManagedVolume:::','')
    #Force all hostPatterns for JSON payload
    $body = '{"hostPatterns":["*"]}'
    #endregion
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#Requires -Version 3
function New-RubrikMount
{
  <#  
      .SYNOPSIS
      Create a new Live Mount from a protected VM
      
      .DESCRIPTION
      The New-RubrikMount cmdlet is used to create a Live Mount (clone) of a protected VM and run it in an existing vSphere environment.
      
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikMount.html

      .EXAMPLE
      New-RubrikMount -id '11111111-2222-3333-4444-555555555555'
      This will create a new mount based on snapshot id "11111111-2222-3333-4444-555555555555"
      The original virtual machine's name will be used along with a date and index number suffix
      The virtual machine will NOT be powered on upon completion of the mount operation
      
      .EXAMPLE
      New-RubrikMount -id '11111111-2222-3333-4444-555555555555' -MountName 'Mount1' -PowerOn -RemoveNetworkDevices
      This will create a new mount based on snapshot id "11111111-2222-3333-4444-555555555555" and name the mounted virtual machine "Mount1"
      The virtual machine will be powered on upon completion of the mount operation but without any virtual network adapters

      .EXAMPLE
      Get-RubrikVM 'Server1' | Get-RubrikSnapshot -Date '03/01/2017 01:00' | New-RubrikMount -MountName 'Mount1' -DisableNetwork
      This will create a new mount based on the closet snapshot found on March 1st, 2017 @ 01:00 AM and name the mounted virtual machine "Mount1"
      The virtual machine will NOT be powered on upon completion of the mount operation

  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik id of the snapshot
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # ID of host for the mount to use 
    [String]$HostID,
    # Name of the mounted VM 
    [Alias('vmName')]
    [String]$MountName,
    # Name of the data store to use/create on the host 
    [String]$DatastoreName,
    # Whether the network should be disabled on mount.This should be set true to avoid ip conflict in case of static IPs. 
    [Bool]$DisableNetwork,
    # Whether the network devices should be removed on mount.
    [Bool]$RemoveNetworkDevices,
    # Whether the VM should be powered on after mount.
    [Bool]$PowerOn,
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
#requires -Version 3
function New-RubrikNASShare
{
  <#  
      .SYNOPSIS
      Creates a new NAS share in Rubrik for backup operations

      .DESCRIPTION
      Registers a new NAS share in Rubrik. Once created, this NAS share can be associated with
      filesets for appropriate fileset backups. Note, a host must first be created using
      New-RubrikHost for the NAS share to be associated.

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      New-RubrikNASShare -HostID (Get-RubrikHost 'FOO').id -ShareType NFS -ExportPoint BAR -Credential (Get-Credential)

      Create a new NFS share for host FOO, export point BAR.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    #Host ID that the NAS share will be associated with
    [Parameter(Mandatory = $true)]
    [String]$HostID,
    #Share type - NFS or SMB
    [Parameter(Mandatory = $true)]
    [ValidateSet('NFS','SMB')]
    [String]$ShareType,
    #Export point - Share Name
    [String]$ExportPoint,
    #Credential for NAS share
    [pscredential]$Credential,
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

    #region one-off
    #Convert credential to valid body values
    if($Credential){
      $bodytemp = ConvertFrom-Json $body
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'username' -Value $Credential.GetNetworkCredential().UserName
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'password' -Value $Credential.GetNetworkCredential().Password 
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'domain' -Value $Credential.GetNetworkCredential().Domain 
      $body = ConvertTo-Json $bodytemp
    }
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#requires -Version 3
function New-RubrikReport
{
  <#  
      .SYNOPSIS
      Create a new report by specifying one of the report templates

      .DESCRIPTION
      The New-RubrikReport cmdlet is used to create a new Envision report by specifying one of the canned report templates

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikReport.html

      .EXAMPLE
      New-RubrikReport -Name 'Report1' -ReportTemplate 'ProtectionTasksDetails'
      This will create a new report named "Report1" by using the "ProtectionTasksDetails" report template
  #>

  [CmdletBinding()]
  Param(
    # The name of the report
    [Parameter(Mandatory = $true)]
    [String]$Name,
    # The template this report is based on
    [Parameter(Mandatory = $true)]    
    [ValidateSet('ProtectionTasksDetails','ProtectionTasksSummary','SystemCapacity','SlaComplianceSummary')]
    [String]$ReportTemplate,
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
#Requires -Version 3
function New-RubrikSLA
{
  <#  
      .SYNOPSIS
      Creates a new Rubrik SLA Domain

      .DESCRIPTION
      The New-RubrikSLA cmdlet will build a new SLA Domain to provide policy-driven control over protected objects within the Rubrik fabric.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikSLA.html

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 7

      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days.

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 7 -DailyFrequency 1 -DailyRetention 30

      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days
      while also keeping one backup per day for 30 days.

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -AdvancedConfig -HourlyFrequency 4 -HourlyRetention 7 -DailyFrequency 1 -DailyRetention 30 -WeeklyFrequency 1 -WeeklyRetention 4 -DayOfWeek Friday -YearlyFrequency 1 -YearlyRetention 3 -DayOfYear LastDay -YearStartMonth February

      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days
      while also keeping one backup per day for 30 days, one backup per week for 4 weeks and one backup per year for 3 years. 
      The weekly backups will be created on Fridays and the yearly backups will be created on January 31 because the year is set
      to start in February. The advanced SLA configuration can only be used with CDM version 5.0 and above.

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 7 -DailyFrequency 1 -DailyRetention 30 -BackupStartHour 22 -BackupStartMinute 00 -BackupWindowDuration 8

      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days. 
      Backups are allowed to run between 22:00 and 6:00AM.

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 7 -DailyFrequency 1 -DailyRetention 30 -FirstFullBackupStartHour 21 -FirstFullBackupStartMinute 30 -FirstFullBackupWindowDuration 57 -FirstFullBackupDay Friday

      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days. 
      The first full backup is allowed to be taken between Friday 21:30 and Monday 6:30AM.
      
      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 7 -DailyFrequency 1 -DailyRetention 30 -Archival -ArchivalLocationId 53aef5df-b628-4b61-aade-6520a2a5ba4d -LocalRetention 14 -InstantArchive

      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days,
      while also keeping one backup per day for 30 days. At the same time, data is immediately copied to the specified archival location 
      and will be kept there for 14 days.

      .EXAMPLE
      New-RubrikSLA -SLA 'Test1' -HourlyFrequency 4 -HourlyRetention 7 -DailyFrequency 1 -DailyRetention 30 -Replication -ReplicationTargetId 8b4fe6f6-cc87-4354-a125-b65e23cf8c90 -RemoteRetention 5
      
      This will create an SLA Domain named "Test1" that will take a backup every 4 hours and keep those hourly backups for 7 days,
      while also keeping one backup per day for 30 days. At the same time, data is replicated to the specified target cluster 
      and will be kept there for 5 days.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # SLA Domain Name
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('SLA')]
    [String]$Name,
    # Hourly frequency to take snapshots
    [int]$HourlyFrequency,
    # Number of days or weeks to retain the hourly snapshots. For CDM versions prior to 5.0 this value must be set in days
    [int]$HourlyRetention,
    # Retention type to apply to hourly snapshots when $AdvancedConfig is used. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Daily','Weekly')]
    [String]$HourlyRetentionType='Daily',
    # Daily frequency to take snapshots
    [int]$DailyFrequency,
    # Number of days or weeks to retain the daily snapshots. For CDM versions prior to 5.0 this value must be set in days
    [int]$DailyRetention,
    # Retention type to apply to daily snapshots when $AdvancedConfig is used. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Daily','Weekly')]
    [String]$DailyRetentionType='Daily',
    # Weekly frequency to take snapshots
    [int]$WeeklyFrequency,
    # Number of weeks to retain the weekly snapshots
    [int]$WeeklyRetention,
    # Day of week for the weekly snapshots when $AdvancedConfig is used. The default is Saturday. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')]
    [String]$DayOfWeek='Saturday',
    # Monthly frequency to take snapshots
    [int]$MonthlyFrequency,
    # Number of months, quarters or years to retain the monthly backups. For CDM versions prior to 5.0, this value must be set in years
    [int]$MonthlyRetention,
    # Day of month for the monthly snapshots when $AdvancedConfig is used. The default is the last day of the month. Does not apply to CDM versions prior to 5.0
    [ValidateSet('FirstDay','Fifteenth','LastDay')]
    [String]$DayOfMonth='LastDay',
    # Retention type to apply to monthly snapshots. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Monthly','Quarterly','Yearly')]
    [String]$MonthlyRetentionType='Monthly',
    # Quarterly frequency to take snapshots. Does not apply to CDM versions prior to 5.0
    [int]$QuarterlyFrequency,
    # Number of quarters or years to retain the monthly snapshots. Does not apply to CDM versions prior to 5.0
    [int]$QuarterlyRetention,
    # Day of quarter for the quarterly snapshots when $AdvancedConfig is used. The default is the last day of the quarter. Does not apply to CDM versions prior to 5.0
    [ValidateSet('FirstDay','LastDay')]
    [String]$DayOfQuarter='LastDay',
    # Month that starts the first quarter of the year for the quarterly snapshots when $AdvancedConfig is used. The default is January. Does not apply to CDM versions prior to 5.0
    [ValidateSet('January','February','March','April','May','June','July','August','September','October','November','December')]
    [String]$FirstQuarterStartMonth='January',
    # Retention type to apply to quarterly snapshots. The default is Quarterly. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Quarterly','Yearly')]
    [String]$QuarterlyRetentionType='Quarterly',
    # Yearly frequency to take snapshots
    [int]$YearlyFrequency,
    # Number of years to retain the yearly snapshots
    [int]$YearlyRetention,
    # Day of year for the yearly snapshots when $AdvancedConfig is used. The default is the last day of the year. Does not apply to CDM versions prior to 5.0
    [ValidateSet('FirstDay','LastDay')]
    [String]$DayOfYear='LastDay',
    # Month that starts the first quarter of the year for the quarterly snapshots when $AdvancedConfig is used. The default is January. Does not apply to CDM versions prior to 5.0
    [ValidateSet('January','February','March','April','May','June','July','August','September','October','November','December')]
    [String]$YearStartMonth='January',
    # Whether to turn advanced SLA configuration on or off. Does not apply to CDM versions prior to 5.0
    [switch]$AdvancedConfig,
    [ValidateRange(0,23)]
    [int]$BackupStartHour,
    # Minute of hour from which backups are allowed to run
    [ValidateRange(0,59)]
    [int]$BackupStartMinute,
    # Number of hours during which backups are allowed to run
    [ValidateRange(1,23)]
    [int]$BackupWindowDuration,
    # Hour from which the first full backup is allowed to run. Uses the 24-hour clock
    [ValidateRange(0,23)]
    [int]$FirstFullBackupStartHour,
    # Minute of hour from which the first full backup is allowed to run
    [ValidateRange(0,59)]
    [int]$FirstFullBackupStartMinute,
    [ValidateSet('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','1','2','3','4','5','6','7')]
    [String]$FirstFullBackupDay,
    # Number of hours during which the first full backup is allowed to run
    [int]$FirstFullBackupWindowDuration,
    # Whether to enable archival
    [switch]$Archival,
    # Time in days to keep backup data locally on the cluster.
    [int]$LocalRetention,
    # ID of the archival location
    [ValidateNotNullOrEmpty()]
    [String]$ArchivalLocationId,
    # Polaris Managed ID
    [ValidateNotNullOrEmpty()]
    [String]$PolarisID,
    # Whether to enable Instant Archive
    [switch]$InstantArchive,
    # Whether to enable replication
    [switch]$Replication,
    # ID of the replication target
    [ValidateNotNullOrEmpty()]
    [String]$ReplicationTargetId,
    # Time in days to keep data on the replication target.
    [int]$RemoteRetention,
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

    #region One-off
    Write-Verbose -Message 'Build the body'
    # Build the body for CDM versions 5 and above when the advanced SLA configuration is turned on
    if (($uri.contains('v2')) -and $AdvancedConfig) {
      $body = @{
        $resources.Body.name = $Name
        frequencies = @()
        allowedBackupWindows = @()
        firstFullAllowedBackupWindows = @()
        archivalSpecs = @()
        replicationSpecs = @()
        showAdvancedUi = $AdvancedConfig.IsPresent
        advancedUiConfig = @()
      }
    # Build the body for CDM versions 5 and above when the advanced SLA configuration is turned off
    } elseif ($uri.contains('v2')) {
      $body = @{
        $resources.Body.name = $Name
        frequencies = @()
        allowedBackupWindows = @()
        firstFullAllowedBackupWindows = @()
        archivalSpecs = @()
        replicationSpecs = @()
        showAdvancedUi = $AdvancedConfig.IsPresent
      }
    # Build the body for CDM versions prior to 5.0
    } else {
      $body = @{
        $resources.Body.name = $Name
        frequencies = @()
        allowedBackupWindows = @()
        firstFullAllowedBackupWindows = @()
        archivalSpecs = @()
        replicationSpecs = @()
      }
    }
    
    Write-Verbose -Message 'Setting ParamValidation flag to $false to check if user set any params'
    [bool]$ParamValidation = $false
    
    if ((($uri.contains('v2')) -and (-not $AdvancedConfig)) -or (-not ($uri.contains('v2')))) {
      $HourlyRetention = $HourlyRetention * 24
    }
    if (-not ($uri.contains('v2'))) {
      $MonthlyRetention = $MonthlyRetention * 12
    }

    # Populate the body with the allowed backup window settings
    if (($BackupStartHour -ge 0) -and ($BackupStartMinute -ge 0) -and $BackupWindowDuration) {
      $body.allowedBackupWindows += @{
          startTimeAttributes = @{hour=$BackupStartHour;minutes=$BackupStartMinute};
          durationInHours = $BackupWindowDuration
      }
    }

    # Populate the body with the allowed backup window settings fort the first full
    if (($FirstFullBackupStartHour -ge 0) -and ($FirstFullBackupStartMinute -ge 0) -and $FirstFullBackupDay -and $FirstFullBackupWindowDuration) {
      if ($FirstFullBackupDay -eq 'Sunday') {
        [int]$FirstFullBackupDay = 1
      } elseif ($FirstFullBackupDay -eq 'Monday') {
        [int]$FirstFullBackupDay = 2
      } elseif ($FirstFullBackupDay -eq 'Tuesday') {
        [int]$FirstFullBackupDay = 3
      } elseif ($FirstFullBackupDay -eq 'Wednesday') {
        [int]$FirstFullBackupDay = 4
      } elseif ($FirstFullBackupDay -eq 'Thursday') {
        [int]$FirstFullBackupDay = 5
      } elseif ($FirstFullBackupDay -eq 'Friday') {
        [int]$FirstFullBackupDay = 6
      } elseif ($FirstFullBackupDay -eq 'Saturday') {
        [int]$FirstFullBackupDay = 7
      }
      $body.FirstFullAllowedBackupWindows += @{
          startTimeAttributes = @{hour=$FirstFullBackupStartHour;minutes=$FirstFullBackupStartMinute;dayOfWeek=$FirstFullBackupDay};
          durationInHours = $FirstFullBackupWindowDuration
      }
    }

    # Convert LocalRetention and RemoteRetention values to seconds
    $LocalRetention = $LocalRetention * 86400
    $RemoteRetention = $RemoteRetention * 86400

    # Populate the body with archival specifications
    if ($uri.contains('v2') -and $Archival) {
      if ($ArchivalLocationId -and $PolarisID -and ($InstantArchive.IsPresent -eq $true)) {
        $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=1;polarisManagedId=$PolarisID}
        $body.localRetentionLimit = $LocalRetention
      } elseif ($ArchivalLocationId -and ($InstantArchive.IsPresent -eq $true)) {
        $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=1}
        $body.localRetentionLimit = $LocalRetention
      } elseif ($ArchivalLocationId -and $PolarisID -and ($InstantArchive.IsPresent -eq $false)) {
        $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=$LocalRetention;polarisManagedId=$PolarisID}
        $body.localRetentionLimit = $LocalRetention
      } elseif ($ArchivalLocationId -and ($InstantArchive.IsPresent -eq $false)) {
        $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=$LocalRetention}
        $body.localRetentionLimit = $LocalRetention
      }
    } elseif ($Archival) {
        if ($ArchivalLocationId -and ($InstantArchive.IsPresent -eq $true)) {
          $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=1}
          $body.localRetentionLimit = $LocalRetention
        } elseif ($ArchivalLocationId -and ($InstantArchive.IsPresent -eq $false)) {
          $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=$LocalRetention}
          $body.localRetentionLimit = $LocalRetention
        }
    }

    # Populate the body with replication specifications
    if ($Replication -and $ReplicationTargetId -and $RemoteRetention) {
      $body.replicationSpecs += @{locationId=$ReplicationTargetId;retentionLimit=$RemoteRetention}
    }

    # Populate the body with frequencies and retentions according to the version of CDM and to whether the advanced SLA configuration is enabled in 5.x
    if ($HourlyFrequency -and $HourlyRetention) {
      if (($uri.contains('v2')) -and $AdvancedConfig) {
        $body.frequencies += @{'hourly'=@{frequency=$HourlyFrequency;retention=$HourlyRetention}}
        $body.advancedUiConfig += @{timeUnit='Hourly';retentionType=$HourlyRetentionType}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'hourly'=@{frequency=$HourlyFrequency;retention=$HourlyRetention}}
      } else {
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Hourly'
          $resources.Body.frequencies.frequency = $HourlyFrequency
          $resources.Body.frequencies.retention = $HourlyRetention
        }
      }
      [bool]$ParamValidation = $true
    }
    
    if ($DailyFrequency -and $DailyRetention) {
      if (($uri.contains('v2')) -and $AdvancedConfig) {
        $body.frequencies += @{'daily'=@{frequency=$DailyFrequency;retention=$DailyRetention}}
        $body.advancedUiConfig += @{timeUnit='Daily';retentionType=$DailyRetentionType}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'daily'=@{frequency=$DailyFrequency;retention=$DailyRetention}}
      } else { 
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Daily'
          $resources.Body.frequencies.frequency = $DailyFrequency
          $resources.Body.frequencies.retention = $DailyRetention
        }
      }
      [bool]$ParamValidation = $true
    }    

    if ($WeeklyFrequency -and $WeeklyRetention) { 
      if (($uri.contains('v2')) -and $AdvancedConfig) {
        $body.frequencies += @{'weekly'=@{frequency=$WeeklyFrequency;retention=$WeeklyRetention;dayOfWeek=$DayOfWeek}}
        $body.advancedUiConfig += @{timeUnit='Weekly';retentionType='Weekly'}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'weekly'=@{frequency=$WeeklyFrequency;retention=$WeeklyRetention;dayOfWeek=$DayOfWeek}}
      } else {
        Write-Warning -Message 'Weekly SLA configurations are not supported in this version of Rubrik CDM.'
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Weekly'
          $resources.Body.frequencies.frequency = $WeeklyFrequency
          $resources.Body.frequencies.retention = $WeeklyRetention
        }
      }
      [bool]$ParamValidation = $true
    }    

    if ($MonthlyFrequency -and $MonthlyRetention) {
      if (($uri.contains('v2')) -and $AdvancedConfig) {
        $body.frequencies += @{'monthly'=@{frequency=$MonthlyFrequency;retention=$MonthlyRetention;dayOfMonth=$DayOfMonth}}
        $body.advancedUiConfig += @{timeUnit='Monthly';retentionType=$MonthlyRetentionType}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'monthly'=@{frequency=$MonthlyFrequency;retention=$MonthlyRetention;dayOfMonth=$DayOfMonth}}
      } else { 
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Monthly'
          $resources.Body.frequencies.frequency = $MonthlyFrequency
          $resources.Body.frequencies.retention = $MonthlyRetention
        }
      }
      [bool]$ParamValidation = $true
    }  

    if ($QuarterlyFrequency -and $QuarterlyRetention) {
      if (($uri.contains('v2')) -and $AdvancedConfig) {
        $body.frequencies += @{'quarterly'=@{frequency=$QuarterlyFrequency;retention=$QuarterlyRetention;firstQuarterStartMonth=$FirstQuarterStartMonth;dayOfQuarter=$DayOfQuarter}}
        $body.advancedUiConfig += @{timeUnit='Quarterly';retentionType=$QuarterlyRetentionType}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'quarterly'=@{frequency=$QuarterlyFrequency;retention=$QuarterlyRetention;firstQuarterStartMonth=$FirstQuarterStartMonth;dayOfQuarter=$DayOfQuarter}}
      } else { 
        Write-Warning -Message 'Quarterly SLA configurations are not supported in this version of Rubrik CDM.'
      }
      [bool]$ParamValidation = $true
    }  

    if ($YearlyFrequency -and $YearlyRetention) {
      if (($uri.contains('v2')) -and $AdvancedConfig) {
        $body.frequencies += @{'yearly'=@{frequency=$YearlyFrequency;retention=$YearlyRetention;yearStartMonth=$YearStartMonth;dayOfYear=$DayOfYear}}
        $body.advancedUiConfig += @{timeUnit='Yearly';retentionType='Yearly'}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'yearly'=@{frequency=$YearlyFrequency;retention=$YearlyRetention;yearStartMonth=$YearStartMonth;dayOfYear=$DayOfYear}}
      } else {  
          $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Yearly'
          $resources.Body.frequencies.frequency = $YearlyFrequency
          $resources.Body.frequencies.retention = $YearlyRetention
        }
      }
      [bool]$ParamValidation = $true
    } 
    
    Write-Verbose -Message 'Checking for the $ParamValidation flag' 
    if ($ParamValidation -ne $true) 
    {
      throw 'You did not specify any frequency and retention values'
    }    
    
    $body = ConvertTo-Json $body -Depth 10
    Write-Verbose -Message "Body = $body"
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function New-RubrikSnapshot
{
  <#  
      .SYNOPSIS
      Takes an on-demand Rubrik snapshot of a protected object

      .DESCRIPTION
      The New-RubrikSnapshot cmdlet will trigger an on-demand snapshot for a specific object (virtual machine, database, fileset, etc.)

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/New-RubrikSnapshot.html

      .EXAMPLE
      Get-RubrikVM 'Server1' | New-RubrikSnapshot -Forever
      This will trigger an on-demand backup for any virtual machine named "Server1" that will be retained indefinitely and available under Unmanaged Objects.

      .EXAMPLE
      Get-RubrikFileset 'C_Drive' | New-RubrikSnapshot -SLA 'Gold'
      This will trigger an on-demand backup for any fileset named "C_Drive" using the "Gold" SLA Domain.

      .EXAMPLE
      Get-RubrikDatabase 'DB1' | New-RubrikSnapshot -ForceFull -SLA 'Silver'
      This will trigger an on-demand backup for any database named "DB1" and force the backup to be a full rather than an incremental.

      .EXAMPLE
      Get-RubrikOracleDB -Id OracleDatabase:::e7d64866-b2ee-494d-9a61-46824ae85dc1 | New-RubrikSnapshot -ForceFull -SLA Bronze
      This will trigger an on-demand backup for the Oracle database by its ID, and force the backup to be a full rather than an incremental.

      .EXAMPLE
      New-RubrikSnapShot -Id MssqlDatabase:::ee7aead5-6a51-4f0e-9479-1ed1f9e31614 -SLA Gold
      This will trigger an on-demand backup by ID, in this example it is the ID of a MSSQL Database
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik's id of the object
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # The SLA Domain in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # The snapshot will be retained indefinitely and available under Unmanaged Objects
    [Parameter(ParameterSetName = 'SLA_Forever')]
    [Switch]$Forever,
    # Whether to force a full snapshot or an incremental. Only valid with MSSQL and Oracle Databases.
    [Alias('forceFullSnapshot')]
    [Switch]$ForceFull,
    # SLA id value
    [String]$SLAID,    
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

    #region One-off

    # Display a warning if -ForceFull is used with anything other than MSSQL or Oracle
    if ((-Not ($id.contains('OracleDatabase:::') -or $id.contains('MssqlDatabase:::'))) -and $ForceFull) {
      Write-Warning -Message ('Using the ForceFull parameter with a {0} object is not possible, this functionality is only available to Oracle and MSSQL databases. The process will continue to take an incremental snapshot' -f $Id.Split(':')[0])
    }

    if ($PSCmdlet.ShouldProcess($SLA, 'Testing SLA')) {
      $SLAID = Test-RubrikSLA -SLA $SLA -DoNotProtect $Forever
    }
    #endregion One-off

    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values) 



    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result
    
    return $result

  } # End of process
} # End of function
#Requires -Version 3
function New-RubrikVCenter
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and creates new vCenter connection
            
      .DESCRIPTION
      The New-RubrikVCenter cmdlet will  creates new vCenter connection on the system. This does require authentication.
            
      .NOTES
      Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      New-RubrikVCenter -hostname "test-vcenter.domain.com"
      This will creates new vCenter connection to "test-vcenter.domain.com" on the current Rubrik cluster  
  #>

  [CmdletBinding()]
  Param(
    # Hostname (FQDN) of your vCenter Server
    [Parameter(Mandatory=$True)]
    [string]$Hostname,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # ID of the Rubrik cluster or me for self
    [String]$id = '',
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    $Credentials=$(Get-Credential -Message "Type vCenter Credentials.")
    $username = $Credentials.UserName
    $password = $Credentials.GetNetworkCredential().Password

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
    Write-Verbose -Message "Build the body"
    #[PSCustomObject]$advancedOptions

    #Write-Verbose "Advanced Options = $advancedOptions"

    $body = @{
        $resources.Body.hostname = $hostname
        $resources.Body.username = $username
        $resources.Body.password = $password
    }
        
    $body = ConvertTo-Json $body
    Write-Verbose -Message "Body = $body"
    #endregion
    
    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    #$uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    #$body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function New-RubrikVMDKMount
{
  <#  
      .SYNOPSIS
      Create a new live mount of a VMDK
      
      .DESCRIPTION
      The New-RubrikVMDKMount cmdlet is used to create a new mount of a specific virtual disk (vmdk) on the TargetVM of the selected Snapshot.      
      
      .NOTES
      Written by Pierre Flammer for community usage
      Twitter: @PierreFlammer
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .PARAMETER
      ATTENTION: Names have to match the names configured in Rubrik!!!
      SnapshotID: ID of the Rubrik snaphot of the source VM
      TargetVM: Name of the VM where the VMDK(s) will be mounted
      AllDisks: If this parameter is used all VMDKs will be mounted to the target VM. 
                If one has to enter a number and select one VMDK.
      VLAN: Specify the VLAN number

      .EXAMPLE
      New-RubrikVMDKMount -snapshotid 'cc1b363a-a0d4-40b7-9b09-7b8f3a805b27' -TargetVM 'VM2' 
      
      New-RubrikVMDKMount -snapshotid 'cc1b363a-a0d4-40b7-9b09-7b8f3a805b27' -TargetVM 'VM2' -AllDisks -VLAN 50
     
  #>

  [CmdletBinding()]
  Param(
    # Snapshot ID containing VMDKs to attach to target VM
    [Parameter(Position = 0,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [Alias('id')]
    [String]$SnapshotID,
    # Target VM to attach the Live Mount disk(s)
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$TargetVM,
    # Switch to specitfy whether or not to mount all VMDKs in snapshot
    [parameter(Mandatory=$false)]
    [Switch]$AllDisks,
    # VLAN used by ESXi to mount the datastore
    [parameter(Mandatory=$false)]
    [Int]$VLAN,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $snapshotid
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        
    $TargetID = Get-RubrikVM -name $TargetVM
    if ($TargetID.count -gt 1) {
        # Found more than one VM with the target name
        "Found multiple VMs with name " + $TargetVM + ". Please select the one to use." | Out-Host
        "--------------------------------" | Out-Host
        $TargetID.id  | ForEach-Object -Begin {$i=0} -Process {"VM $i - $($_)";$i++} | Out-Host
        $selection = Read-Host 'Enter ID of selected VM'
        $TargetID = $TargetID[$selection].id
    } else {
        $TargetID = $TargetID.id
    }

    Write-Verbose -Message "Build the body"

    $body = @{
        $resources.Body.targetVmId = $TargetID
        vmdkIds = @() 
    }

    # Disk configuration
    $snapdiskdetails = Get-RubrikVMSnapshot -id $snapshotid 
    #$snapdiskdetails = Get-RubrikVMSnapshot -id 'cc1b363a-a0d4-40b7-9b09-7b8f3a805b27'
    if ($AllDisks) {
        #Parameter -AllDisks was used -> Mount all VMDKs
        foreach ($disk in $snapdiskdetails.snapshotDiskDetails)
        {
            $body.vmdkIds += $disk.virtualDiskId
        }
    } else {
        #Get List of VMDKs and mount the selected one
        "Please select a VMDK to use:" | Out-Host
        "--------------------------------" | Out-Host
        $snapdiskdetails.snapshotDiskDetails  | ForEach-Object -Begin {$i=0} -Process {"VMDK $i - $($_.filename)";$i++} | Out-Host
        $selection = Read-Host 'Enter ID of selected VMDK'

        $body.vmdkIds += $snapdiskdetails.snapshotDiskDetails[$selection].virtualDiskId
    }

    $body = ConvertTo-Json $body
    Write-Verbose -Message "Body = $body"

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function New-RubrikVolumeGroupMount
{
  <#  
      .SYNOPSIS
      Create a new live mount of a protected volume group
      
      .DESCRIPTION
      The New-RubrikVolumeGroupMount cmdlet is used to create a new volume group mount on the TargetHost of the selected Snapshot.
      The Snapshot object contains the snapID and all drives that are included in the snapshot.
      
      .NOTES
      Written by Pierre Flammer for community usage
      Twitter: @PierreFlammer
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      New-RubrikVolumeGroupMount -TargetHost 'Restore-Server1' -VolumeGroupSnapshot $snap -ExcludeDrives -$DrivestoExclude
     
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Target host to attach the Live Mount disk(s)
    [Parameter(Mandatory=$true)]
    [String]$TargetHost,
    # Rubrik VolumeGroup Snapshot Array
    [Parameter(Mandatory = $true)]
    [object]$VolumeGroupSnapshot,
    # Rubrik server IP or FQDN
    [Parameter(ParameterSetName = 'Create')]
    [Array]$ExcludeDrives,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $VolumeGroupSnapshot.id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        
    $TargetHostID = Get-RubrikHost -name $TargetHost
    $TargetHostID = $TargetHostID.id

    Write-Verbose -Message "Build the body"
    
    $body = @{
        $resources.Body.targetHostid = $TargetHostID
        volumeConfigs = @()
        $resources.Body.smbValidUsers = @()
    }

    foreach ($disk in $VolumeGroupSnapshot.includedVolumes)
    {
        if ($ExcludeDrives -contains $disk.mountPoints.Replace(":\",""))
        {
            Write-Verbose -Message "Skipping Disk $disk.mountPoints" -Verbose
        } 
        else 
        {
            $body.volumeConfigs += @{$resources.body.volumeConfigs.volumeId = $disk.id
            $resources.body.volumeConfigs.mountpointonhost = 'c:\rubrik-mounts\Disk-' + $disk.mountpoints.Replace(':','').Replace('\','')}
        }
    }

    $body = ConvertTo-Json $body

    Write-Verbose -Message "Body = $body"
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Protect-RubrikDatabase
{
  <#
      .SYNOPSIS
      Connects to Rubrik and assigns an SLA to a database
            
      .DESCRIPTION
      The Protect-RubrikDatabase cmdlet will update a database's SLA Domain assignment within the Rubrik cluster.
      The SLA Domain contains all policy-driven values needed to protect workloads.
      Note that this function requires the Database ID value, not the name of the database, since database names are not unique across hosts.
      It is suggested that you first use Get-RubrikDatabase to narrow down the one or more database / instance / hosts to protect, and then pipe the results to Protect-RubrikDatabase.
      You will be asked to confirm each database you wish to protect, or you can use -Confirm:$False to skip confirmation checks.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Protect-RubrikDatabase.html
            
      .EXAMPLE
      Get-RubrikDatabase -Name "DB1" | Protect-RubrikDatabase -SLA 'Gold'
      This will assign the Gold SLA Domain to any database named "DB1"

      .EXAMPLE
      Get-RubrikDatabase -Name "DB1" -Instance "MSSQLSERVER" | Protect-RubrikDatabase -SLA 'Gold' -Confirm:$False
      This will assign the Gold SLA Domain to any database named "DB1" residing on an instance named "MSSQLSERVER" without asking for confirmation
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Database ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()] 
    [String]$id,
    # The SLA Domain in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Removes the SLA Domain assignment
    [Parameter(ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # Inherits the SLA Domain assignment from a parent object
    [Parameter(ParameterSetName = 'SLA_Inherit')]
    [Switch]$Inherit,
    # SLA id value
    [Alias('configuredSlaDomainId')]
    [String]$SLAID,
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

    #region One-off
    $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    #endregion One-off

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Protect-RubrikFileset
{
  <#
      .SYNOPSIS
      Connects to Rubrik and assigns an SLA to a fileset
            
      .DESCRIPTION
      The Protect-RubrikFileset cmdlet will update a fileset's SLA Domain assignment within the Rubrik cluster.
      The SLA Domain contains all policy-driven values needed to protect data.
      Note that this function requires the fileset ID value, not the name of the fileset, since fileset names are not unique across clusters.
      It is suggested that you first use Get-RubrikFileset to narrow down the one or more filesets to protect, and then pipe the results to Protect-RubrikFileset.
      You will be asked to confirm each fileset you wish to protect, or you can use -Confirm:$False to skip confirmation checks.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Protect-RubrikFileset.html
            
      .EXAMPLE
      Get-RubrikFileset 'C_Drive' | Protect-RubrikFileset -SLA 'Gold'
      This will assign the Gold SLA Domain to any fileset named "C_Drive"

      .EXAMPLE
      Get-RubrikFileset 'C_Drive' -HostName 'Server1' | Protect-RubrikFileset -SLA 'Gold' -Confirm:$False
      This will assign the Gold SLA Domain to the fileset named "C_Drive" residing on the host named "Server1" without asking for confirmation
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Fileset ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # The SLA Domain in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Removes the SLA Domain assignment
    [Parameter(ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # SLA id value
    [Alias('configuredSlaDomainId')]
    [String]$SLAID,    
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

    #region One-off
    $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    #endregion One-off

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Protect-RubrikHyperVVM
{
  <#
      .SYNOPSIS
      Connects to Rubrik and assigns an SLA to a virtual machine
            
      .DESCRIPTION
      The Protect-RubrikHyperVVM cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster.
      The SLA Domain contains all policy-driven values needed to protect workloads.
      Note that this function requires the virtual machine ID value, not the name of the virtual machine, since virtual machine names are not unique across clusters.
      It is suggested that you first use Get-RubrikHyperVVM to narrow down the one or more virtual machine to protect, and then pipe the results to Protect-RubrikVM.
      You will be asked to confirm each virtual machine you wish to protect, or you can use -Confirm:$False to skip confirmation checks.
            
      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/
            
      .EXAMPLE
      Get-RubrikHyperVVM "VM1" | Protect-RubrikHyperVVM -SLA 'Gold'
      This will assign the Gold SLA Domain to any virtual machine named "VM1"

      .EXAMPLE
      Get-RubrikHyperVVM "VM1" -SLA Silver | Protect-RubrikHyperVVM -SLA 'Gold' -Confirm:$False
      This will assign the Gold SLA Domain to any virtual machine named "VM1" that is currently assigned to the Silver SLA Domain
      without asking for confirmation
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High',DefaultParameterSetName="None")]
  Param(
    # Virtual machine ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # The SLA Domain in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Inherits the SLA Domain assignment from a parent object
    [Parameter(ParameterSetName = 'SLA_Inherit')]
    [Switch]$Inherit,
    # Removes the SLA Domain assignment
    [Parameter(ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # SLA id value
    [Alias('configuredSlaDomainId')]
    [String]$SLAID = (Test-RubrikSLA -SLA $SLA -DoNotProtect $DoNotProtect -Inherit $Inherit -Mandatory:$true),    
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
#Requires -Version 3
function Protect-RubrikNutanixVM
{
  <#
      .SYNOPSIS
      Connects to Rubrik and assigns an SLA to a virtual machine
            
      .DESCRIPTION
      The Protect-RubrikNutanixVM cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster.
      The SLA Domain contains all policy-driven values needed to protect workloads.
      Note that this function requires the virtual machine ID value, not the name of the virtual machine, since virtual machine names are not unique across clusters.
      It is suggested that you first use Get-RubrikNutanixVM to narrow down the one or more virtual machine to protect, and then pipe the results to Protect-RubrikVM.
      You will be asked to confirm each virtual machine you wish to protect, or you can use -Confirm:$False to skip confirmation checks.
            
      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/
            
      .EXAMPLE
      Get-RubrikNutanixVM "VM1" | Protect-RubrikNutanixVM -SLA 'Gold'
      This will assign the Gold SLA Domain to any virtual machine named "VM1"

      .EXAMPLE
      Get-RubrikNutanixVM "VM1" -SLA Silver | Protect-RubrikNutanixVM -SLA 'Gold' -Confirm:$False
      This will assign the Gold SLA Domain to any virtual machine named "VM1" that is currently assigned to the Silver SLA Domain
      without asking for confirmation
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High',DefaultParameterSetName="None")]
  Param(
    # Virtual machine ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # The SLA Domain in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Inherits the SLA Domain assignment from a parent object
    [Parameter(ParameterSetName = 'SLA_Inherit')]
    [Switch]$Inherit,
    # Removes the SLA Domain assignment
    [Parameter(ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # SLA id value
    [Alias('configuredSlaDomainId')]
    [String]$SLAID = (Test-RubrikSLA -SLA $SLA -DoNotProtect $DoNotProtect -Inherit $Inherit -Mandatory:$true),    
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
#Requires -Version 3

function Protect-RubrikTag
{
  <#
      .SYNOPSIS
      Connects to Rubrik and assigns an SLA Domain based on a vSphere category and tag value

      .DESCRIPTION
      The Protect-RubrikTag cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster.
      The SLA Domain contains all policy-driven values needed to protect workloads.
      Make sure you have PowerCLI installed and connect to the required vCenter Server.

      .NOTES
      Written by Jason Burrell for community usage
      Twitter: @jasonburrell2

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Protect-RubrikTag.html

      .EXAMPLE
      Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -SLA 'Gold'
      This will assign the Gold SLA Domain to any VM tagged with Gold in the Rubrik category

      .EXAMPLE
      Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -SLA 'Titanium'
      This will assign the Titanium SLA Domain to any VM tagged with Gold in the Rubrik category

      .EXAMPLE
      Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -DoNotProtect
      This will remove protection from any VM tagged with Gold in the Rubrik category

      .EXAMPLE
      Protect-RubrikTag -Tag 'Gold' -Category 'Rubrik' -Inherit
      This will flag any VM tagged with Gold in the Rubrik category to inherit the SLA Domain of its parent object
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # vSphere Tag
    [Parameter(Mandatory = $true)]
    [String]$Tag,
    # vSphere Tag Category
    [Parameter(Mandatory = $true)]
    [String]$Category,
    # The SLA Domain in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Removes the SLA Domain assignment
    [Parameter(ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # Inherits the SLA Domain assignment from a parent object
    [Parameter(ParameterSetName = 'SLA_Inherit')]
    [Switch]$Inherit,
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

    # Check to ensure that a session to the vSphere Center Server exists and load the needed header data for authentication
    Test-VMwareConnection

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
    $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect

    Write-Verbose -Message "Gathering a list of VMs associated with Category $Category and Tag $Tag"
    try
    {
      $vmlist = Get-VM -Tag (Get-Tag -Name $Tag -Category $Category) | Get-View
      # This will pull out the vCenter UUID assigned to the parent vCenter Server by Rubrik
      # Reset switches to prevent Get-RubrikVM from picking them up (must be a better way?)
      $DoNotProtect = $false
      $Inherit = $false
      if ($vmlist.count -gt 0) {
        $vcuuid = ((Get-RubrikVM -VM ($vmlist[0].Name) -PrimaryClusterID 'local' | where-object {$_.isRelic -eq $false}).vCenterId) -replace 'vCenter:::', ''
      }
    }
    catch
    {
      throw $_
    }

    if ($vmlist.count -eq 0) {
      Write-Verbose -Message "No VMs found with Category $Category and Tag $Tag"
      return $null
    }

    Write-Verbose -Message 'Building an array of Rubrik Managed IDs'
    [array]$vmbulk = @()
    foreach ($_ in $vmlist)
    {
      $vmbulk += 'VirtualMachine:::' + $vcuuid + '-' + $($_.moref.value)
      Write-Verbose -Message "Found $($vmbulk.count) records"
    }
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $SLAID
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri

    #region One-off
    Write-Verbose -Message 'Creating the array to mass assign the list of IDs'
    $body = @{
      managedIds = $vmbulk
    }
    $body = ConvertTo-Json -InputObject $body
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#Requires -Version 3
function Protect-RubrikVM
{
  <#
      .SYNOPSIS
      Connects to Rubrik and assigns an SLA to a virtual machine
            
      .DESCRIPTION
      The Protect-RubrikVM cmdlet will update a virtual machine's SLA Domain assignment within the Rubrik cluster.
      The SLA Domain contains all policy-driven values needed to protect workloads.
      Note that this function requires the virtual machine ID value, not the name of the virtual machine, since virtual machine names are not unique across clusters.
      It is suggested that you first use Get-RubrikVM to narrow down the one or more virtual machine to protect, and then pipe the results to Protect-RubrikVM.
      You will be asked to confirm each virtual machine you wish to protect, or you can use -Confirm:$False to skip confirmation checks.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Protect-RubrikVM.html
            
      .EXAMPLE
      Get-RubrikVM "VM1" | Protect-RubrikVM -SLA 'Gold'
      This will assign the Gold SLA Domain to any virtual machine named "VM1"

      .EXAMPLE
      Get-RubrikVM "VM1" -SLA Silver | Protect-RubrikVM -SLA 'Gold' -Confirm:$False
      This will assign the Gold SLA Domain to any virtual machine named "VM1" that is currently assigned to the Silver SLA Domain
      without asking for confirmation
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High',DefaultParameterSetName="None")]
  Param(
    # Virtual machine ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # The SLA Domain in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
    # Removes the SLA Domain assignment
    [Parameter(ParameterSetName = 'SLA_Unprotected')]
    [Switch]$DoNotProtect,
    # Inherits the SLA Domain assignment from a parent object
    [Parameter(ParameterSetName = 'SLA_Inherit')]
    [Switch]$Inherit,
    # SLA id value
    [Alias('configuredSlaDomainId')]
    [String]$SLAID = (Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect -Mandatory:$true),    
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
#requires -Version 3
function Register-RubrikBackupService
{
  <#  
      .SYNOPSIS
      Register the Rubrik Backup Service

      .DESCRIPTION
      Register the Rubrik Backup Service for the specified VM

      .NOTES
      Written by Pierre-François Guglielmi
      Twitter: @pfguglielmi
      GitHub: pfguglielmi

      .LINK
      https://github.com/rubrikinc/rubrik-sdk-for-powershell

      .EXAMPLE
      Get-RubrikVM -Name "demo-win01" | Register-RubrikBackupService -Verbose
      Get the details of VMware VM demo-win01 and register the Rubrik Backup Service installed on it with the Rubrik cluster
      
      .EXAMPLE
      Get-RubrikNutanixVM -Name "demo-ahv01" | Register-RubrikBackupService -Verbose
      Get the details of Nutanix VM demo-win01 and register the Rubrik Backup Service installed on it with the Rubrik cluster

      .EXAMPLE
      Get-RubrikHyperVVM -Name "demo-hyperv01" | Register-RubrikBackupService -Verbose
      Get the details of Hyper-V VM demo-win01 and register the Rubrik Backup Service installed on it with the Rubrik cluster

      .EXAMPLE
      Register-RubrikBackupService -VMid VirtualMachine:::2af8fe5f-5b64-44dd-a9e0-ec063753b823-vm-37558
      Register the Rubrik Backup Service installed on this VM with the Rubrik cluster by specifying the VM id
  #>

  [CmdletBinding()]
  Param(
    # ID of the VM which agent needs to be registered
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [Alias('VMid')]
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
#requires -Version 3
function Remove-RubrikAPIToken
{
  <#
      .SYNOPSIS
      Removes a Rubrik API Token.

      .DESCRIPTION
      The Remove-RubrikAPIToken cmdlet is used to remove an API Token from the Rubrik cluster.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikAPIToken.html

      .EXAMPLE
      Remove-RubrikAPIToken -TokenId "11111111-2222-3333-4444-555555555555"
      This will remove the API Token matching id "11111111-2222-3333-4444-555555555555".

      .EXAMPLE
      Remove-RubrikAPIToken -TokenId ("11111111-2222-3333-4444-555555555555","aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
      This will remove the API Tokens matching id values "11111111-2222-3333-4444-555555555555" and "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" in one request.

  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # API Token ID value(s). For multiple ID values, encase the values in parenthesis and separate each ID with a comma. See the examples for more details.
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias('tokenIds')]
    [Array]$TokenId,
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
#Requires -Version 3
function Remove-RubrikDatabaseMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and removes one or more database live mounts
            
      .DESCRIPTION
      The Remove-RubrikDatabaseMount cmdlet is used to request the deletion of one or more instant database mounts
            
      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikDatabaseMount.html

      .EXAMPLE
      Remove-RubrikDatabaseMount -id '11111111-2222-3333-4444-555555555555'
      This will remove mount id "11111111-2222-3333-4444-555555555555".
            
      .EXAMPLE
      Get-RubrikDatabaseMount | Remove-RubrikDatabaseMount
      This will remove all mounted databases.

      .EXAMPLE
      Get-RubrikDatabaseMount -source_database_name 'BAR' | Remove-RubrikDatabaseMount
      This will remove any mounts found using the datase name as a base reference.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The Rubrik ID value of the mount
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # Force unmount to deal with situations where host has been moved.
    [Switch]$Force,
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
#requires -Version 3
function Remove-RubrikFileset
{
  <#  
      .SYNOPSIS
      Delete a fileset by specifying the fileset ID

      .DESCRIPTION
      The Remove-RubrikFileset cmdlet is used to remove a fileset registered with the Rubrik cluster.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikFileset.html

      .EXAMPLE
      Get-RubrikFileset -Name 'C_Drive' | Remove-RubrikHost
      This will remove any fileset that matches the name "C_Drive"

      .EXAMPLE
      Remove-RubrikFileset -id 'Fileset:::111111-2222-3333-4444-555555555555'
      This will specifically remove the fileset id matching "Fileset:::111111-2222-3333-4444-555555555555"
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The Rubrik ID value of the fileset
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
#requires -Version 3
function Remove-RubrikHost
{
  <#  
      .SYNOPSIS
      Delete host by specifying the host ID.

      .DESCRIPTION
      The Remove-RubrikHost cmdlet is used to remove a host registered with the Rubrik cluster.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikHost.html

      .EXAMPLE
      Get-RubrikHost -Name 'Server1.example.com' | Remove-RubrikHost
      This will remove a host that matches the name "Server1.example.com"

      .EXAMPLE
      Remove-RubrikHost -id 'Host:::111111-2222-3333-4444-555555555555'
      This will specifically remove the host id matching "Host:::111111-2222-3333-4444-555555555555"
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The Rubrik ID value of the host
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
#requires -Version 3
function Remove-RubrikLogShipping
{
  <#  
      .SYNOPSIS
      Delete a specified log shipping configuration from Rubrik

      .DESCRIPTION
      Based on an id associated to a Rubrik Log Shipping job, we can delete the configuration and also remove the secondary database. 

      .NOTES
      Written by Chris Lumnah
      Twitter: @lumnah
      GitHub: clumnah
      

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikLogShipping -PrimaryDatabaseName 'AthenaAM1-SQL16-1-2016' -SecondaryDatabaseName 'AthenaAM1-SQL16-1-2016'  | Remove-RubrikLogShipping
  #>

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,

    [Alias('delete_secondary_database')]
    [switch]$DeleteSecondaryDatabase,
    
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
#requires -Version 3
function Remove-RubrikManagedVolume
{
  <#  
      .SYNOPSIS
      Deletes a Rubrik Managed Volume 

      .DESCRIPTION
      The Remove-RubrikManagedVolume cmdlet is used to dlete a Managed Volume

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Remove-RubrikManagedVolume -id ManagedVolume:::f68ecd45-bdb9-46dd-aea4-8f041fb2dec2

      Remove the specified managed volume. All associated snapshots will become unmaged objects.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Name of managed volume
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName = $true)]
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
#requires -Version 3
function Remove-RubrikManagedVolumeExport
{
  <#  
      .SYNOPSIS
      Deletes a Rubrik Managed Volume export

      .DESCRIPTION
      The Remove-RubrikManagedVolumeExport cmdlet is used to delete a Managed Volume export

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Remove-RubrikManagedVolumeExport -id deddca39-b8ca-407c-8f1c-af9866f7ba67

      Remove the specified managed volume export (live mount).

      .EXAMPLE
      Get-RubrikManagedVolumeExport -SourceManagedVolumeName 'foo' | Remove-RubrikManagedVolumeExport

      Remove all the managed volume exports (live mounts) for the managed volume 'foo'.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Id of managed volume export
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName = $true)]
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
#Requires -Version 3
function Remove-RubrikMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and removes one or more live mounts
            
      .DESCRIPTION
      The Remove-RubrikMount cmdlet is used to request the deletion of one or more instant mounts
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikMount.html

      .EXAMPLE
      Remove-RubrikMount -id '11111111-2222-3333-4444-555555555555'
      This will remove mount id "11111111-2222-3333-4444-555555555555".
            
      .EXAMPLE
      Get-RubrikMount | Remove-RubrikMount
      This will remove all mounted virtual machines.

      .EXAMPLE
      Get-RubrikMount -VMID (Get-RubrikVM -VM 'Server1').id | Remove-RubrikMount
      This will remove any mounts found using the virtual machine named "Server1" as a base reference.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The Rubrik ID value of the mount
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Force unmount to deal with situations where host has been moved.
    [Switch]$Force,
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
#requires -Version 3
function Remove-RubrikNASShare
{
  <#  
      .SYNOPSIS
      {required: high level overview}

      .DESCRIPTION
      {required: more detailed description of the function's purpose}

      .NOTES
      Written by {required}
      Twitter: {optional}
      GitHub: {optional}
      Any other links you'd like here

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikNASShare -Name 'FOO' | Remove-RubrikNASShare
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # NAS Share ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]    
    [String]$Id,  
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
#Requires -Version 3
function Remove-RubrikReport
{
  <#  
      .SYNOPSIS
      Removes one or more reports created in Rubrik Envision

      .DESCRIPTION
      The Remove-RubrikReport cmdlet is used to delete any number of Rubrik Envision reports

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikReport.html

      .EXAMPLE
      Get-RubrikReport | Remove-RubrikReport -Confirm:$true
      This will delete all reports and force confirmation for each delete operation
      
      .EXAMPLE
      Get-RubrikReport -Name 'SLA' -Type Custom | Remove-RubrikReport
      This will delete all custom reports that contain the string "SLA"

      .EXAMPLE
      Get-RubrikReport -id '11111111-2222-3333-4444-555555555555' | Remove-RubrikReport -Confirm:$false
      This will delete the report id "11111111-2222-3333-4444-555555555555" without confirmation
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The Rubrik ID value of the report
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
#Requires -Version 3
function Remove-RubrikSLA 
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and removes SLA Domains
            
      .DESCRIPTION
      The Remove-RubrikSLA cmdlet will request that the Rubrik API delete an SLA Domain.
      The SLA Domain must have zero protected objects (VMs, filesets, databases, etc.) in order to be successful.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikSLA.html
            
      .EXAMPLE
      Get-RubrikSLA -SLA 'Gold' | Remove-RubrikSLA
      This will attempt to remove the Gold SLA Domain from Rubrik if there are no objects being protected by the policy
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # SLA Domain id
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
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
#Requires -Version 3
function Remove-RubrikUnmanagedObject
{
  <#  
      .SYNOPSIS
      Removes one or more unmanaged objects known to a Rubrik cluster

      .DESCRIPTION
      The Remove-RubrikUnmanagedObject cmdlet is used to remove unmanaged objects that have been stored in the cluster
      In most cases, this will be on-demand snapshots that are associated with an object (virtual machine, fileset, database, etc.)

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikUnmanagedObject.html

      .EXAMPLE
      Get-RubrikUnmanagedObject | Remove-RubrikUnmanagedObject
      This will remove all unmanaged objects from the cluster

      .EXAMPLE
      Get-RubrikUnmanagedObject -Type 'WindowsFileset' | Remove-RubrikUnmanagedObject -Confirm:$false
      This will remove any unmanaged objects related to filesets applied to Windows Servers and supress confirmation for each activity

      .EXAMPLE
      Get-RubrikUnmanagedObject -Status 'Unprotected' -Name 'Server1' | Remove-RubrikUnmanagedObject
      This will remove any unmanaged objects associated with any workload named "Server1" that is currently unprotected
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The id of the unmanaged object.
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [Alias('objectId')]
    [String]$id,
    # The type of the unmanaged object. This may be VirtualMachine, MssqlDatabase, LinuxFileset, or WindowsFileset.
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [Alias('objectType')]
    [String]$Type,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI)
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)        
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Remove-RubrikVCenter 
{
    <#  
        .SYNOPSIS
        Removes an existing vCenter connection
            
        .DESCRIPTION
        The Remove-RubrikVCenter cmdlet will remove an existing vCenter connection on the system. This does require authentication.
            
        .NOTES
        Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage
            
        .LINK
        https://github.com/rubrikinc/PowerShell-Module
            
        .EXAMPLE
        Remove-RubrikVCenter -id "vCenter:::9e4299f5-dd99-4ec1-adee-cacb311b9507"
        This will remove the vCenter connection with ID "vCenter:::9e4299f5-dd99-4ec1-adee-cacb311b9507" from the current Rubrik cluster.
    #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # ID of the vCenter Server to remove
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
#requires -Version 3
function Remove-RubrikVMSnapshot
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and removes an expired VMware VM snapshot available for garbage collection.
            
      .DESCRIPTION
      The Remove-RubrikVMSnapshot cmdlet will request that the Rubrik API delete an an expired VMware VM snapshot.
      The snapshot must be an on-demand snapshot or a snapshot from a virtual machine that is not assigned to an SLA Domain.
            
      .NOTES
      Written by Matt Elliott for community usage
      Twitter: @NetworkBrouhaha
      GitHub: shamsway
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikVMSnapshot.html
           
      .EXAMPLE
      Remove-RubrikVMSnapshot -id '01234567-8910-1abc-d435-0abc1234d567'
      This will attempt to remove VM snapshot (backup) data with the snapshot id `01234567-8910-1abc-d435-0abc1234d567`

      .EXAMPLE
      Remove-RubrikVMSnapshot -id '01234567-8910-1abc-d435-0abc1234d567' -location local
      This will attempt to remove the local copy of the VM snapshot (backup) data with the snapshot id `01234567-8910-1abc-d435-0abc1234d567`

      .EXAMPLE
      Get-RubrikVM OldVM1 | Get-RubrikSnapshot -Date '03/21/2017' | Remove-RubrikVMSnapshot
      This will attempt to remove any snapshot from `03/21/2017` for VM `OldVM1`.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # ID of the snapshot to delete
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Snapshot location to delete, either "local" or "all". Defaults to "all"
    [String]$location = "all",
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Remove-RubrikVolumeGroupMount
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and removes one or more volume group mounts
            
      .DESCRIPTION
      The Remove-RubrikMount cmdlet is used to request the deletion of one or more volume group live mounts
            
      .NOTES
      Written by Pierre Flammer for community usage
      Twitter: @PierreFlammer
            
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Remove-RubrikVolumeGroupMount -id '11111111-2222-3333-4444-555555555555'
      This will remove volume mount id "11111111-2222-3333-4444-555555555555".
            
      .EXAMPLE
      Get-RubrikVolumeGroupMount | Remove-RubrikVolumeGroupMount
      This will remove all mounted volume groups.

      .EXAMPLE
      Get-RubrikVolumeGroupMount -source_host 'Server1' | Remove-RubrikVolumeGroupMount
      This will remove any volume group mounts found using the host named "Server1" as a base reference.
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # The Rubrik ID value of the mount
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Force unmount to deal with situations where host has been moved.
    [Switch]$Force,
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
#requires -Version 3
function Reset-RubrikLogShipping
{
  <#  
      .SYNOPSIS
      Reseed a secondary database

      .DESCRIPTION
      Reseed a secondary database

      .NOTES
      Written by Chris Lumnah 
      Twitter: lumnah
      GitHub: clumnah
      

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikLogShipping -PrimaryDatabaseName 'AthenaAM1-SQL16-1-2016' -SecondaryDatabaseName 'AthenaAM1-SQL16-1-2016' | Reset-RubrikLogShipping -state STANDBY -DisconnectStandbyUsers
  #>

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    
    [ValidateSet("RESTORING", "STANDBY")]
    [String]$state,

    [Alias('shouldDisconnectStandbyUsers')]
    [switch]$DisconnectStandbyUsers,  

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
#Requires -Version 3
function Restore-RubrikDatabase
{
  <#
      .SYNOPSIS
      Connects to Rubrik and restores a MSSQL database

      .DESCRIPTION
      The Restore-RubrikDatabase command will request a database restore from a Rubrik Cluster to a MSSQL instance. This
      is an inplace restore, meaning it will overwrite the existing asset.

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .EXAMPLE
      Restore-RubrikDatabase -id MssqlDatabase:::c5ecf3ef-248d-4bb2-8fe1-4d3c820a0e38 -FinishRecovery -maxDataStreams 4 -timestampMs 1492661627000
      
      Restore database to declared epoch ms timestamp.

      .EXAMPLE
      Restore-RubrikDatabase -id $db.id -recoveryDateTime (Get-Date (Get-RubrikDatabase $db).latestRecoveryPoint) -maxDataStreams 1 -FinishRecovery

      Restore the $db (where $db is the outoput of a Get-RubrikDatabase call) to the most recent recovery point for that database.

      .EXAMPLE
      Get-RubrikDatabase -Name db01 | Restore-RubrikDatabase -FinishRecovery -maxDataStreams 6 -timestampMs 3492661627000
      
      Restore using the pipeline to get the database ID.
      
      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Remove-RubrikDatabase.html
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik identifier of database to be exported
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$Id,
    # Number of parallel streams to copy data
    [int]$MaxDataStreams,
    # Recovery Point desired in the form of Epoch with Milliseconds
    [Parameter(ParameterSetName='Recovery_timestamp')]
    [int64]$TimestampMs,
    # Recovery Point desired in the form of DateTime value
    [Parameter(ParameterSetName='Recovery_DateTime')]
    [datetime]$RecoveryDateTime,
    # Recovery Point desired in the form of an LSN (Log Sequence Number)
    [Parameter(ParameterSetName='Recovery_LSN')]
    [string]$RecoveryLSN,
    # If FinishRecover is true, fully recover the database
    [Switch]$FinishRecovery,
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

    #If recoveryDateTime, convert to epoch milliseconds
    if($recoveryDateTime){  
      $TimestampMs = ConvertTo-EpochMS -DateTimeValue $RecoveryDateTime
    } 
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $Id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri


    #region One-off
    Write-Verbose -Message "Build the body"
    $body = @{
      $resources.Body.finishRecovery = $FinishRecovery.IsPresent
      recoveryPoint = @()
    }

    if($MaxDataStreams){
      $body.Add($resources.Body.maxDataStreams,$MaxDataStreams)
    }

    if($RecoveryLSN){
      $body.recoveryPoint += @{lsnPoint=@{lsn=$RecoveryLSN}}
    } else {
      $body.recoveryPoint += @{timestampMs = $TimestampMs}
    }

    $body = ConvertTo-Json $body -depth 10
    Write-Verbose -Message "Body = $body"
    #endregion


    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#requires -Version 3
function Set-RubrikAvailabilityGroup
{
  <#  
      .SYNOPSIS
      Sets the protection values of an Availability Group

      .DESCRIPTION
      The Set-RubrikAvailabilityGroup cmdlet is used to set the protetion values of an Availability Group in Rubrik.

      .NOTES
      Written by Chris Lumnah for community usage
      Twitter: @lumnah
      GitHub: clumnah

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikAvailabilityGroup -GroupName 'am1-sql16ag-1ag' | Set-RubrikAvailabilityGroup -SLA GOLD
      This will set the SLA Domain to GOLD for this Availability Group

      .EXAMPLE
      Get-RubrikAvailabilityGroup -GroupName 'am1-sql16ag-1ag' | Set-RubrikAvailabilityGroup -SLA GOLD -LogBackupFrequencyInSeconds 3600 -LogRetentionHours 168
      This will set the SLA Domain to GOLD for this Availability Group with a log backup frequency of hourly and a retention of 15 days

  #>

  [CmdletBinding()]
  Param(
    #Availability Group ID
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    
    #How often we should backup the transaction log  
    [int]$LogBackupFrequencyInSeconds =-1,
    
    #How long should we keep the backup for
    [int]$LogRetentionHours =-1,    

    #Boolean declaration for copy only backups on the database.
    [switch]$CopyOnly,   

    #SLA Domain Name
    [string]$SLA,

    #SLA Domain ID
    [Alias("configuredSlaDomainId")]
    [string]$SLAID,
    
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )

    Begin 
    {

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

  Process 
  {
    #region One-off
    $SLAID = Test-RubrikSLA -SLA $SLA -Inherit $Inherit -DoNotProtect $DoNotProtect
    
    $body = @{
        $resources.Body.logRetentionHours = $logRetentionHours
        $resources.Body.logBackupFrequencyInSeconds = $logBackupFrequencyInSeconds
        $resources.Body.configuredSlaDomainId = $SLAID
        $resources.Body.copyOnly = $CopyOnly.ToBool()
      }
    #If the following params are -1, remove from body (invalid values)
    $intparams = @('LogBackupFrequencyInSeconds','LogRetentionHours')
    foreach($p in $intparams)
    {
        if((Get-Variable -Name $p).Value -eq -1){$resources.Body.Remove($p)}
    }     
    $body = ConvertTo-Json $body
    #endregion
    
    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
#    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)  
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#Requires -Version 3
function Set-RubrikBlackout
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and sets blackout (stops/starts all snaps)

      .DESCRIPTION
      The Set-RubrikBlackout cmdlet will accept a flag of true/false to set cluster blackout

      .NOTES
      Written by Pete Milanese for community usage
      Twitter: @pmilano1
      GitHub: pmilano1

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikBlacout.html

      .EXAMPLE
      Set-RubrikBlackout -Set:[$true/$false]
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik blackout value
    [Alias('isGlobalBlackoutActive')]
    [Switch]$Set,
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

#requires -Version 3
function Set-RubrikDatabase
{
  <#  
      .SYNOPSIS
      Sets Rubrik database properties

      .DESCRIPTION
      The Set-RubrikDatabase cmdlet is used to update certain settings for a Rubrik database.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikDatabase.html

      .EXAMPLE
      Set-RubrikDatabase -id MssqlDatabase:::c5ecf3ef-248d-4bb2-8fe1-4d3c820a0e38 -LogBackupFrequencyInSeconds 900

      Set the target database's log backup interval to 15 minutes (900 seconds)

      .EXAMPLE
      Get-RubrikDatabase -HostName Foo -Instance MSSQLSERVER | Set-RubrikDatabase -SLA 'Silver' -CopyOnly 

      Set all databases on host FOO to use SLA Silver and be copy only.

      .EXAMPLE

      $RubrikDatabase = Get-RubrikDatabase -Hostname am1-sql16-1 -Instance MSSQLSERVER -Name "AthenaAM1-SQL16-1-2016"
      Set-RubrikDatabase -id $RubrikDatabase.id -PreScriptPath "c:\temp\test.bat" -PreScriptErrorAction "continue" -PreTimeoutMs 300 
      
      Set a script to run before a Rubrik Backup runs against the database

      .EXAMPLE

      $RubrikDatabase = Get-RubrikDatabase -Hostname am1-sql16-1 -Instance MSSQLSERVER -Name "AthenaAM1-SQL16-1-2016"
      Set-RubrikDatabase -id $RubrikDatabase.id -PostScriptPath "c:\temp\test.bat" -PostScriptErrorAction "continue" -PostTimeoutMs 300 
      
      Set a script to run after a Rubrik Backup runs against the database

      .EXAMPLE

      $RubrikDatabase = Get-RubrikDatabase -Hostname am1-sql16-1 -Instance MSSQLSERVER -Name "AthenaAM1-SQL16-1-2016"
      Set-RubrikDatabase -id $RubrikDatabase.id -DisablePreBackupScript 
      
      Remove a script from running before a Rubrik Backup

      .EXAMPLE

      $RubrikDatabase = Get-RubrikDatabase -Hostname am1-sql16-1 -Instance MSSQLSERVER -Name "AthenaAM1-SQL16-1-2016"
      Set-RubrikDatabase -id $RubrikDatabase.id -DisablePostBackupScript 
      
      Remove a script from running after a Rubrik Backup
  #>

   [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik's database id value
    [Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
    [ValidateNotNullOrEmpty()] 
    [String]$id,
    #Number of seconds between log backups if db is in FULL or BULK_LOGGED
    #NOTE: Default of -1 is used to get around ints defaulting as 0
    [int]$LogBackupFrequencyInSeconds = -1,
    #Number of hours backups will be retained in Rubrik
    #NOTE: Default of -1 is used to get around ints defaulting as 0
    [int]$LogRetentionHours = -1,
    #Boolean declaration for copy only backups on the database.
    [Switch]$CopyOnly,
    #Pre-backup script parameters
    [Parameter(ParameterSetName = 'preBackupScript')]
    [string]$PreScriptPath,
    [Parameter(ParameterSetName = 'preBackupScript')]
    [ValidateSet('abort','continue')]
    [string]$PreScriptErrorAction,
    [Parameter(ParameterSetName = 'preBackupScript')]
    [int]$PreTimeoutMs,
    [Parameter(ParameterSetName = 'preBackupScript')]
    [switch]$DisablePreBackupScript,
    #Post-backup script parameters
    [Parameter(ParameterSetName = 'postBackupScript')]
    [string]$PostScriptPath,
    [Parameter(ParameterSetName = 'postBackupScript')]
    [ValidateSet('abort','continue')]
    [string]$PostScriptErrorAction,
    [Parameter(ParameterSetName = 'postBackupScript')]
    [int]$PostTimeoutMs,
    [Parameter(ParameterSetName = 'postBackupScript')]
    [switch]$DisablePostBackupScript,
    #Number of max data streams Rubrik will use to back up the database
    #NOTE: Default of -1 is used to get around ints defaulting as 0
    [int]$MaxDataStreams = -1,
    #SLA Domain ID for the database
    [Alias('ConfiguredSlaDomainId')]
    [string]$SLAID,
    # The SLA Domain name in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
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
    
    #If the following params are -1, remove from body (invalid values)
    $intparams = @('LogBackupFrequencyInSeconds','LogRetentionHours','MaxDataStreams')
    foreach($p in $intparams){
      if((Get-Variable -Name $p).Value -eq -1){$resources.Body.Remove($p)}
    }

    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    

    #Pre Backup script
    #region Enable Pre Backup Script
    if($PreScriptPath)
    {
      $bodytemp = ConvertFrom-Json $body
      $pre = New-Object psobject -Property @{'scriptPath'=$PreScriptPath;'timeoutMs'=$PreTimeoutMs;'scriptErrorAction'=$PreScriptErrorAction}
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'preBackupScript' -Value $pre
      $body = ConvertTo-Json $bodytemp
    }
    #endregion
    #region Disable Pre Backup Script
    if($DisablePreBackupScript -eq $true -and ([string]::IsNullOrEmpty($PreScriptPath)))
    {
      $bodytemp = ConvertFrom-Json $body
      $pre = New-Object psobject -Property @{'scriptPath'=$null;'timeoutMs'=$Null;'scriptErrorAction'=$Null}
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'preBackupScript' -Value $pre
      $body = ConvertTo-Json $bodytemp
    } 
    elseif(($DisablePreBackupScript) -and -not ([string]::IsNullOrEmpty($PreScriptPath)))
    {
      $msg = "Can not declare -PreScriptPath and -DisablePreBackupScript in the same request."
      Write-Warning $msg
      return $msg
    }
    #endregion

    #Post Backup script
    #region Enable Post Backup Script
    if($PostScriptPath)
    {
      $bodytemp = ConvertFrom-Json $body
      $Post = New-Object psobject -Property @{'scriptPath'=$PostScriptPath;'timeoutMs'=$PostTimeoutMs;'scriptErrorAction'=$PostScriptErrorAction}
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'postBackupScript' -Value $Post
      $body = ConvertTo-Json $bodytemp
    }
    #endregion
    #region Disable Post Backup Script
    
    if($DisablePostBackupScript -eq $true -and ([string]::IsNullOrEmpty($PostScriptPath)))
    {
      $bodytemp = ConvertFrom-Json $body
      $Post = New-Object psobject -Property @{'scriptPath'=$null;'timeoutMs'=$Null;'scriptErrorAction'=$Null}
      $bodytemp | Add-Member -MemberType NoteProperty -Name 'postBackupScript' -Value $Post
      $body = ConvertTo-Json $bodytemp
    } 
    elseif(($DisablePostBackupScript) -and -not ([string]::IsNullOrEmpty($PostScriptPath)))
    {
      $msg = "Can not declare -PostScriptPath and -DisablePostBackupScript in the same request."
      Write-Warning $msg
      return $msg
    }
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#requires -Version 3
function Set-RubrikHyperVVM
{
    <#  
            .SYNOPSIS
            Applies settings on one or more virtual machines known to a Rubrik cluster

            .DESCRIPTION
            The Set-RubrikHyperVVM cmdlet is used to apply updated settings from a Rubrik cluster on any number of virtual machines

            .NOTES
            Written by Mike Fal for community usage
            Twitter: @Mike_Fal
            GitHub: MikeFal

            .LINK
            http://rubrikinc.github.io/rubrik-sdk-for-powershell/

            .EXAMPLE
            Get-RubrikHyperVVM 'Server1' | Set-RubrikHyperVVM -PauseBackups
            This will pause backups on any virtual machine named "Server1"

            .EXAMPLE
            Get-RubrikHyperVVM -SLA Platinum | Set-RubrikHyperVVM -SnapConsistency 'CRASH_CONSISTENT' -MaxNestedSnapshots 2 -UseArrayIntegration 
            This will find all virtual machines in the Platinum SLA Domain and set their snapshot consistency to crash consistent (no application quiescence)
            while also limiting the number of active hypervisor snapshots to 2 and enable storage array (SAN) snapshots for ingest
    #>

    [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
    Param(
        # Virtual machine ID
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$id,
        #Raw Cloud Instantiation spec
        [hashtable]$cloudInstantiationSpec,
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
#requires -Version 3
function Set-RubrikLogShipping
{
  <#  
      .SYNOPSIS
      Update a specified log shipping configuration

      .DESCRIPTION
      Update a specified log shipping configuratio

      .NOTES
      Written by Chris Lumnah
      Twitter: lumnah
      GitHub: clumnah
      

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
       Get-RubrikLogShipping -PrimaryDatabaseName 'AthenaAM1-SQL16-1-2016' -SecondaryDatabaseName 'AthenaAM1-SQL16-1-2016' | Set-RubrikLogShipping -state STANDBY -DisconnectStandbyUsers
  #>

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    
    [ValidateSet("RESTORING", "STANDBY",IgnoreCase=$false)]
    [String]$state,

    [Alias('shouldDisconnectStandbyUsers')]
    [switch]$DisconnectStandbyUsers,  

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

#requires -Version 3
function Set-RubrikMount
{
  <#  
      .SYNOPSIS
      Powers on/off a live mounted virtual machine within a connected Rubrik vCenter.

      .DESCRIPTION
      The Set-RubrikMount cmdlet is used to send a power on request to mounted virtual machine visible to a Rubrik cluster.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikMount.html

      .EXAMPLE
      Get-RubrikMount -id '11111111-2222-3333-4444-555555555555' | Set-RubrikMount -PowerOn:$true
      This will send a power on request to "Server1"

      .EXAMPLE
      Get-RubrikMount -VMID (Get-RubrikVM -VM 'Server1').id | Set-RubrikMount -PowerOn:$false
      This will send a power off request to "Server1"
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Mount id
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Configuration for the change power status request
    [Alias('powerStatus')]
    [Bool]$PowerOn,
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
#requires -Version 3
function Set-RubrikNASShare
{
  <#  
      .SYNOPSIS
      Change settings for a NAS share

      .DESCRIPTION
      Update NAS share settings that are configured in Rubrik, such as updating the export point or
      change the NAS credentials

      .NOTES
      Written by Mike Fal
      Twitter: @Mike_Fal
      GitHub: MikeFal
      Any other links you'd like here

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Get-RubrikNASShare -name 'FOO' | Set-RubrikNASShare -ExportPoint 'TEMP' 

      Update the NAS Share FOO with the export point of TEMP.
  #>

  [CmdletBinding()]
  Param(
    # NAS Share ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]    
    [String]$Id,
    # New export point for the share
    [String]$ExportPoint,
    # New NAS Share credential
    [pscredential]$Credential,    
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

    #region one-off
    #Convert credential to valid body values
    $bodytemp = ConvertFrom-Json $body
    $bodytemp.Add('username',$Credential.GetNetworkCredential().UserName)
    $bodytemp.Add('password',$Credential.GetNetworkCredential().Password)
    $bodytemp.Add('domain',$Credential.GetNetworkCredential().Domain)
    $body = ConvertTo-Json $bodytemp
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#requires -Version 3
function Set-RubrikNutanixVM
{
    <#  
            .SYNOPSIS
            Applies settings on one or more virtual machines known to a Rubrik cluster

            .DESCRIPTION
            The Set-RubrikNutanixVM cmdlet is used to apply updated settings from a Rubrik cluster on any number of virtual machines

            .NOTES
            Written by Mike Fal for community usage
            Twitter: @Mike_Fal
            GitHub: MikeFal

            .LINK
            http://rubrikinc.github.io/rubrik-sdk-for-powershell/

            .EXAMPLE
            Get-RubrikNutanixVM 'Server1' | Set-RubrikNutanixVM -PauseBackups
            This will pause backups on any virtual machine named "Server1"

            .EXAMPLE
            Get-RubrikNutanixVM -SLA Platinum | Set-RubrikNutanixVM -SnapConsistency 'CRASH_CONSISTENT' -MaxNestedSnapshots 2 -UseArrayIntegration 
            This will find all virtual machines in the Platinum SLA Domain and set their snapshot consistency to crash consistent (no application quiescence)
            while also limiting the number of active hypervisor snapshots to 2 and enable storage array (SAN) snapshots for ingest
    #>

    [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
    Param(
        # Virtual machine ID
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$id,
        # Consistency level mandated for this VM
        [ValidateSet('AUTOMATIC','APP_CONSISTENT','CRASH_CONSISTENT','FILE_SYSTEM_CONSISTENT','VSS_CONSISTENT','INCONSISTENT','UNKNOWN')]
        [Alias('snapshotConsistencyMandate')]
        [String]$SnapConsistency,
        # Whether to pause or resume backups/archival for this VM.
        [Alias('isPaused')]
        [Bool]$PauseBackups,
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

        #region one-off
        if ($SnapConsistency)
        {
            $SnapConsistency = $SnapConsistency -replace 'AUTOMATIC', 'UNKNOWN'
        }
        #endregion    
  
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
#Requires -Version 3
function Set-RubrikSetting
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and sets Rubrik cluster settings
            
      .DESCRIPTION
      The Set-RubrikSetting cmdlet will set the cluster settings on the system. This does require authentication.
            
      .NOTES
      Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage
            
      .LINK
      https://github.com/rubrikinc/PowerShell-Module
            
      .EXAMPLE
      Set-RubrikSetting -ClusterName "test-rubrik-cluster" -Timezone "America/Los Angeles" -ClusterLocation "LA Office"
      This will set the designated cluster settings on the Rubrik cluster
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # New name for a Rubrik cluster
    [Parameter(Mandatory=$True)]
    [Alias('name')]
    [string]$ClusterName,
    # New time zone for a Rubrik cluster 
    [Parameter(Mandatory=$True)]
    [ValidateSet("Africa/Johannesburg","Africa/Lagos","Africa/Nairobi","America/Anchorage","America/Araguaina","America/Barbados","America/Chicago","America/Denver","America/Los_Angeles","America/Mexico_City","America/New_York","America/Noronha","America/Phoenix","America/Toronto","America/Vancouver","Asia/Bangkok","Asia/Dhaka","Asia/Hong_Kong","Asia/Karachi","Asia/Kathmandu","Asia/Kolkata","Asia/Magadan","Asia/Singapore","Asia/Tokyo","Atlantic/Cape_Verde","Australia/Perth","Australia/Sydney","Europe/Amsterdam","Europe/Athens","Europe/London","Europe/Moscow","Pacific/Auckland","Pacific/Honolulu","Pacific/Midway","UTC")]
    [string]$Timezone,
    # Address information for mapping the location of the Rubrik cluster. This value is used to provide a location for the Rubrik cluster on the dashboard map
    [Parameter(Mandatory=$True)]
    [string]$ClusterLocation,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # ID of the Rubrik cluster or me for self
    [String]$id = 'me',
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
    Write-Verbose -Message "Build the body"
    [PSCustomObject]$tz = @{timezone = $timezone}
    [PSCustomObject]$add = @{address = $clusterLocation}

    Write-Verbose "TimeZone = $tz"
    Write-Verbose "Address = $add"

    $body = @{
        $resources.Body.timezone = $tz
        $resources.Body.geolocation = $add
        $resources.Body.name = $clusterName
    }
        
    $body = ConvertTo-Json $body
    Write-Verbose -Message "Body = $body"
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    #$body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Set-RubrikSLA
{
  <#  
      .SYNOPSIS
      Updates an existing Rubrik SLA Domain

      .DESCRIPTION
      The Set-RubrikSLA cmdlet will update an existing SLA Domain with specified parameters.

      .NOTES
      Written by Pierre-François Guglielmi for community usage
      Twitter: @pfguglielmi
      GitHub: pfguglielmi

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikSLA.html

      .EXAMPLE
      Set-RubrikSLA -id e4d121af-5611-496a-bb8d-57ba46443e94 -Name Gold -HourlyFrequency 12 -HourlyRetention 5
      This will update the SLA Domain named "Gold" to take a snapshot every 12 hours and keep those for 5 days.
      All other existing parameters will be reset.
      
      .EXAMPLE
      Get-RubrikSLA -Name Gold | Set-RubrikSLA -HourlyFrequency 4 -HourlyRetention 3
      This will update the SLA Domain named "Gold" to take a snapshot every 4 hours and keep those hourly snapshots for 3 days,
      while keeping all other existing parameters.

      .EXAMPLE
      Get-RubrikSLA -Name Gold | Set RubrikSLA -AdvancedConfig -HourlyFrequency 4 -HourlyRetention 3 -WeeklyFrequency 1 -WeeklyRetention 4 -DayOfWeek Friday
      This will update the SLA Domain named "Gold" to take a snapshot every 4 hours and keep those hourly snapshots for 3 days
      while also keeping one snapshot per week for 4 weeks, created on Fridays. All other existing parameters will remain as they were.

      .EXAMPLE
      Get-RubrikSLA -Name Gold | Set-RubrikSLA -BackupStartHour 22 -BackupStartMinute 00 -BackupWindowDuration 8
      This will update the SLA Domain named "Gold" to take snapshots between 22:00PM and 6:00AM, while keeping all other existing parameters.

      .EXAMPLE
      Get-RubrikSLA -Name Gold | Set-RubrikSLA -FirstFullBackupStartHour 21 -FirstFullBackupStartMinute 30 -FirstFullBackupWindowDuration 57 -FirstFullBackupDay Friday
      This will update the SLA Domain named "Gold" to take the first full snapshot between Friday 21:30PM and Monday 6:30AM, while keeping all other existing parameters.

      .EXAMPLE
      Get-RubrikSLA -Name Gold | Set-RubrikSLA -Archival -ArchivalLocationId 64e27685-f1d9-4243-a2d4-78dbf5e8b43d -LocalRetention 30
      This will update the SLA Domain named "Gold" to keep data locally for 30 days before sending it to the specified archival location.

      .EXAMPLE
      Get-RubrikSLA -Name Gold | Set-RubrikSLA -InstantArchive
      This will update the SLA Domain named "Gold" to enable Instant Archive, assuming that archival was already configured. Ommitting this parameter will disable Instant Archive.

      .EXAMPLE
      Get-RubrikSLA -Name Gold | Set-RubrikSLA -Replication -ReplicationTargetId eeece05e-980f-4d32-953e-d236b65ff6fd -RemoteRetention 7
      This will update the SLA Domain named "Gold" to replicate snapshots to the specified cluster and keep them for 7 days remotely.

      .EXAMPLE
      Get-RubrikSLA -Name Gold | Set-RubrikSLA -AdvancedConfig
      This will update the SLA Domain named "Gold" to only enable Advanced Configuration

      .EXAMPLE
      Get-RubrikSLA -Name Gold | Set-RubrikSLA -Archival:$false
      This will update the SLA Domain named "Gold" to only disable archival

      .EXAMPLE
      Get-RubrikSLA -Name Gold | Set-RubrikSLA -Replication:$false
      This will update the SLA Domain named "Gold" to only disable replication
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # SLA id value from the Rubrik Cluster
    [Parameter(
      ValueFromPipelineByPropertyName = $true,
      Mandatory = $true )]
    [ValidateNotNullOrEmpty()]
    [String]$id,
    # SLA Domain Name
    [Parameter(
      ValueFromPipelineByPropertyName = $true)]
    [Alias('SLA')]
    [ValidateNotNullOrEmpty()]
    [String]$Name,
    # Hourly frequency to take snapshots
    [int]$HourlyFrequency,
    # Number of days or weeks to retain the hourly snapshots. For CDM versions prior to 5.0 this value must be set in days
    [int]$HourlyRetention,
    # Retention type to apply to hourly snapshots when advanced configuration is enabled. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Daily','Weekly')]
    [String]$HourlyRetentionType='Daily',
    # Daily frequency to take snapshots
    [int]$DailyFrequency,
    # Number of days or weeks to retain the daily snapshots. For CDM versions prior to 5.0 this value must be set in days
    [int]$DailyRetention,
    # Retention type to apply to daily snapshots when advanced configuration is enabled. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Daily','Weekly')]
    [String]$DailyRetentionType='Daily',
    # Weekly frequency to take snapshots
    [int]$WeeklyFrequency,
    # Number of weeks to retain the weekly snapshots
    [int]$WeeklyRetention,
    # Day of week for the weekly snapshots when advanced configuration is enabled. The default is Saturday. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')]
    [String]$DayOfWeek='Saturday',
    # Monthly frequency to take snapshots
    [int]$MonthlyFrequency,
    # Number of months, quarters or years to retain the monthly backups. For CDM versions prior to 5.0, this value must be set in years
    [int]$MonthlyRetention,
    # Day of month for the monthly snapshots when advanced configuration is enabled. The default is the last day of the month. Does not apply to CDM versions prior to 5.0
    [ValidateSet('FirstDay','Fifteenth','LastDay')]
    [String]$DayOfMonth='LastDay',
    # Retention type to apply to monthly snapshots. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Monthly','Quarterly','Yearly')]
    [String]$MonthlyRetentionType='Monthly',
    # Quarterly frequency to take snapshots. Does not apply to CDM versions prior to 5.0
    [int]$QuarterlyFrequency,
    # Number of quarters or years to retain the monthly snapshots. Does not apply to CDM versions prior to 5.0
    [int]$QuarterlyRetention,
    # Day of quarter for the quarterly snapshots when advanced configuration is enabled. The default is the last day of the quarter. Does not apply to CDM versions prior to 5.0
    [ValidateSet('FirstDay','LastDay')]
    [String]$DayOfQuarter='LastDay',
    # Month that starts the first quarter of the year for the quarterly snapshots when advanced configuration is enabled. The default is January. Does not apply to CDM versions prior to 5.0
    [ValidateSet('January','February','March','April','May','June','July','August','September','October','November','December')]
    [String]$FirstQuarterStartMonth='January',
    # Retention type to apply to quarterly snapshots. The default is Quarterly. Does not apply to CDM versions prior to 5.0
    [ValidateSet('Quarterly','Yearly')]
    [String]$QuarterlyRetentionType='Quarterly',
    # Yearly frequency to take snapshots
    [int]$YearlyFrequency,
    # Number of years to retain the yearly snapshots
    [int]$YearlyRetention,
    # Day of year for the yearly snapshots when advanced configuration is enabled. The default is the last day of the year. Does not apply to CDM versions prior to 5.0
    [ValidateSet('FirstDay','LastDay')]
    [String]$DayOfYear='LastDay',
    # Month that starts the first quarter of the year for the quarterly snapshots when advanced configuration is enabled. The default is January. Does not apply to CDM versions prior to 5.0
    [ValidateSet('January','February','March','April','May','June','July','August','September','October','November','December')]
    [String]$YearStartMonth='January',
    # Whether to turn advanced SLA configuration on or off. Does not apply to CDM versions prior to 5.0
    [Parameter(
      ValueFromPipelineByPropertyName = $true)]
    [alias('showAdvancedUi')]
    [switch]$AdvancedConfig,
    # Hour from which backups are allowed to run. Uses the 24-hour clock
    [ValidateRange(0,23)]
    [int]$BackupStartHour,
    # Minute of hour from which backups are allowed to run
    [ValidateRange(0,59)]
    [int]$BackupStartMinute,
    # Number of hours during which backups are allowed to run
    [ValidateRange(1,23)]
    [int]$BackupWindowDuration,
    # Hour from which the first full backup is allowed to run. Uses the 24-hour clock
    [ValidateRange(0,23)]
    [int]$FirstFullBackupStartHour,
    # Minute of hour from which the first full backup is allowed to run
    [ValidateRange(0,59)]
    [int]$FirstFullBackupStartMinute,
    [ValidateSet('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','1','2','3','4','5','6','7')]
    [String]$FirstFullBackupDay,
    # Number of hours during which the first full backup is allowed to run
    [int]$FirstFullBackupWindowDuration,
    # Whether to enable archival
    [switch]$Archival,
    # Time in days to keep backup data locally on the cluster.
    [Parameter(
      ValueFromPipelineByPropertyName = $true)]
    [alias('localRetentionLimit')]
    [int]$LocalRetention,
    # ID of the archival location
    [ValidateNotNullOrEmpty()]
    [String]$ArchivalLocationId,
    # Polaris Managed ID
    [ValidateNotNullOrEmpty()]
    [String]$PolarisID,
    # Whether to enable Instant Archive
    [switch]$InstantArchive,
    # Whether to enable replication
    [switch]$Replication,
    # ID of the replication target
    [ValidateNotNullOrEmpty()]
    [String]$ReplicationTargetId,
    # Time in days to keep data on the replication target.
    [int]$RemoteRetention,
    # Retrieves frequencies from Get-RubrikSLA via the pipeline
    [Parameter(
      ValueFromPipelineByPropertyName = $true)]
    [object[]] $Frequencies,
    # Retrieves the advanced UI configuration parameters from Get-RubrikSLA via the pipeline
    [Parameter(
      ValueFromPipelineByPropertyName = $true)]
    [alias('advancedUiConfig')]
    [object[]] $AdvancedFreq,    
    # Retrieves the allowed backup windows from Get-RubrikSLA via the pipeline
    [Parameter(
      ValueFromPipelineByPropertyName = $true)]
    [alias('allowedBackupWindows')]
    [object[]] $BackupWindows,
    # Retrieves the allowed backup windows for the first full backup from Get-RubrikSLA via the pipeline
    [Parameter(
      ValueFromPipelineByPropertyName = $true)]
    [alias('firstFullAllowedBackupWindows')]
    [object[]] $FirstFullBackupWindows,
    # Retrieves the archical specifications from Get-RubrikSLA via the pipeline
    [Parameter(
      ValueFromPipelineByPropertyName = $true)]
    [object[]] $ArchivalSpecs,
    # Retrieves the replication specifications from Get-RubrikSLA via the pipeline
    [Parameter(
      ValueFromPipelineByPropertyName = $true)]
    [object[]] $ReplicationSpecs,
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

    #region One-off
    Write-Verbose -Message 'Build the body'
    # Build the body for CDM versions 5 and above when the advanced SLA configuration is turned on
    if (($uri.contains('v2')) -and ($AdvancedConfig -eq $true)) {
      $body = @{
        $resources.Body.name = $Name
        allowedBackupWindows = @()
        firstFullAllowedBackupWindows = @()
        archivalSpecs = @()
        replicationSpecs = @()
        showAdvancedUi = $true
        advancedUiConfig = @()
     }
    # Build the body for CDM versions 5 and above when the advanced SLA configuration is turned off
    } elseif ($uri.contains('v2')) {
      $body = @{
        $resources.Body.name = $Name
        allowedBackupWindows = @()
        firstFullAllowedBackupWindows = @()
        archivalSpecs = @()
        replicationSpecs = @()
        showAdvancedUi = $false
      }
    # Build the body for CDM versions prior to 5.0
    } else {
      $body = @{
        $resources.Body.name = $Name
        frequencies = @()
        allowedBackupWindows = @()
        firstFullAllowedBackupWindows =@()
        archivalSpecs = @()
        replicationSpecs = @()
      }
    }

    Write-Verbose -Message 'Setting ParamValidation flag to $false to check if user set any params'
    [bool]$ParamValidation = $false

    # Retrieve snapshot frequencies from pipeline for CDM versions 5 and above when advanced SLA configuration is turned on
    if (($uri.contains('v2')) -and ($Frequencies) -and ($AdvancedConfig -eq $true)) {
      $Frequencies[0].psobject.properties.name | ForEach-Object {
        if ($_ -eq 'Hourly') {
          if (($Frequencies.$_.frequency) -and (-not $HourlyFrequency)) {
            $HourlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $HourlyRetention)) {
            # Convert hourly retention in days when the value retrieved from pipeline is in hours because advanced SLA configuration was previously turned off
            if ($AdvancedFreq.Count -eq 0) {
              $HourlyRetention = ($Frequencies.$_.retention) / 24
            } else {
              $HourlyRetention = $Frequencies.$_.retention
            }
          }
        } elseif ($_ -eq 'Daily') {
          if (($Frequencies.$_.frequency) -and (-not $DailyFrequency)) {
            $DailyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $DailyRetention)) {
            $DailyRetention = $Frequencies.$_.retention
          }
        } elseif ($_ -eq 'Weekly') {
          if (($Frequencies.$_.frequency) -and (-not $WeeklyFrequency)) {
            $WeeklyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $WeeklyRetention)) {
            $WeeklyRetention = $Frequencies.$_.retention
          }
          if (($Frequencies.$_.dayOfWeek) -and (-not $PSBoundParameters.ContainsKey('dayOfWeek'))) {
            $DayOfWeek = $Frequencies.$_.dayOfWeek
          }
        } elseif ($_ -eq 'Monthly') {
          if (($Frequencies.$_.frequency) -and (-not $MonthlyFrequency)) {
            $MonthlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $MonthlyRetention)) {
            $MonthlyRetention = $Frequencies.$_.retention
          }
          if (($Frequencies.$_.dayOfMonth) -and (-not $PSBoundParameters.ContainsKey('dayOfMonth'))) {
            $DayofMonth = $Frequencies.$_.dayOfMonth
          }
        } elseif ($_ -eq 'Quarterly') {
          if (($Frequencies.$_.frequency) -and (-not $QuarterlyFrequency)) {
            $QuarterlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $QuarterlyRetention)) {
            $QuarterlyRetention = $Frequencies.$_.retention
          }
          if (($Frequencies.$_.firstQuarterStartMonth) -and (-not $PSBoundParameters.ContainsKey('firstQuarterStartMonth'))) {
            $FirstQuarterStartMonth = $Frequencies.$_.firstQuarterStartMonth
          }
          if (($Frequencies.$_.dayOfQuarter) -and (-not $PSBoundParameters.ContainsKey('dayOfQuarter'))) {
            $DayOfQuarter = $Frequencies.$_.dayOfQuarter
          }
        } elseif ($_ -eq 'Yearly') {
          if (($Frequencies.$_.frequency) -and (-not $YearlyFrequency)) {
            $YearlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $YearlyRetention)) {
            $YearlyRetention = $Frequencies.$_.retention
          }
          if (($Frequencies.$_.yearStartMonth) -and (-not $PSBoundParameters.ContainsKey('yearStartMonth'))) {
            $YearStartMonth = $Frequencies.$_.yearStartMonth
          }
          if (($Frequencies.$_.dayOfYear) -and (-not $PSBoundParameters.ContainsKey('dayOfYear'))) {
            $DayOfYear = $Frequencies.$_.dayOfYear
          }
        }
      }
    # Retrieve snapshot frequencies from pipeline for CDM versions 5 and above when advanced SLA configuration is turned off
    } elseif ($uri.contains('v2') -and ($Frequencies)) {
      $Frequencies[0].psobject.properties.name | ForEach-Object {
        if ($_ -eq 'Hourly') {
          if (($Frequencies.$_.frequency) -and (-not $HourlyFrequency)) {
            $HourlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $HourlyRetention)) {
            # Convert hourly retention in hours when the value retrieved from pipeline is in days because advanced SLA configuration was previously turned on
            if ($AdvancedFreq.Count -eq 0) {
              $HourlyRetention = $Frequencies.$_.retention
            } else {
              $HourlyRetention = ($Frequencies.$_.retention) * 24
            }
          # Convert hourly retention in hours when the value set explicitly with the parameter is in days, like in the UI
          } elseif ($HourlyRetention) {
            $HourlyRetention = ($HourlyRetention * 24)
          }
        } elseif ($_ -eq 'Daily') {
          if (($Frequencies.$_.frequency) -and (-not $DailyFrequency)) {
            $DailyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $DailyRetention)) {
            $DailyRetention = $Frequencies.$_.retention
          }
        } elseif ($_ -eq 'Monthly') {
          if (($Frequencies.$_.frequency) -and (-not $MonthlyFrequency)) {
            $MonthlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $MonthlyRetention)) {
            $MonthlyRetention = $Frequencies.$_.retention
          }
          if (($Frequencies.$_.dayOfMonth) -and (-not $PSBoundParameters.ContainsKey('dayOfMonth'))) {
            $DayofMonth = $Frequencies.$_.dayOfMonth
          }
        } elseif ($_ -eq 'Yearly') {
          if (($Frequencies.$_.frequency) -and (-not $YearlyFrequency)) {
            $YearlyFrequency = $Frequencies.$_.frequency
          }
          if (($Frequencies.$_.retention) -and (-not $YearlyRetention)) {
            $YearlyRetention = $Frequencies.$_.retention
          }
          if (($Frequencies.$_.yearStartMonth) -and (-not $PSBoundParameters.ContainsKey('yearStartMonth'))) {
            $YearStartMonth = $Frequencies.$_.yearStartMonth
          }
          if (($Frequencies.$_.dayOfYear) -and (-not $PSBoundParameters.ContainsKey('dayOfYear'))) {
            $DayOfYear = $Frequencies.$_.dayOfYear
          }
        }
      }
    # Retrieve snapshot frequencies from pipeline for CDM versions prior to 5.0
    } elseif ($Frequencies) {
      $Frequencies | ForEach-Object {
        if ($_.timeUnit -eq 'Hourly') {
          if (($_.frequency) -and (-not $HourlyFrequency)) {
            $HourlyFrequency = $_.frequency
          }
          if (($_.retention) -and (-not $HourlyRetention)) {
            $HourlyRetention = $_.retention
          # Convert hourly retention in hours when the parameter is explicitly specified because the default unit is days, like in the UI
          } elseif ($HourlyRetention) {
            $HourlyRetention = $HourlyRetention * 24
          }
        } elseif ($_.timeUnit -eq 'Daily') {
          if (($_.frequency) -and (-not $DailyFrequency)) {
            $DailyFrequency = $_.frequency
          }
          if (($_.retention) -and (-not $DailyRetention)) {
            $DailyRetention = $_.retention
          }
        } elseif ($_.timeUnit -eq 'Monthly') {
          if (($_.frequency) -and (-not $MonthlyFrequency)) {
            $MonthlyFrequency = $_.frequency
          }
          if (($_.retention) -and (-not $MonthlyRetention)) {
            $MonthlyRetention = $_.retention
          # Convert monthly retention in months when the parameter is explicitly specified because the default unit is in years, like in the UI
          } elseif ($MonthlyRetention) {
            $MonthlyRetention = $MonthlyRetention * 12
          }
        } elseif ($_.timeUnit -eq 'Yearly') {
          if (($_.frequency) -and (-not $YearlyFrequency)) {
            $YearlyFrequency = $_.frequency
          }
          if (($_.retention) -and (-not $YearlyRetention)) {
            $YearlyRetention = $_.retention
          }
        }
      }
      # Ensure the hourly retention set via the cli parameter is converted to hours if frequencies were retrieved from the pipeline but hourly retention was empty
      if (($Frequencies.timeUnit -notcontains 'Hourly') -and $HourlyRetention) {
        $HourlyRetention = $HourlyRetention * 24
      }
      # Ensure the monthly retention set via the cli parameter is converted to months if frequencies were retrieved from the pipeline but monthly retention was empty
      if (($Frequencies.timeUnit -notcontains 'Monthly') -and $MonthlyRetention) {
        $MonthlyRetention = $MonthlyRetention * 12
      }
    } elseif ($HourlyRetention -or $MonthlyRetention) {
      # Ensure the hourly retention set via the cli parameter is converted to hours for CDM versions prior to 5.0, and 5.x when advanced SLA configuration is disabled
      if ($HourlyRetention -and $PSBoundParameters.ContainsKey('AdvancedConfig') -and ($AdvancedConfig -eq $false)) {
        $HourlyRetention = $HourlyRetention * 24
        }
      # Ensure the monthly retention set via the cli parameter is converted to months for CDM versions prior to 5.0
      if ($MonthlyRetention -and (-not ($uri.contains('v2')))) {
        $MonthlyRetention = $MonthlyRetention * 12
      }
    }

    # Retrieve advanced retention unit parameters from pipeline for CDM 5.0
    if ($AdvancedFreq) {
      $AdvancedFreq | ForEach-Object {
        if (($_.timeUnit -eq 'Hourly') -and ($_.retentionType) -and (-not $PSBoundParameters.ContainsKey('HourlyRetentionType'))) {
          $HourlyRetentionType = $_.retentionType
        } elseif (($_.timeUnit -eq 'Daily') -and ($_.retentionType) -and (-not $PSBoundParameters.ContainsKey('DailyRetentionType'))) {
          $DailyRetentionType = $_.retentionType
        } elseif (($_.timeUnit -eq 'Monthly') -and ($_.retentionType) -and (-not $PSBoundParameters.ContainsKey('MonthlyRetentionType'))) {
          $MonthlyRetentionType = $_.retentionType
        } elseif (($_.timeUnit -eq 'Quarterly') -and ($_.retentionType) -and (-not $PSBoundParameters.ContainsKey('QuarterlyRetentionType'))) {
          $QuarterlyRetentionType = $_.retentionType
        }
      }
    }
    
    # Retrieve the allowed backup window settings from pipeline
    if ($BackupWindows) {
      if (($BackupWindows.startTimeAttributes.hour -ge 0) -and (-not $PSBoundParameters.ContainsKey('BackupStartHour'))) {
        $BackupStartHour = $BackupWindows.startTimeAttributes.hour
      }
      if (($BackupWindows.startTimeAttributes.minutes -ge 0) -and (-not $PSBoundParameters.ContainsKey('BackupStartMinute'))) {
        $BackupStartMinute = $BackupWindows.startTimeAttributes.minutes
      }
      if (($BackupWindows.durationInHours) -and (-not $BackupWindowDuration)) {
        $BackupWindowDuration = $BackupWindows.durationInHours
      }
    }

    # Retrieve the allowed backup window settings for the first full from pipeline
    if ($FirstFullBackupWindows) {
      if (($FirstFullBackupWindows.startTimeAttributes.hour -ge 0) -and (-not $PSBoundParameters.ContainsKey('FirstFullBackupStartHour'))) {
        $FirstFullBackupStartHour = $FirstFullBackupWindows.startTimeAttributes.hour
      }
      if (($FirstFullBackupWindows.startTimeAttributes.minutes -ge 0) -and (-not $PSBoundParameters.ContainsKey('FirstFullBackupStartMinute'))) {
        $FirstFullBackupStartMinute = $FirstFullBackupWindows.startTimeAttributes.minutes
      }
      if (($FirstFullBackupWindows.startTimeAttributes.dayOfWeek) -and (-not $PSBoundParameters.ContainsKey('FirstFullBackupDay'))) {
        [int]$FirstFullBackupDay = $FirstFullBackupWindows.startTimeAttributes.dayOfWeek
      }
      if (($FirstFullBackupWindows.durationInHours) -and (-not $FirstFullBackupWindowDuration)) {
        $FirstFullBackupWindowDuration = $FirstFullBackupWindows.durationInHours
      }
    }

    # Retrieve the archival specifications from pipeline
    if ($ArchivalSpecs) {
      if ($ArchivalSpecs.locationId -and (-not $ArchivalLocationId)) {
        $ArchivalLocationId = $ArchivalSpecs.locationId
      }
      if ($ArchivalSpecs.polarisManagedId -and (-not $PolarisID)) {
        $PolarisID = $ArchivalSpecs.polarisManagedId
      }
      if (-not ($PSBoundParameters.ContainsKey('Archival'))) {
        $Archival = $true
      }
    }
    # If LocalRetention is set directly, convert its value in seconds
    if ($LocalRetention -lt 86400) {
      $LocalRetention = $LocalRetention * 86400
    }

    # Retrieve the replication specifications from pipeline
    if ($ReplicationSpecs) {
      if ($ReplicationSpecs.locationId -and (-not $ReplicationTargetId)) {
        $ReplicationTargetId = $ReplicationSpecs.locationId
      }
      if ($ReplicationSpecs.retentionLimit -and (-not $RemoteRetention)) {
        $RemoteRetention = $ReplicationSpecs.retentionLimit
      }
      if (-not ($PSBoundParameters.ContainsKey('Replication'))) {
        $Replication = $true
      }
    }
    # If RemoteRetention is set directly, convert its value in seconds
    if ($RemoteRetention -lt 86400) {
      $RemoteRetention = $RemoteRetention * 86400
    }

    # Populate the body with the allowed backup window settings
    if (($BackupStartHour -ge 0) -and ($BackupStartMinute -ge 0) -and $BackupWindowDuration) {
      $body.allowedBackupWindows += @{
          startTimeAttributes = @{hour=$BackupStartHour;minutes=$BackupStartMinute};
          durationInHours = $BackupWindowDuration
      }
    }

    # Populate the body with the allowed backup window settings fort the first full
    if (($FirstFullBackupStartHour -ge 0) -and ($FirstFullBackupStartMinute -ge 0) -and $FirstFullBackupDay -and $FirstFullBackupWindowDuration) {
      if ($FirstFullBackupDay -eq 'Sunday') {
        [int]$FirstFullBackupDay = 1
      } elseif ($FirstFullBackupDay -eq 'Monday') {
        [int]$FirstFullBackupDay = 2
      } elseif ($FirstFullBackupDay -eq 'Tuesday') {
        [int]$FirstFullBackupDay = 3
      } elseif ($FirstFullBackupDay -eq 'Wednesday') {
        [int]$FirstFullBackupDay = 4
      } elseif ($FirstFullBackupDay -eq 'Thursday') {
        [int]$FirstFullBackupDay = 5
      } elseif ($FirstFullBackupDay -eq 'Friday') {
        [int]$FirstFullBackupDay = 6
      } elseif ($FirstFullBackupDay -eq 'Saturday') {
        [int]$FirstFullBackupDay = 7
      }          
      $body.FirstFullAllowedBackupWindows += @{
          startTimeAttributes = @{hour=$FirstFullBackupStartHour;minutes=$FirstFullBackupStartMinute;dayOfWeek=$FirstFullBackupDay};
          durationInHours = $FirstFullBackupWindowDuration
      }
    }

    # Populate the body with archival specifications
    if ($uri.contains('v2') -and $Archival) {
      if ($ArchivalLocationId -and $PolarisID -and ($InstantArchive.IsPresent -eq $true)) {
        $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=1;polarisManagedId=$PolarisID}
        $body.localRetentionLimit = $LocalRetention
      } elseif ($ArchivalLocationId -and ($InstantArchive.IsPresent -eq $true)) {
        $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=1}
        $body.localRetentionLimit = $LocalRetention
      } elseif ($ArchivalLocationId -and $PolarisID -and ($InstantArchive.IsPresent -eq $false)) {
        $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=$LocalRetention;polarisManagedId=$PolarisID}
        $body.localRetentionLimit = $LocalRetention
      } elseif ($ArchivalLocationId -and ($InstantArchive.IsPresent -eq $false)) {
        $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=$LocalRetention}
        $body.localRetentionLimit = $LocalRetention
      }
    } elseif ($Archival) {
        if ($ArchivalLocationId -and ($InstantArchive.IsPresent -eq $true)) {
          $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=1}
          $body.localRetentionLimit = $LocalRetention
        } elseif ($ArchivalLocationId -and ($InstantArchive.IsPresent -eq $false)) {
          $body.archivalSpecs += @{locationId=$ArchivalLocationId;archivalThreshold=$LocalRetention}
          $body.localRetentionLimit = $LocalRetention
        }
    }

    # Populate the body with replication specifications
    if ($Replication -and $ReplicationTargetId -and $RemoteRetention) {
      $body.replicationSpecs += @{locationId=$ReplicationTargetId;retentionLimit=$RemoteRetention}
    }

    # Populate the body with frequencies according to the version of CDM and to whether the advanced SLA configuration is enabled in 5.x
    if ($HourlyFrequency -and $HourlyRetention) {
      if (($uri.contains('v2')) -and ($AdvancedConfig -eq $true)) {
        $body.frequencies += @{'hourly'=@{frequency=$HourlyFrequency;retention=$HourlyRetention}}
        $body.advancedUiConfig += @{timeUnit='Hourly';retentionType=$HourlyRetentionType}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'hourly'=@{frequency=$HourlyFrequency;retention=$HourlyRetention}}
      } else {
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Hourly'
          $resources.Body.frequencies.frequency = $HourlyFrequency
          $resources.Body.frequencies.retention = $HourlyRetention
        }
      }
      [bool]$ParamValidation = $true
    }
    
    if ($DailyFrequency -and $DailyRetention) {
      if (($uri.contains('v2')) -and ($AdvancedConfig -eq $true)) {
        $body.frequencies += @{'daily'=@{frequency=$DailyFrequency;retention=$DailyRetention}}
        $body.advancedUiConfig += @{timeUnit='Daily';retentionType=$DailyRetentionType}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'daily'=@{frequency=$DailyFrequency;retention=$DailyRetention}}
      } else { 
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Daily'
          $resources.Body.frequencies.frequency = $DailyFrequency
          $resources.Body.frequencies.retention = $DailyRetention
        }
      }
      [bool]$ParamValidation = $true
    }    

    if ($WeeklyFrequency -and $WeeklyRetention) { 
      if (($uri.contains('v2')) -and ($AdvancedConfig -eq $true)) {
        $body.frequencies += @{'weekly'=@{frequency=$WeeklyFrequency;retention=$WeeklyRetention;dayOfWeek=$DayOfWeek}}
        $body.advancedUiConfig += @{timeUnit='Weekly';retentionType='Weekly'}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'weekly'=@{frequency=$WeeklyFrequency;retention=$WeeklyRetention;dayOfWeek=$DayOfWeek}}
      } else {
        Write-Warning -Message 'Weekly SLA configurations are not supported in this version of Rubrik CDM.'
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Weekly'
          $resources.Body.frequencies.frequency = $WeeklyFrequency
          $resources.Body.frequencies.retention = $WeeklyRetention
        }
      }
      [bool]$ParamValidation = $true
    }    

    if ($MonthlyFrequency -and $MonthlyRetention) {
      if (($uri.contains('v2')) -and ($AdvancedConfig -eq $true)) {
        $body.frequencies += @{'monthly'=@{frequency=$MonthlyFrequency;retention=$MonthlyRetention;dayOfMonth=$DayOfMonth}}
        $body.advancedUiConfig += @{timeUnit='Monthly';retentionType=$MonthlyRetentionType}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'monthly'=@{frequency=$MonthlyFrequency;retention=$MonthlyRetention;dayOfMonth=$DayOfMonth}}
      } else { 
        $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Monthly'
          $resources.Body.frequencies.frequency = $MonthlyFrequency
          $resources.Body.frequencies.retention = $MonthlyRetention
        }
      }
      [bool]$ParamValidation = $true
    }  

    if ($QuarterlyFrequency -and $QuarterlyRetention) {
      if (($uri.contains('v2')) -and ($AdvancedConfig -eq $true)) {
        $body.frequencies += @{'quarterly'=@{frequency=$QuarterlyFrequency;retention=$QuarterlyRetention;firstQuarterStartMonth=$FirstQuarterStartMonth;dayOfQuarter=$DayOfQuarter}}
        $body.advancedUiConfig += @{timeUnit='Quarterly';retentionType=$QuarterlyRetentionType}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'quarterly'=@{frequency=$QuarterlyFrequency;retention=$QuarterlyRetention;firstQuarterStartMonth=$FirstQuarterStartMonth;dayOfQuarter=$DayOfQuarter}}
      } else { 
        Write-Warning -Message 'Quarterly SLA configurations are not supported in this version of Rubrik CDM.'
      }
      [bool]$ParamValidation = $true
    }  

    if ($YearlyFrequency -and $YearlyRetention) {
      if (($uri.contains('v2')) -and ($AdvancedConfig -eq $true)) {
        $body.frequencies += @{'yearly'=@{frequency=$YearlyFrequency;retention=$YearlyRetention;yearStartMonth=$YearStartMonth;dayOfYear=$DayOfYear}}
        $body.advancedUiConfig += @{timeUnit='Yearly';retentionType='Yearly'}
      } elseif ($uri.contains('v2')) {
        $body.frequencies += @{'yearly'=@{frequency=$YearlyFrequency;retention=$YearlyRetention;yearStartMonth=$YearStartMonth;dayOfYear=$DayOfYear}}
      } else {  
          $body.frequencies += @{
          $resources.Body.frequencies.timeUnit = 'Yearly'
          $resources.Body.frequencies.frequency = $YearlyFrequency
          $resources.Body.frequencies.retention = $YearlyRetention
        }
      }
      [bool]$ParamValidation = $true
    } 
    
    Write-Verbose -Message 'Checking for the $ParamValidation flag' 
    if ($ParamValidation -ne $true) 
    {
      throw 'You did not specify any frequency and retention values'
    }    
    
    $body = ConvertTo-Json $body -Depth 10
    
    # Remove bearer or basic auth info from verbose information
    Write-Verbose -Message "Header = $(
        (ConvertTo-Json -InputObject $header -Compress) -replace '(Bearer\s.*?")|(Basic\s.*?")'
      )"
    Write-Verbose -Message "Body = $body"
    #endregion

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#requires -Version 3
function Set-RubrikSQLInstance
{
  <#  
      .SYNOPSIS
      Sets SQL Instance properties

      .DESCRIPTION
      The Set-RubrikSQLInstance cmdlet is used to update certain settings for a Rubrik SQL instance.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Set-RubrikSQLInstance
  #>

  [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik's database id value
    [Parameter(
      Position = 0,
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()] 
    [String]$id,
    #Number of seconds between log backups if db s are in FULL or BULK_LOGGED
    #NOTE: Default of -1 is used to get around ints defaulting as 0
    [int]$LogBackupFrequencyInSeconds = -1,
    #Number of hours backups will be retained in Rubrik
    #NOTE: Default of -1 is used to get around ints defaulting as 0
    [int]$LogRetentionHours = -1,
    #Boolean declaration for copy only backups on the instance.
    [Switch]$CopyOnly,
    #SLA Domain ID for the database
    [Alias('ConfiguredSlaDomainId')]
    [string]$SLAID,
    # The SLA Domain name in Rubrik
    [Parameter(ParameterSetName = 'SLA_Explicit')]
    [String]$SLA,
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

    #region One-off
    if($SLA){
        $SLAID = Test-RubrikSLA $SLA
      }
      
    #If the following params are -1, remove from body (invalid values)
    $intparams = @('LogBackupFrequencyInSeconds','LogRetentionHours')
    foreach($p in $intparams){
      if((Get-Variable -Name $p).Value -eq -1){$resources.Body.Remove($p)}
    }     
    #endregion
  
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

#requires -Version 3
function Set-RubrikSupportTunnel
{
  <#  
      .SYNOPSIS
      Sets the configuration of the Support Tunnel

      .DESCRIPTION
      The Set-RubrikSupportTunnel cmdlet is used to update a Rubrik cluster's Support Tunnel configuration
      This tunnel is used by Rubrik's support team for providing remote assistance and is toggled on or off by the cluster administrator

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Set-RubrikSupportTunnel -EnableTunnel $false
      This will disable the Support Tunnel for the Rubrik cluster

      .EXAMPLE
      Set-RubrikSupportTunnel -EnableTunnel $true
      This will enable the Support Tunnel for the Rubrik cluster and set the inactivity timeout to infinite (no timeout)

      .EXAMPLE
      Set-RubrikSupportTunnel -EnableTunnel $true -Timeout 100
      This will enable the Support Tunnel for the Rubrik cluster and set the inactivity timeout to 100 seconds
  #>

  [CmdletBinding()]
  Param(
    # Status of the Support Tunnel. Choose $true to enable or $false to disable.
    [Parameter(Mandatory = $true)]
    [Alias('isTunnelEnabled')]
    [Bool]$EnableTunnel,
    # Tunnel inactivity timeout in seconds. Only valid when setting $EnableTunnel to $true.
    [Alias('inactivityTimeoutInSeconds')]
    [int]$Timeout,    
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
#Requires -Version 3
function Set-RubrikVCenter
{
    <#  
        .SYNOPSIS
        Connects to Rubrik and modifies an existing vCenter connection
            
        .DESCRIPTION
        The Set-RubrikVCenter cmdlet will modifies an existing vCenter connection on the system. This does require authentication.
            
        .NOTES
        Adapted by Adam Shuttleworth from scripts by Chris Wahl for community usage
            
        .LINK
        https://github.com/rubrikinc/PowerShell-Module
            
        .EXAMPLE
        Set-RubrikVCenter -hostname "test-vcenter.domain.com"
        This will return the running cluster settings on the Rubrik cluster.
    #>

    [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
    Param(
    # vCenter ID
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # vCenter Hostname (FQDN)
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [string]$Hostname,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
    )

    Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    $id = $Encode = [System.Web.HttpUtility]::UrlEncode($id)
    $Credentials=$(Get-Credential -Message "Type vCenter Credentials.")
    $username = $Credentials.UserName
    $password = $Credentials.GetNetworkCredential().Password

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
    Write-Verbose -Message "Build the body"

    $body = @{
        $resources.Body.hostname = $hostname
        $resources.Body.username = $username
        $resources.Body.password = $password
    }
        
    $body = ConvertTo-Json $body
    Write-Verbose -Message "Body = $body"
    #endregion
    
    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    #$uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    #$body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

    } # End of process
} # End of function
#requires -Version 3
function Set-RubrikVM
{
    <#  
            .SYNOPSIS
            Applies settings on one or more virtual machines known to a Rubrik cluster

            .DESCRIPTION
            The Set-RubrikVM cmdlet is used to apply updated settings from a Rubrik cluster on any number of virtual machines

            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl

            .LINK
            http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikVM.html

            .EXAMPLE
            Get-RubrikVM 'Server1' | Set-RubrikVM -PauseBackups
            This will pause backups on any virtual machine named "Server1"

            .EXAMPLE
            Get-RubrikVM -SLA Platinum | Set-RubrikVM -SnapConsistency 'CRASH_CONSISTENT' -MaxNestedSnapshots 2 -UseArrayIntegration 
            This will find all virtual machines in the Platinum SLA Domain and set their snapshot consistency to crash consistent (no application quiescence)
            while also limiting the number of active hypervisor snapshots to 2 and enable storage array (SAN) snapshots for ingest
    #>

    [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
    Param(
        # Virtual machine ID
        [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$id,
        # Consistency level mandated for this VM
        [ValidateSet('AUTOMATIC','APP_CONSISTENT','CRASH_CONSISTENT','FILE_SYSTEM_CONSISTENT','VSS_CONSISTENT','INCONSISTENT','UNKNOWN')]
        [Alias('snapshotConsistencyMandate')]
        [String]$SnapConsistency,
        #Raw Cloud Instantiation spec
        [hashtable]$cloudInstantiationSpec,
        # The number of existing virtual machine snapshots allowed by Rubrik. Choices range from 0 - 4 snapshots.
        [ValidateRange(0,4)] 
        [Alias('maxNestedVsphereSnapshots')]
        [int]$MaxNestedSnapshots,
        # Whether to pause or resume backups/archival for this VM.
        [Alias('isVmPaused')]
        [Bool]$PauseBackups,
        # User setting to dictate whether to use storage array snaphots for ingest. This setting only makes sense for VMs where array based ingest is possible.
        [Alias('isArrayIntegrationEnabled')]
        [Bool]$UseArrayIntegration,
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

        #region one-off
        if ($SnapConsistency)
        {
            $SnapConsistency = $SnapConsistency -replace 'AUTOMATIC', 'UNKNOWN'
        }
        #endregion             
        
        $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
        $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
        $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
        $result = Test-FilterObject -filter ($resources.Filter) -result $result

        return $result

    } # End of process
} # End of function
#requires -Version 3
function Set-RubrikVolumeFilterDriver
{
  <#  
      .SYNOPSIS
      Used to Install or Uninstall the Rubrik Volume Filter Driver on a registered Windows host.

      .DESCRIPTION
      The Set-RubrikVolumeFilterDriver either installs or uninstalls the Rubrik Volume Filter Driver on a host registered to a Rubrik cluster

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikVolumeFilterDriver.html

      .EXAMPLE
      Set-RubrikVolumeFilterDriver -Id 'Host:::a1e1004c-f460-4ac1-a25a-e07b5eb15443' -Install
      This will install the Volume Filter Driver on the host with an id of Host:::a1e1004c-f460-4ac1-a25a-e07b5eb15443
      
      .EXAMPLE
      Get-RubrikHost -Name server01 -DetailedObject | Set-RubrikVolumeFilterDriver -Remove
      This will remove the Volume Filter Driver on the host named server01
      
      .EXAMPLE
      Set-RubrikVolumeFilterDriver -hostId Host:::a1e1004c-f460-4ac1-a25a-e07b5eb15443, Host:::a1e1043c-f460-4ac1-a25a-e07b5eh45583 -Install
      This will install the Volume Filter Driver on the specifed array of host ids

      .EXAMPLE
      Get-RubrikHost -DetailedObject | Where hostVfdDriverState -ne Installed | Set-RubrikVolumeFilterDriver -Install
      Install Volume Filter Drivers for all hosts where the driver currently is not installed

      .EXAMPLE
      Get-RubrikHost -DetailedObject | Where hostVfdDriverState -eq Installed | Set-RubrikVolumeFilterDriver -Remove
      Uninstall Volume Filter Drivers for all hosts where the driver currently is not installed

  #>

   [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik's host id value
    [Parameter(
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true)]
    [Alias('hostids','id')]
    [String[]]$hostid,
    # Installs the volume filter driver
    [Parameter(ParameterSetName='Install')]
    [switch]$Install,
    # Removes the volume filter driver if installed
    [Parameter(ParameterSetName='Remove')]
    [switch]$Remove,
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
    
    # Update PSBoundParameters for correct processing for New-BodyString
    if ($Install) {
      $PSBoundParameters.Remove('Install') | Out-Null
      $PSBoundParameters.Add('install',$true)
    } elseif ($Remove) {
      $PSBoundParameters.Remove('Remove') | Out-Null
      $PSBoundParameters.Add('install',$false)
    }
  }

  Process {

    #region One-off
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#requires -Version 3
function Start-RubrikManagedVolumeSnapshot
{
  <#  
      .SYNOPSIS
      Starts Rubrik Managed Volume snopshot

      .DESCRIPTION
      The Start-RubrikManagedVolumeSnapshot cmdlet is used to open a Rubrik Managed Volume
      for read/write actions.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Start-ManagedVolumeSnapshot -id ManagedVolume:::f68ecd45-bdb9-46dd-aea4-8f041fb2dec2

      Open the specified managed volume for read/write operations

      .EXAMPLE
      Get-RubrikManagedVolume -name 'foo' | Start-ManagedVolumeSnapshot
      
      Open the 'foo' managed volume for read/write operations.
  #>

   [CmdletBinding()]
  Param(
    # Rubrik's Managed Volume id value
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)    
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#requires -Version 3
function Stop-RubrikManagedVolumeSnapshot
{
  <#  
      .SYNOPSIS
      Stops Rubrik Managed Volume snopshot

      .DESCRIPTION
      The Stop-RubrikManagedVolumeSnapshot cmdlet is used to close a Rubrik Managed Volume
      for read/write actions.

      .NOTES
      Written by Mike Fal for community usage
      Twitter: @Mike_Fal
      GitHub: MikeFal

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/

      .EXAMPLE
      Stop-ManagedVolumeSnapshot -id ManagedVolume:::f68ecd45-bdb9-46dd-aea4-8f041fb2dec2

      Close the specified managed volume for read/write operations

      .EXAMPLE
      Get-RubrikManagedVolume -name 'foo' | Stop-ManagedVolumeSnapshot

  #>

  [CmdletBinding(SupportsShouldProcess = $true)]
  Param(
    # Rubrik's Managed Volume id value
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
     # The SLA Domain in Rubrik
     [String]$SLA,
     # The snapshot will be retained indefinitely and available under Unmanaged Objects
     [Switch]$Forever,
         # SLA id value
    [String]$SLAID, 
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

    #region One-off
    if($SLA -ne $null -or $Forever -eq '$true'){
      $SLAID = Test-RubrikSLA -SLA $SLA -DoNotProtect $Forever
    }
    #endregion One-off
  
  }

  Process {

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    #Custom body is used, uncomment this line and integrate if more options are added
    #$body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)  

    #region Add-SLAID
    if($SLAID){
      $body = @{retentionConfig=@{slaId=$SLAID}} | ConvertTo-Json 
      Write-Verbose -Message "Body = $body"
    }
    #endregion Add-SLAID

    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function

#Requires -Version 3
function Sync-RubrikAnnotation
{
  <#  
      .SYNOPSIS
      Applies Rubrik SLA Domain information to VM Annotations using the Custom Attributes feature in vCenter

      .DESCRIPTION
      The Sync-RubrikAnnotation cmdlet will comb through all VMs currently being protected by Rubrik.
      It will then create Custom Attribute buckets for SLA Domain Name(s) and Snapshot counts and assign details for each VM found in vCenter using Annotations.
      The attribute names can be specified using this function's parameters or left as the defaults. See the examples for more information.
      Keep in mind that this only displays in the VMware vSphere Thick (C#) client, which is deprecated moving forward.

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Sync-RubrikAnnotation.html

      .EXAMPLE
      Sync-RubrikAnnotation
      This will find all VMs being protected with any Rubrik SLA Domain Name and update their SLA and snapshot count annotations
      using the defaults of "Rubrik_SLA" and "Rubrik_Backups" respectively.

      .EXAMPLE
      Sync-RubrikAnnotation -SLA Silver
      This will find all VMs being protected with a Rubrik SLA Domain Name of "Silver" and update their SLA and snapshot count annotations
      using the defaults of "Rubrik_SLA" and "Rubrik_Backups" respectively.

      .EXAMPLE
      Sync-RubrikAnnotation -SLAAnnotationName 'Backup-Policy' -BackupAnnotationName 'Backup-Snapshots' -LatestRubrikBackupAnnotationName 'Latest-Rubrik-Backup'
      This will find all VMs being protected with any Rubrik SLA Domain Name and update their SLA and snapshot count annotations
      using the custom values of "Backup-Policy", "Backup-Snapshots", and 'Latest-Rubrik-Backup' respectively.
  #>

  [CmdletBinding()]
  Param(
    # Optional filter for a single SLA Domain Name
    # By default, all SLA Domain Names will be collected when this parameter is not used
    [Parameter(Position = 0)]
    [ValidateNotNullorEmpty()]
    [String]$SLA,
    # Attribute name in vCenter for the Rubrik SLA Domain Name
    # By default, will use "Rubrik_SLA"
    [Parameter(Position = 1)]
    [ValidateNotNullorEmpty()]
    [ValidateLength(1,63)]
    [String]$SLAAnnotationName = 'Rubrik_SLA',
    # Attribute name in vCenter for quantity of snapshots
    # By default, will use "Rubrik_Backups"
    [Parameter(Position = 2)]
    [ValidateNotNullorEmpty()]
    [ValidateLength(1,63)]
    [String]$BackupAnnotationName = 'Rubrik_Backups',
    # Attribute name in vCenter for latest backup date
    # By default, will use "Rubrik_Latest_Backup"
    [Parameter(Position = 3)]
    [ValidateNotNullorEmpty()]
    [ValidateLength(1,63)]
    [String]$LatestRubrikBackupAnnotationName = 'Rubrik_Latest_Backup',
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
    Test-VMwareConnection
      
  }

  Process {

    Write-Verbose -Message "Ensuring vCenter has attributes for $SLAAnnotationName and $BackupAnnotationName"
    New-CustomAttribute -Name $SLAAnnotationName -TargetType VirtualMachine -ErrorAction SilentlyContinue | Out-Null
    New-CustomAttribute -Name $BackupAnnotationName -TargetType VirtualMachine -ErrorAction SilentlyContinue | Out-Null
    New-CustomAttribute -Name $LatestRubrikBackupAnnotationName -TargetType VirtualMachine -ErrorAction SilentlyContinue | Out-Null

    Write-Verbose -Message 'Updating vCenter annotations'
    foreach ($_ in (Get-RubrikVM -SLA $SLA -DetailedObject)) {
      Set-Annotation -Entity (Get-VM -Id ('VirtualMachine-'+$_.moid)) -CustomAttribute $SLAAnnotationName -Value $_.effectiveSlaDomainName | Out-Null
      Set-Annotation -Entity (Get-VM -Id ('VirtualMachine-'+$_.moid)) -CustomAttribute $BackupAnnotationName -Value $_.snapshotCount | Out-Null
      Set-Annotation -Entity (Get-VM -Id ('VirtualMachine-'+$_.moid)) -CustomAttribute $LatestRubrikBackupAnnotationName -Value ($_.snapshots | Sort-Object -Property date -Descending | Select -First 1).date | Out-Null
      Write-Verbose -Message "Successfully tagged $($_.name) as $($_.effectiveSlaDomainName)"
    }

  } # End of process
} # End of function
#Requires -Version 3
function Sync-RubrikTag
{
  <#  
      .SYNOPSIS
      Connects to Rubrik and creates a vSphere tag for each SLA Domain

      .DESCRIPTION
      The Sync-RubrikTag cmdlet will query Rubrik for all of the existing SLA Domains, and then create a tag for each one

      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Sync-RubrikTag.html

      .EXAMPLE
      Sync-RubrikTag -vCenter 'vcenter1.demo' -Category 'Rubrik'
      This will validate or create a vSphere Category named Rubrik along with a Tag for each SLA Domain found in Rubrik
  #>

  [CmdletBinding()]
  Param(
    # The vSphere Category name for the Rubrik SLA Tags
    [Parameter(Mandatory = $true,Position = 0)]
    [ValidateNotNullorEmpty()]
    [String]$Category,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [String]$api = $global:RubrikConnection.api
  )

  Begin {

    Test-RubrikConnection
    Test-VMwareConnection
  
  }

  Process {
        
    Write-Verbose -Message 'Gather the SLA Domains'
    $sladomain = Get-RubrikSLA

    Write-Verbose -Message 'Validate the tag category exists'
    if (-not ((Get-TagCategory) -eq $Category)) 
    {
      New-TagCategory -Name $Category -Description 'Rubrik SLA Domains' -Cardinality Single -ErrorAction SilentlyContinue
    }
       
    Write-Verbose -Message 'Validate the tags exist'
    foreach ($_ in $sladomain)
    {
      Write-Verbose -Message "Creating $($_.name) tag"
      New-Tag -Name $_.name -Category $Category -ErrorAction SilentlyContinue
    }
        
    Write-Verbose -Message 'Create the DoNotProtect assignment for VMs without an SLA Domain'
    New-Tag -Name 'DoNotProtect' -Category $Category -ErrorAction SilentlyContinue

  } # End of process
} # End of function
#requires -Version 3
function Update-RubrikHost
{
  <#  
      .SYNOPSIS
      Refresh the properties shown for the specified host

      .DESCRIPTION
      Refresh the properties of a host object when changes on the host are not seen in the Rubrik web UI.

      .NOTES
      Written by Chris Lumnah
      Twitter: @lumnah
      GitHub: clumnah

      .LINK
      https://github.com/rubrikinc/rubrik-sdk-for-powershell

      .EXAMPLE
      Get-RubrikHost -Name "am1-sql16fc-1" | Update-RubrikHost
      
      Get the details of Rubrikhost am1-sql16fc-1 and refresh the information of this host on the Rubrik Cluster and returns the information of the host
      
      .EXAMPLE
      Update-RubrikHost -id Host:::ccc9c8f4-6f16-4216-ba46-e9925c67d3b2
      
      Refresh the information of this host by specifying the id on the Rubrik Cluster and returns the information of the host
  #>

  [CmdletBinding()]
  Param(
    # ID assigned to a host object
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
#Requires -Version 3
function Update-RubrikVCenter
{
  <#  
      .SYNOPSIS
      Connects to Rubrik to refresh the metadata for the specified vCenter Server
            
      .DESCRIPTION
      The Update-RubrikVCenter cmdlet will refresh all vCenter metadata known to the connected Rubrik cluster.
            
      .NOTES
      Written by Chris Wahl for community usage
      Twitter: @ChrisWahl
      GitHub: chriswahl

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Update-RubrikVCenter.html
      
      .EXAMPLE
      Get-RubrikVCenter -Name 'vcsa.domain.local' | Update-RubrikVCenter
      This will refresh the vCenter metadata on the currently connected Rubrik cluster

      .EXAMPLE
      Get-RubrikVCenter | Update-RubrikVCenter
      This will refresh the vCenter metadata for all connecter vCenter instances on the currently connected Rubrik cluster
  #>

  [CmdletBinding()]
  Param(
    # vCenter id value from the Rubrik Cluster
    [Parameter(
      ValueFromPipelineByPropertyName = $true,
      Mandatory = $true )]
    [ValidateNotNullOrEmpty()]
    [String]$id,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
#Requires -Version 3
function Update-RubrikVMwareVM
{
  <#  
      .SYNOPSIS
      Connects to Rubrik to refresh the metadata for the specified VMware VM
            
      .DESCRIPTION
      The Update-RubrikVMwareVM cmdlet will refresh the specified VMware VM metadata known to the connected Rubrik cluster.
            
      .NOTES
      Written by Pierre-François Guglielmi for community usage
      Twitter: @pfguglielmi
      GitHub: pfguglielmi

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Update-RubrikVMwareVM.html
      
      .EXAMPLE
      Get-RubrikVM -Name 'myvm.domain.local' | Update-RubrikVMwareVM
      This will refresh the VMware VM metadata on the currently connected Rubrik cluster

      .EXAMPLE
      Update-RubrikVMwareVM -Id vCenter:::1226ff04-6100-454f-905b-5df817b6981a -moid vm-100
      This will refresh the VMware VM metadata, for the VM and vcCenter specified, on the currently connected Rubrik cluster
      
      .EXAMPLE
      Import-Csv .\RefreshVM.csv | Update-RubrikVMwareVM -Verbose
      This will refresh the VMware VM metadata, for the VM and vcCenter specified in the csv file, on the currently connected Rubrik cluster while displaying verbose information. Please note that the .csv file should contain the id and moid fields.
  #>

  [CmdletBinding()]
  Param(
    # vCenter id value from the Rubrik Cluster
    [Parameter(
      ValueFromPipelineByPropertyName = $true,
      Mandatory = $true )]
    [ValidateNotNullOrEmpty()]
    [Alias('id')]
    [String]$vcenterId,
    # VMware VM id value from the Rubrik Cluster
    [Parameter(
      ValueFromPipelineByPropertyName = $true,
      Mandatory = $true )]
    [ValidateNotNullOrEmpty()]
    [Alias('moid')]
    [String]$vmMoid,
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

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $vcenterId
    $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
Export-ModuleMember -Function @(
'Connect-Rubrik','Disconnect-Rubrik','Export-RubrikDatabase',
'Export-RubrikReport','Export-RubrikVM','Get-RubrikAPIToken',
'Get-RubrikAPIVersion','Get-RubrikAvailabilityGroup','Get-RubrikBootStrap',
'Get-RubrikDatabase','Get-RubrikDatabaseFiles','Get-RubrikDatabaseMount',
'Get-RubrikDatabaseRecoverableRange','Get-RubrikEvent','Get-RubrikFileset',
'Get-RubrikFilesetTemplate','Get-RubrikHost','Get-RubrikHyperVVM',
'Get-RubrikLDAP','Get-RubrikLogShipping','Get-RubrikManagedVolume',
'Get-RubrikManagedVolumeExport','Get-RubrikMount','Get-RubrikNASShare',
'Get-RubrikNutanixVM','Get-RubrikOracleDB','Get-RubrikOrganization',
'Get-RubrikReport','Get-RubrikReportData','Get-RubrikRequest',
'Get-RubrikSetting','Get-RubrikSLA','Get-RubrikSnapshot',
'Get-RubrikSoftwareVersion','Get-RubrikSQLInstance','Get-RubrikSupportTunnel',
'Get-RubrikUnmanagedObject','Get-RubrikVCenter','Get-RubrikVersion',
'Get-RubrikVM','Get-RubrikVMSnapshot','Get-RubrikVMwareDatastore',
'Get-RubrikVMwareHost','Get-RubrikVolumeGroup','Get-RubrikVolumeGroupMount',
'Invoke-RubrikRESTCall','Move-RubrikMountVMDK','New-RubrikAPIToken',
'New-RubrikBootStrap','New-RubrikDatabaseMount','New-RubrikFileset',
'New-RubrikFilesetTemplate','New-RubrikHost','New-RubrikLDAP',
'New-RubrikLogBackup','New-RubrikLogShipping','New-RubrikManagedVolume',
'New-RubrikManagedVolumeExport','New-RubrikMount','New-RubrikNASShare',
'New-RubrikReport','New-RubrikSLA','New-RubrikSnapshot',
'New-RubrikVCenter','New-RubrikVMDKMount','New-RubrikVolumeGroupMount',
'Protect-RubrikDatabase','Protect-RubrikFileset','Protect-RubrikHyperVVM',
'Protect-RubrikNutanixVM','Protect-RubrikTag','Protect-RubrikVM',
'Register-RubrikBackupService','Remove-RubrikAPIToken','Remove-RubrikDatabaseMount',
'Remove-RubrikFileset','Remove-RubrikHost','Remove-RubrikLogShipping',
'Remove-RubrikManagedVolume','Remove-RubrikManagedVolumeExport','Remove-RubrikMount',
'Remove-RubrikNASShare','Remove-RubrikReport','Remove-RubrikSLA',
'Remove-RubrikUnmanagedObject','Remove-RubrikVCenter','Remove-RubrikVMSnapshot',
'Remove-RubrikVolumeGroupMount','Reset-RubrikLogShipping','Restore-RubrikDatabase',
'Set-RubrikAvailabilityGroup','Set-RubrikBlackout','Set-RubrikDatabase',
'Set-RubrikHyperVVM','Set-RubrikLogShipping','Set-RubrikManagedVolume',
'Set-RubrikMount','Set-RubrikNASShare','Set-RubrikNutanixVM',
'Set-RubrikSetting','Set-RubrikSLA','Set-RubrikSQLInstance',
'Set-RubrikSupportTunnel','Set-RubrikVCenter','Set-RubrikVM',
'Set-RubrikVolumeFilterDriver','Start-RubrikManagedVolumeSnapshot','Stop-RubrikManagedVolumeSnapshot',
'Sync-RubrikAnnotation','Sync-RubrikTag','Update-RubrikHost',
'Update-RubrikVCenter','Update-RubrikVMwareVM'
)
