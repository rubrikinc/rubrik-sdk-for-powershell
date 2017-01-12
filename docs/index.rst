Welcome to the Rubrik PowerShell Module
========================

.. image:: https://ci.appveyor.com/api/projects/status/52cv3jshak2w7624?svg=true
   :target: https://ci.appveyor.com/project/chriswahl/powershell-module

.. image:: http://readthedocs.org/projects/powershell-module/badge/?version=latest
   :target: http://powershell-module.readthedocs.io/en/latest/?badge=latest

This is a community project that provides a Windows PowerShell module for managing and monitoring Rubrik's Converged Data Management fabric by way of published RESTful APIs. If you're looking to perform interactive automation, setting up scheduled tasks, leverage an orchestration engine, or need ad-hoc operations, this module is intended to be valuable to your needs. The code is open source, and `available on GitHub`_.

Below is a quick YouTube video that explains how to begin using the module. 

.. image:: http://i.imgur.com/MGHfunv.png
   :target: https://www.youtube.com/watch?v=XJ6IaVhYWWY

.. _available on GitHub: https://github.com/rubrikinc/PowerShell-Module

.. toctree::
   :maxdepth: 2
   :hidden:
   :caption: User Documentation

   requirements
   installation
   getting_started
   project_architecture
   support
   contribution
   licensing  
   faq

.. toctree::
   :maxdepth: 2
   :hidden:
   :caption: Command Documentation

   cmd_connect
   cmd_get
   cmd_move
   cmd_new
   cmd_protect
   cmd_remove
   cmd_set
   cmd_start
   cmd_stop
   cmd_sync

.. toctree::
   :maxdepth: 2
   :hidden:
   :caption: Workflow Examples

   flow_audit
   flow_backup_validation
