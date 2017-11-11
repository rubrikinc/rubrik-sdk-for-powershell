<#
SQL DBAs commonly refer to SQL instances as the HOSTNAME (for a default instance of MSSQLSERVER)
or HOSTNAME\NAMEDINSTANCE for a named instance. This returns a hash table of Hostname and InstanceName
to simplify SQL cmdlet calls.
#>
function ConvertFrom-SqlServerInstance([string]$ServerInstance){
    if($ServerInstance -contains '\'){
        $si = $ServerInstance -split '\'
        $return = New-Object psobject -Property @{'hostname'= $si[0];'instancename'=$si[1]}
    } else {
        $return = New-Object psobject -Property @{'hostname'= $ServerInstance;'instancename'='MSSQLSERVER'}
    }
    return $return
}