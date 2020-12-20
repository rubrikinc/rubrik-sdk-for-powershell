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
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/invoke-rubrikrestcall

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

      .EXAMPLE
      $body = New-Object -TypeName PSObject -Property @{'isPassthrough'=$true;'shareId'='HostShare:::11111';'templateId'='FilesetTemplate:::22222'}
      Invoke-RubrikRESTCall -Endpoint 'fileset_template/bulk' -Method POST -Body $body -BodyAsArray

      Creates a new fileset from the given fileset template and the given host id supporting Direct Archive.  Since fileset_template/bulk expects an array, we force the single item array with the BodyAsArray parameter.

      .EXAMPLE
      Invoke-RubrikRESTCall -Endpoint 'fileset_template/bulk' -Method POST -Body '{"isPassthrough":true,"shareId":"HostShare:::11111","templateId":"FilesetTemplate:::22222"}' -BodyAsJson

      Creates a new fileset from the given fileset template and the given host id supporting Direct Archive.  Since fileset_template/bulk expects an array, we force the single item array with the BodyAsArray parameter.

      .EXAMPLE
      Invoke-RubrikRESTCall -api internal -Endpoint nutanix/cluster/NutanixCluster:::d34d42c0-5468-4c37-a3cf-4376baf018e4/refresh -Method post

      Refreshes the information of the Nutanix cluster

      .EXAMPLE
      Invoke-RubrikRESTCall -api internal -Endpoint nutanix/cluster/NutanixCluster:::d34d42c0-5468-4c37-a3cf-4376baf018e4/refresh -Method post -Verbose -WhatIf

      Displays Verbose information while not executing the query

      .EXAMPLE
      $currentreport = Get-RubrikReport -name BoringReportName -DetailedObject
      $currentreport.name = "Jaap's QuokkaReport"
      $updatedbody = $currentreport|select * -exclude id,updatestatus,reportTemplate,reportType
      Invoke-RubrikRESTCall -Endpoint "report/$($currentreport.id)" -api internal -Method PATCH -Body $updatedbody -Verbose

      Using this example it is possible to rename an existing report to the report name listed in the second row of this example
  #>

  [cmdletbinding(
    DefaultParameterSetName='General',
    SupportsShouldProcess=$true
  )]
  Param (
      #Rubrik API endpoint, DO NOT USE LEADING '/'
      [Parameter(Mandatory = $true, ParameterSetName='BodyAsArray', HelpMessage = 'REST Endpoint')]
      [Parameter(Mandatory = $true, ParameterSetName='BodyAsJson', HelpMessage = 'REST Endpoint')]
      [Parameter(Mandatory = $true, ParameterSetName='General', HelpMessage = 'REST Endpoint')]
      [ValidateNotNullorEmpty()]
      [System.String]$Endpoint,
      #REST API method
      [Parameter(Mandatory = $true,HelpMessage = 'REST Method')]
      [ValidateSET('GET','PUT','PATCH','DELETE','POST','HEAD','OPTIONS')]
      [System.String]$Method,
      #Hash table body to pass to API call
      [Parameter(Mandatory = $false,HelpMessage = 'REST Query')]
      [ValidateNotNullorEmpty()]
      [psobject]$Query,
      #Hash table body to pass to API call
      [Parameter(Mandatory = $false, HelpMessage = 'REST Body')]
      [ValidateNotNullorEmpty()]
      [psobject]$Body,
      #Force the body as an array (For endpoints requiring single item arrays)
      [Parameter(Mandatory = $true, ParameterSetName='BodyAsArray', HelpMessage = 'Force Body to be an array')]
      [Switch]$BodyAsArray,
      #Allows to input the body as a JSON instead of a hashtable
      [Parameter(Mandatory = $true, ParameterSetName='BodyAsJson', HelpMessage = 'Force Body to be a JSON string')]
      [Switch]$BodyAsJson,
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
            if ($BodyAsArray) {
                [string]$JsonBody = ConvertTo-Json -inputobject @($Body) -Depth 10
            } elseif ($BodyAsJson) {
                [string]$JsonBody = $Body
            }
            else {
                [string]$JsonBody = $Body | ConvertTo-Json -Depth 10
            }
        }
        Write-Verbose "URI string: $uri"
        Write-Verbose "Body string: $JsonBody"

        if ($Method -eq 'Get' -and $Body) {
            Write-Warning 'Executing a ''Get'' request in combination with a body object, processing request without body'
            if ($PSCmdlet.ShouldProcess($uri, 'Invoke WebRequest')) {
                $result = Submit-Request -uri $uri -header $Header -method $Method
            }
        } else {
            if ($PSCmdlet.ShouldProcess($uri, 'Invoke WebRequest')) {
                $result = Submit-Request -uri $uri -header $Header -method $Method -body $JsonBody
            }
        }
        
    }
    catch {
        throw $_
    }

    return $result
  }
}