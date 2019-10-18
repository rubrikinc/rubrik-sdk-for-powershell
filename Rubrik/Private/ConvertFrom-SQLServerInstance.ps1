function ConvertFrom-SqlServerInstance([string]$ServerInstance) {
    <#
        .SYNOPSIS
        Returns a hashtable containing both the Hostname and InstanceName of a SQL Instance.

        .DESCRIPTION
        SQL DBAs commonly refer to SQL instances as the HOSTNAME (for a default instance of MSSQLSERVER) or HOSTNAME\NAMEDINSTANCE for a named instance. 
        This function returns a hash table of Hostname and InstanceName for both naming conventtions to simplify SQL cmdlet calls.

        .EXAMPLE
        ConvertFrom-SQLServerInstance "TESTSERVER\NAMEDINSTANCE"

        hostname   instancename
        --------   ------------
        TESTSERVER NAMEDINSTANCE

        .EXAMPLE
        ConvertFrom-SQLServerInstance "TESTSERVER"

        hostname   instancename
        --------   ------------
        TESTSERVER MSSQLSERVER

    #>    
    if($ServerInstance.Contains('\')){
        $si = $ServerInstance.Split('\')
        $return = New-Object psobject -Property @{'hostname'= $si[0];'instancename'=$si[1]}
    } else {
        $return = New-Object psobject -Property @{'hostname'= $ServerInstance;'instancename'='MSSQLSERVER'}
    }
    return $return
}