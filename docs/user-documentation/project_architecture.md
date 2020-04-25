# Project Architecture

This page contains details on the artifacts found within the repository.

* docs: Documentation on the module
* templates: Templates for creating your own functions
* tests: Pester unit tests used to validate the public functions
* workflows: Sample workflows for more complex automation tasks
* Rubrik: The parent folder containing the module
  * Private: Private functions that are used internally by the module
  * Public: Published functions that are available to the PowerShell session
  * ObjectDefinitions: Custom TypeName view definitions applicable to Rubrik objects
  * OptionsDefault: Template of module options and default parameters
  * Rubrik.psd1: Module manifest
  * Rubrik.psm1: Script module file

