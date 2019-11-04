# Getting Started

Now that you have the Rubrik module installed on your workstation, there's a few beginner commands that you can explore to feel comfortable with the available functions.

## Connecting to the Rubrik Cluster

To begin, let's connect to a Rubrik cluster. To keep things simple, we'll do the first command without any supplied parameters.

* Open a PowerShell session
* Type `Connect-Rubrik` and press enter.

A prompt will appear asking you for a server. Enter the IP address or fully qualified domain name \(FQDN\) of any node in the cluster. An additional prompt will appear asking for your user credentials. Once entered, you will see details about the newly created connection.

![Example](http://i.imgur.com/DKDDW3P.png)

At this point, you are authenticated and ready to begin issuing commands to the cluster.

## Commands and Help

What if we didn't know that `Connect-Rubrik` exists? To see a list of all available commands, type in `Get-Command -Module Rubrik`. This will display a list of every function available in the module. Note that all commands are in the format of **Verb-RubrikNoun**. This has two benefits:

* Adheres to the Microsoft requirements for PowerShell functions.
* Use of "Rubrik" in the name avoids collisions with anyone else's commands.

For details on a command, use the PowerShell help command `Get-Help`. For example, to get help on the `Connect-Rubrik` function, use the following command:

`Get-Help Connect-Rubrik`

This will display a description about the command. For details and examples, use the `-Full` parameter on the end.

`Get-Help Connect-Rubrik -Full`

## Gathering Data

Let's get information on the cluster. The use of any command beginning with the word **get** is safe to use. No data will be modified. These are good commands to use if this is your first time using PowerShell.

We'll start by looking up the version running on the Rubrik cluster. Enter the command below and press enter:

`Get-RubrikVersion`

The result is fairly simple: the command will output the cluster's code version. How about something a bit more complex? Try getting all of the SLA Domain details from the cluster. Here's the command:

`Get-RubrikSLA`

Lots of stuff should be scrolling across the screen. You're seeing details on every SLA Domain known by the cluster at a very detailed level. If you want to see just one SLA Domain, tell the command to limit results. You can do this by using a _parameter_. Parameters are ways to control a function. Try it now.

`Get-RubrikSLA -SLA "Gold"`

The `-SLA` portion is a parameter and "Gold" is a value for the parameter. This effectively asks the function to limit results to one SLA Domain: gold. Easy, right?

For a full list of available parameters and examples, use `Get-Help Get-RubrikSLA -Full`. Every Rubrik command has native help available.

## Modifying Data

Not every command will be about gathering data. Sometimes you'll want to modify or delete data, too. The process is nearly the same, although some safeguards have been implemented to protect against errant modifications. Let's start with an easy one.

This works best if you have a test virtual machine that you don't care about. Make sure that virtual machine is visible to the Rubrik cluster. To validate this, use the following command:

`Get-RubrikVM -VM "Name"`

Make sure to replace `"Name"` with the actual name of the virtual machine. If you received data back from Rubrik, you can be sure that this virtual machine is known to the cluster and can be modified.

Note: The double quotes are required if your virtual machine has any spaces in the name. It's generally considered a good habit to always use double quotes around the name of objects.

Let's protect this virtual machine with the "Gold" SLA Domain. To do this, use the following command:

`Get-RubrikVM -VM "Name" | Protect-RubrikVM -SLA "Gold"`

Before the change is made, a prompt will appear asking you to confirm the change.

::

```text
Confirm
Are you sure you want to perform this action?
Performing the operation "Assign SLA Domain 1234567890" on target "Name".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):
```

This is a safeguard. You can either take the default action of "Yes" by pressing enter, or type "N" if you entered the wrong name or changed your mind. If you want to skip the confirmation check all together, use the `-Confirm:$false` parameter like this:

`Protect-RubrikVM -VM "Name" -SLA "Gold" -Confirm:$false`

This will make the change without asking for confirmation. Be careful!

