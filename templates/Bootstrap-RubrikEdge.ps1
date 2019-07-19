# New-RubrikBootStrap/Get-RubrikBootStrap example for bootstrapping Rubrik Edge/Air

# This example uses the IPv4 Locally Assigned Link Address (169.254.x.x) on the Rubrik VM for bootstrap
# You will need an address in this range configured on the NIC of the system you initiate bootstrap from
# Can also use MDNS name - IE VRVW564D3A0BC.local

$server = '169.254.10.10'
$name = 'BootstrapExample'

# Must Be an array even if you only have 1 server
$management_dns = @(
    '8.8.8.8'
)

# Must be an array with a hash table inside
$ntp = @(
    @{
        server = 'pool.ntp.org'
    }
)

# Follow the below format to define additonal nodes
$node = @{
    node1 = @{
        managementIpConfig = @{
            address = '192.168.1.10';
            gateway = '192.168.1.1';
            netmask = '255.255.255.0'
        }
    }
}
$enableSoftwareEncryption = $false

$adminuserinfo = @{
    emailAddress = 'user@email.com';
    id = 'admin';
    password = 'Rubrik123!'
}

Write-Output "Beginning Bootstrap Process"

New-RubrikBootStrap -Server $server -name $name -dnsNameservers $management_dns `
    -ntpserverconfigs $ntp -adminUserInfo $adminuserinfo -nodeconfigs $node `
    -enableSoftwareEncryptionAtRest $enableSoftwareEncryption

$clusterIp = $node.node1.managementIpConfig.address

$attempts = 1

while ($true) {
    Try {
        Write-Output "Polling Bootstrap Status on $($clusterIp)"
        $Status = Get-RubrikBootStrap -Server $clusterIp -RequestId 1
    }
    Catch
    {
        If($_.Exception -eq "No route to host") {
            $attempts += 1
            sleep 30
        }
        Else {
            Write-Output $Status
            Write-Output $_.Exception
            $attempts += 1
            sleep 30
        }
    }

    If($attempts -eq 12) {
        Throw "Timed out attempting to connect"
    }

    If($Status.status -eq "IN_PROGRESS") {
        Write-Output "Bootstrap Status: $($Status.status)"
        sleep 30
    }
    Elseif(($Status.status -eq "FAILURE") -or ($Status.status -eq "FAILED")) {
        Throw "Bootstrap Status: $($Status.status)"
    }
    Elseif($Status.status -eq "SUCCESS")  {
        Return $Status.status
    }
}
