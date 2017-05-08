Auditing Workflows
========================

This page contains workflows to audit Rubrik activities.

Failed Tasks
------------------------

The activity log contains detailed information on every task. In the event of a failure, a number of options are available to the administrator - alerts, traps, logs, and so forth. If you wish to pull this data for programmatic use, the following workflow can be used:

``New-RubrikReport -ReportType daily -StatusType Failed``

The resulting data will contain a key named ``failureDescription`` that can be parsed for more information. A snippet sample value is shown below:

::

    failureDescription : Rubrik backup service at 'object' returned error: Remote call exception: object:12801 error: SSL_read: Resource temporarily unavailable
    status             : Failed
    jobType            : Backup

Storing this information into a variable, CSV file, or other object can be helpful for pushing failed task data to 3rd party systems.

CSV Export:
    ``New-RubrikReport -ReportType daily -StatusType Failed | Export-Csv -Encoding UTF8 -Path $Home\Documents\Report.CSV -NoTypeInformation``

Store to Variable:
    ``$Report = New-RubrikReport -ReportType daily -StatusType Failed``