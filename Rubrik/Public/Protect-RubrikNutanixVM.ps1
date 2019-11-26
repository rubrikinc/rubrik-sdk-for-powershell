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
      https://rubrik.gitbook.io/rubrik-sdk-for-powershell/command-documentation/reference/protect-rubriknutanixvm
            
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