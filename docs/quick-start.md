# Introduction to the Rubrik SDK for PowerShell

Rubrik's API first architecture enables organizations to embrace and integrate Rubrik functionality into their existing automation processes. While Rubrik APIs can be consumed natively, companies are at various stages in their automation journey with different levels of automation knowledge on staff. The Rubrik SDK for PowerShell is a project that provides a Microsoft PowerShell module for managing and monitoring Rubrik's Cloud Data Management fabric by way of published RESTful APIs. If you are looking to perform interactive automation, set up scheduled tasks, leverage an orchestration engine, or need ad-hoc operations, this module will be be valuable to your needs.

# Prerequisites

The code assumes that you have already deployed at least one Rubrik cluster into your environment and have completed the initial configuration process to form a cluster. At a minimum, make sure you have installed the following:

1. [PowerShell](https://aka.ms/getps6) Core or Windows PowerShell
1. [PowerCLI](http://www.vmware.com/go/powercli) version 6.0 or higher

## Note - PowerShell Core

*The module has been written with PowerShell Core support in mind. For best performance and compatibility, the most recent release of PowerShell Core is recommended with the Rubrik PowerShell Module.*

# Installation

The Rubrik SDK for PowerShell project contains a folder named [Rubrik](https://github.com/rubrikinc/PowerShell-Module/tree/master/Rubrik). The folder needs to be installed into one of your PowerShell Module Paths using one of the installation options outlined below. To see the full list of available PowerShell Module paths, use `$env:PSModulePath.split(';')` in a PowerShell console.

Common PowerShell module paths include:

1. Current User: `%USERPROFILE%\Documents\WindowsPowerShell\Modules\`
1. All Users: `%ProgramFiles%\WindowsPowerShell\Modules\`
1. OneDrive: `$env:OneDrive\Documents\WindowsPowerShell\Modules\`

## Option 1: PowerShell Gallery (Recommended)

1. Ensure you have the [Windows Management Framework 5.0](htps://www.microsoft.com/en-us/download/details.aspx?id=50395) or greater installed.
1. Open a Powershell console with the Run as Administrator option.
1. Run `Set-ExecutionPolicy` using the parameter RemoteSigned or Bypass.
1. Run `Install-Module -Name Rubrik -Scope CurrentUser` to download the module from the PowerShell Gallery. Note that the first time you install from the remote repository it may ask you to first trust the repository.
1. Alternatively `Install-Module -Name Rubrik -Scope AllUsers` can be execute be used if you would like to install the module for all users on the current system.

## Option 2: Installer Script

1. Download the [master branch](https://github.com/rubrikinc/PowerShell-Module) to your workstation.
1. Open a Powershell console with the _Run as Administrator_ option.
1. Run `Set-ExecutionPolicy` using the parameter _RemoteSigned_ or _Bypass_.
1. Run the `Install-Rubrik.ps1` script in the root of this repository and follow the prompts to install, upgrade, or delete your Rubrik Module contents.

## Option 3: Manual Installation

1. Download the [master branch](https://github.com/rubrikinc/PowerShell-Module) to your workstation.
1. Copy the contents of the Rubrik folder onto your workstation into the desired PowerShell Module path.
1. Open a Powershell console with the _Run as Administrator_ option.
1. Run `Set-ExecutionPolicy` using the argument _RemoteSigned_ or _Bypass_.

## Options 4: Download Module from PowerShell Gallery for redistribution

1. Navigate to [PowerShell Gallery - Rubrik](https://www.powershellgallery.com/packages/Rubrik)
1. Click Manual Download.
1. Click Download the raw nupkg file.
   1. To directly use the module, the .nupkg file can be extracted on the destination system. Be sure the place the files in PSModulePath to allow for automatic loading.
   1. Alternatively, this file can be imported in a local nupkg repository for further distribution

## Verification

PowerShell will create a folder for each new version of any module you install. It's a good idea to check and see what version(s) you have installed and running in the session. To begin, let's see what versions of the Rubrik Module are installed:

``` PowerShell
Get-Module -ListAvailable -Name Rubrik
```

The `-ListAvailable` switch will pull up all installed versions from any path found in `$env:PSModulePath`. Check to make sure the version you wanted is installed. You can safely remove old versions, if desired.

To see which version is currently loaded, use:

``` PowerShell
Get-Module Rubrik
```

If nothing is returned, you need to first load the module by using:

``` PowerShell
Import-Module Rubrik
```

If you wish to load a specific version, use:

``` PowerShell
Import-Module Rubrik -RequiredVersion #.#.#.#
```

Where "#.#.#.#" represents the version number.

# Authentication

The Rubrik SDK for PowerShell provides two mechanisms for supplying credentials to the `Connect-Rubrik` function. A combination of username and password or a credential object. Credentials in the credential object may be entered manually or provided as an object.

#### Authenticate by Providing Username and Password

To authenticate with your Rubrik cluster you can make use of the `-UserName` and `-Password` parameters.

#### Authenticate by providing credential object

It is also possible to store your credentials in a credential object by using the built-in Get-Credential cmdlet. To store your credentials in a variable, the following sample can be used:

``` PowerShell
$Credential = Get-Credential
```

PowerShell will prompt for the UserName and Password and the credentials will be securely stored in the `$Credential` variable. This variable can now be used to authenticate against the Rubrik Cluster in by running the following code:

``` PowerShell
Connect-Rubrik -Server yourip -Credential $Credential
```

Using credential objects can reduce the amount of time you have to enter your username and password.

# Interacting with Rubrik

Now that you have the Rubrik module installed on your workstation, here are a few beginner commands that you can explore to feel comfortable with the available functions.

## Connecting to the Rubrik Cluster

To begin, connect to a Rubrik cluster. To keep things simple, we'll do the first command without any supplied parameters.

* Open a PowerShell session
* Type `Connect-Rubrik` and press enter.

A prompt will appear asking you for a server. Enter the IP address or fully qualified domain name (FQDN) of any node in the cluster. An additional prompt will appear asking for your user credentials. Once entered, you will see details about the newly created connection.

![alt text](/docs/img/image1.png)

At this point, you are authenticated and ready to begin issuing commands to the cluster. This token will be valid for the duration of the PowerShell session. If you close your PowerShell console or open an additional console you will have to re-authenticate using the `Connect-Rubrik` function.

## Commands and Help

What if we didn't know that `Connect-Rubrik` exists? To see a list of all available commands, type in `Get-Command -Module Rubrik`. This will display a list of every function available in the module. Note that all commands are in the format of **Verb-RubrikNoun**. This has two benefits:

* Adheres to the Microsoft requirements for PowerShell functions.
* Use of "Rubrik" in the name avoids collisions with anyone else's commands.

For details on a command, use the PowerShell help command `Get-Help`. For example, to get help on the `Connect-Rubrik` function, use the following command:

``` PowerShell
Get-Help Connect-Rubrik
```

![alt text](/docs/img/image2.png)

This will display a description about the command. For details and examples, use the `-Full` parameter on the end.

``` PowerShell
Get-Help Connect-Rubrik -Full
```

![alt text](/docs/img/image3.png)

As this is a lot of help to process, the help function can be used instead of Get-Help, to get scrolling output.

``` PowerShell
help Connect-Rubrik -Full
```

![alt text](/docs/img/image4.png)

## Gathering Data

Let's get information on the cluster. The use of any command beginning with the word get is safe to use. No data will be modified, so these are good commands to use if this is your first time using PowerShell.

We'll start by looking up the version running on the Rubrik cluster. Enter the command below and press enter:

``` PowerShell
Get-RubrikVersion
```

![alt text](/docs/img/image5.png)

The result is fairly simple: the command will output the cluster's code version. How about something a bit more complex? Try getting all of the SLA Domain details from the cluster. Here's the command:

``` PowerShell
Get-RubrikSLA
```

![alt text](/docs/img/image6.png)

A lot of stuff should be scrolling across the screen. You're seeing details on every SLA Domain known by the cluster at a very detailed level. If you want to see just one SLA Domain, tell the command to limit the results. You can do this by using a parameter. Parameters are ways to control a function. Try it with this example:.

``` PowerShell
Get-RubrikSLA -SLA 'Gold'
```

![alt text](/docs/img/image7.png)

The `-SLA` portion is a parameter and "Gold" is a value for the parameter. This effectively asks the function to limit results to one SLA Domain: Gold. Easy, right?

For a full list of available parameters and examples, use `Get-Help Get-RubrikSLA -Full`. Every Rubrik command has native help available.

## Modifying Data

Not every command will be about gathering data. Sometimes you'll want to modify or delete data, too. The process is nearly the same, although some safeguards have been implemented to protect against errant modifications. Let's start with an simple one.

This example works best if you have a test virtual machine that you are not concerned with changes being made to it. Make sure that virtual machine is visible to the Rubrik cluster. To validate this, use the following command:

``` PowerShell
Get-RubrikVM -VM "JBrasser-Win"
```

![alt text](/docs/img/image8.png)

Make sure to replace `"JBrasser-Win"` with the actual name of the virtual machine. If you received data back from Rubrik, you can be sure that this virtual machine is known to the cluster and can be modified.

### Note - Quoting Rules

*The double quotes, or single quotes, are required if your virtual machine has any spaces in the name. It's generally considered a good habit to always use quotes around the name of objects.*

Let's protect this virtual machine with the "Gold" SLA Domain. To do this, use the following command:

``` PowerShell
Get-RubrikVM -VM 'Name' | Protect-RubrikVM -SLA 'Gold'
```

Before the change is made, a prompt will appear asking you to confirm the change.

![alt text](/docs/img/image9.png)

This is a safeguard. You can either take the default action of "Yes" by pressing enter, or type "N" if you entered the wrong name or changed your mind. If you want to skip the confirmation check all together, use the `-Confirm:$false` parameter like this:

``` PowerShell
Get-RubrikVM -VM 'Name' | Protect-RubrikVM -SLA 'Gold' -Confirm:$false
```

This will make the change without asking for confirmation. Be careful!

Additionally, it is also possible to either set the confirmation preference for an individual cmdlet or function by changing the default parameters and arguments:

``` PowerShell
$PSDefaultParameterValues = @{"Rubrik\Protect-RubrikVM:Confirm" = $false}
```

![alt text](/docs/img/image10.png)

By setting this, for the duration of your current PowerShell session, `Protect-RubrikVM` will no longer prompt for confirmation.

## Gather data for reporting

If we want to know the status of backups for certain workloads or SLAs we can easily gather this data using the PowerShell module.

``` PowerShell
Get-RubrikVM -SLAID 'Gold'
```

We can use the SLAID parameter of Get-RubrikVM to only gather a list of VMs that are protected under the Gold SLA. If we want to have the number of VMs that are protected under the Gold SLA, we can use the `Measure-Object` cmdlet in PowerShell:

``` PowerShell
Get-RubrikVM -SLAID 'Gold' | Measure-Object
```

![alt text](/docs/img/image10.png)

If we want to make this output readable, we could also choose to only display either the output or the count-property:

``` PowerShell
Get-RubrikVM -SLAID 'Gold' | Measure-Object | Select-Object -Property Count
Get-RubrikVM -SLAID 'Gold' | Measure-Object | Select-Object -ExpandProperty Count
```

Alternatively we can also display all VMs that are protected by any SLA:

``` PowerShell
Get-RubrikVM | Where-Object {$_.EffectiveSlaDomainName -ne 'Unprotected'}
```

We use the PowerShell `Where-Object` cmdlet to filter out VMs that are not protected by SLAs. Now if we want to take this one step further, we can also make a generate a summary of all the number of VMs assigned to each SLA:

``` PowerShell
Get-RubrikVM | Where-Object {$_.EffectiveSlaDomainName -ne 'Unprotected'} |
Group-Object -Property EffectiveSlaDomainName | Sort-Object -Property Count -Descending
```

![alt text](/docs/img/image14.png)

We can use the `Group-Object` cmdlet to group objects together, by then piping this through to the `Sort-Object` cmdlet we can sort on the number of assigned workloads to each SLA. This can information can be used to directly query the system, without having to login to the Rubrik Cluster and retrieving this information from the interface.

## Assign SLA based on source file

In PowerShell we have the possibility to work data from different sources. In the following example we will use an external `.csv` file to assign Rubrik SLAs based on what is defined in the CSV file.

In the first example we will use PowerShell to generate a `.csv` file for us:

``` PowerShell
1..25 | ForEach-Object {
    [pscustomobject]@{
        Name = "TestVM$_"
        SLA  = ('Gold','Silver','Bronze' | Get-Random)
    }
} | Export-Csv -Path ./Example-SLA.csv -NoTypeInformation
```

![alt text](/docs/img/image11.png)

If you have a spreadsheet application installed, we can now open this spreadsheet by running the following code:

``` PowerShell
Invoke-Item ./Example-SLA.csv
```

![alt text](/docs/img/image12.png)

Now if we would like to make changes we can easily edit the `.csv` file. Once we have made the desired modifications, for example changes the SLAs for certain mission critical VMs to Gold, we can apply this configuration to our Rubrik Cluster:

``` PowerShell
Import-Csv -Path ./Example-SLA.csv | ForEach-Object {
    Get-RubrikVM $_.Name | Protect-RubrikVM -SLA $_.SLA -Confirm:$false
}
```

## Making changes based on csv-input

This code will change the SLAs for all the VMs that are listed in the .csv file, verify that want to make those changes to be made before running this against your Rubrik cluster. This is good practice in general, make sure you use the correct data source (the csv file in our example), that you target the right environment (the Rubrik Cluster) and finally make sure that your PowerShell code does what you expect it to do.

The advantage of using the PowerShell module to automate tasks such as assigning SLAs to specific machines should be apparent here. The alternative, doing this through the GUI, is a slower process and more error prone. A single miss-click means assigning the wrong SLA. By writing a script or putting together a couple of PowerShell code you can automate a task forever.

# Building Your Own Commands

The PowerShell SDK supports the majority of the functionality available within the Rubrik CDM. That said, the release cycles between the SDK and Rubrik CDM are not simultaneous. This means there may be times when new features or enhancements are added to the product but methods and functions to utilize them may be missing from the SDK.

Links to the API documentation available online are available at the end of this Quick Start. If you currently have access to a Rubrik cluster you can browse to either of the following urls:

[https://yourserver/docs/v1/playground/](https://yourserver/docs/v1/playground/)
[https://yourserver/docs/internal/playground/](https://yourserver/docs/internal/playground/)

## Sample Syntax

In situations where the functions in the Rubrik SDK for PowerShell do not fulfill your specific use-case, it is possible to use the `InvokeRubrikRESTCall` function. The `Invoke-RubrikRESTCall` function, may be used to make native calls to Rubrik's RESTful API. The following syntax outlines a common piece of Rubrik functionality, assigning a VM to an SLA Domain, however, it does so by creating raw API requests to Rubrik CDM using the `Invoke-RubrikRESTCall` function

``` PowerShell
Invoke-RubrikRESTCall -Endpoint 'vmware/vm' -Method GET
```

Retrieve the raw output for all VMware VMs being managed by the Rubrik device. It is the most direct method of interacting with the Rubrik API that is found in this module.

We can also create more complex commands, for example:

``` PowerShell
$body = New-Object -TypeName PSObject -Property @{'slaID'='INHERIT';'ForceFullSnapshot'='FALSE'}
Invoke-RubrikRESTCall -Endpoint 'vmware/vm/VirtualMachine:::fbcb1f51-9520-4227-a68c-6fe145982f48-vm-649/snapshot' -Method POST -Body $body
```

This executes an on-demand snapshot for the VMware VM where the id is part of the endpoint.

Rubrik prides itself upon its API-first architecture, ensuring everything available within the HTML5 interface, and more, is consumable via a RESTful API. For more information on Rubrik's API architecture and complete API documentation, please see the official Rubrik API Documentation.

# Further Reading

* [Rubrik PowerShell SDK GitHub Repository](https://github.com/rubrikinc/rubrik-sdk-for-powershell)
* [Rubrik PowerShell SDK Official Documentation](http://rubrikinc.github.io/rubrik-sdk-for-powershell/)
* [Rubrik CDM API Documentation (v1)](https://rubrikinc.github.io/api-doc-v1/)
* [Rubrik CDM API Documentation (internal)](https://rubrikinc.github.io/api-doc-internal/)
* [Get-Started with the Rubrik PowerShell Module](https://www.rubrik.com/blog/get-started-rubrik-powershell-module/)
