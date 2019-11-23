---
name: Bug Report
about: Report a bug encountered while using the Rubrik SDK for PowerShell.
title: ''
labels: kind-bug
assignees: ''

---

<!-- Please use this template while reporting a bug and provide as much info as possible. Not doing so may result in your bug not being addressed in a timely manner. Thanks!-->

<!-- Any bug reports submitted will be visible publicly, do not include any confidential information in this bug report. !-->

**Current Behavior**:

Provide information about the failure by issuing the command using the `-Verbose` command. Ensure that any identifiable information (server names, tokens, passwords) is removed from your logs before sharing this on GitHub. 

```
Paste the verbose output from the command here
```

**Expected Behavior**:

**Steps to Reproduce**:

Please provide detailed steps for reproducing the issue.

1. Step 1
1. Step 2
1. Step 3 (and so on)

**Context**:

Please provide any relevant information about your setup. This is important in case the issue is not reproducible except for under certain conditions.

* **Rubrik PowerShell Module Version**: Use `Get-Module -ListAvailable Rubrik`
* **PowerShell Version**: Use `$PSVersiontable.PSVersion`
* **Operating System**: Use `$PSVersiontable.PSVersion` on PowerShell 6 and later, use `(Get-WMIObject win32_operatingsystem).Name` for Windows PowerShell

**Failure Logs**

Please include any relevant log snippets or files here, *IMPORTANT* all information will be visible publicly on GitHub. Do not include computer or user names, passwords, API tokens or any identifiable information when submitting failure logs.
