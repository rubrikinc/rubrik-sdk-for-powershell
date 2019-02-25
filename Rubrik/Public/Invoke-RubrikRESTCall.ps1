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
      Invoke-RubrikRESTCall -Endpoint 'vmware/vm' -Method GET -Query (New-Object -TypeName PSObject -Property @{'name'='msf-sql2016'})

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