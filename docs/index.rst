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

The main documentation for the project is organized into a couple sections:

* :ref:`user-docs`
* :ref:`command-docs`
* :ref:`workflow-docs`

.. _user-docs:

.. toctree::
   :maxdepth: 2
   :caption: User Documentation

   requirements
   installation
   support
   contribution
   licensing  
   faq

.. _command-docs:

.. toctree::
   :maxdepth: 2
   :caption: Command Documentation

   connect
   sla_domain
   snapshot
   live_mount

.. _workflow-docs:

.. toctree::
   :maxdepth: 2
   :caption: Workflow Examples

   backup_validation

   design
   theme
