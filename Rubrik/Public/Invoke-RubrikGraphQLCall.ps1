function Invoke-RubrikGraphQLCall {
<#
.SYNOPSIS
Provides generic interface to make Rubrik REST API calls

.DESCRIPTION
The Invoke-RubrikGraphQLCall allows users to make raw API endpoint calls to the Rubrik REST interface. The user
will need to manage the format of both the endpoint call(including resource ids) and body, but provides the
option to make cmdlet independent API calls for automating Rubrik actions through PowerShell. The Rubrik API
reference is found on the Rubrik device at:
<Rubrik IP>/docs/v1
<Rubrik IP>/docs/v1/playground

.NOTES
Written by Jaap Brasser for community usage
Twitter: @jaap_brasser
GitHub: jaapbrasser

.LINK
https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/invoke-rubrikgraphqlcall

.EXAMPLE
Invoke-RubrikGraphQLCall -Endpoint 'vmware/vm' -Method GET

Retrieve the raw output for all VMWare VMs being managed by the Rubrik device.

.EXAMPLE
Invoke-RubrikGraphQLCall -Endpoint 'vmware/vm' -Method GET -Query @{'name'='msf-sql2016'}
Retrieve the raw output for the VMWare VM msf-sql2016 using a query parameter.

.EXAMPLE
$body = New-Object -TypeName PSObject -Property @{'slaID'='INHERIT';'ForceFullSnapshot'='FALSE'}
Invoke-RubrikGraphQLCall -Endpoint 'vmware/vm/VirtualMachine:::fbcb1f51-9520-4227-a68c-6fe145982f48-vm-649/snapshot' -Method POST -Body $body

Execute an on-demand snapshot for the VMWare VM where the id is part of the endpoint.

.EXAMPLE
$body = New-Object -TypeName PSObject -Property @{'isPassthrough'=$true;'shareId'='HostShare:::11111';'templateId'='FilesetTemplate:::22222'}
Invoke-RubrikGraphQLCall -Endpoint 'fileset_template/bulk' -Method POST -Body $body -BodyAsArray

Creates a new fileset from the given fileset template and the given host id supporting Direct Archive.  Since fileset_template/bulk expects an array, we force the single item array with the BodyAsArray parameter.
#>
    
      [cmdletbinding()]
      Param (
          #Rubrik API endpoint, DO NOT USE LEADING '/'
          [Parameter(Mandatory = $true,HelpMessage = 'REST Endpoint')]
          [ValidateNotNullorEmpty()]
          [System.String]$Endpoint,
          #Hash table body to pass to API call
          [Parameter(Mandatory = $false,HelpMessage = 'REST Content')]
          [ValidateNotNullorEmpty()]
          [psobject]$Body,
          #Force the body as an array (For endpoints requiring single item arrays)
          [Parameter(Mandatory = $false, HelpMessage = 'Force Body to be an array')]
          [Switch]$BodyAsArray,
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
        #execute GraphQL operation
        try {
    
            #construct uri
            [string]$uri = New-URIString -server $Server -endpoint "/api/internal/graphql"
    
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
                if ($BodyAsArray) {
                    [string]$JsonBody = ConvertTo-Json -inputobject @($Body) -Depth 10
                }
                else {
                    [string]$JsonBody = $Body | ConvertTo-Json -Depth 10
                }
            }
            Write-Verbose "URI string: $uri"
            Write-Verbose "Body string: $JsonBody"
            $result = Submit-Request -uri $uri -header $Header -method $Method -body $JsonBody
        }
        catch {
            throw $_
        }
    
        return $result
      }
    }