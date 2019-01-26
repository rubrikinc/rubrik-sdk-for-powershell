Community PowerShell Module for Rubrik
============================

[![Build status](https://ci.appveyor.com/api/projects/status/52cv3jshak2w7624?svg=true)](https://ci.appveyor.com/project/chriswahl/powershell-module)

This is a community project that provides a Microsoft PowerShell module for managing and monitoring Rubrik's Cloud Data Management fabric by way of published RESTful APIs. If you're looking to perform interactive automation, setting up scheduled tasks, leverage an orchestration engine, or need ad-hoc operations, this module is intended to be valuable to your needs.

## Installation

Load the module by using:

`Import-Module Rubrik`

If you wish to load a specific version, use:

`Import-Module Rubrik -RequiredVersion #.#.#.#`

Where `"#.#.#.#"` represents the version number.

## Quick Start

* [Quick Start Guide](https://github.com/rubrikinc/rubrik-sdk-for-powershell/blob/master/docs/quick-start.md)

## Documentation

* [Rubrik SDK for PowerShell Documentation](http://rubrikinc.github.io/rubrik-sdk-for-powershell/)
* [Rubrik API Documentation](https://github.com/rubrikinc/api-documentation)

## Important Note
As we continue to improve our Community PowerShell module we have begun work on the next version of the module. As we are working on refactoring the module we will focus our attention on the refactor branch. As a result of this code rewrite we are focussed on the 
`rubrik-sdk-for-powershell/Refactor` branch. We do still take issues and pull requests but we are mostly focussed on bug fixes in the existing branch.

### Moving forward
We will continue to support the issues and pull requests coming in, but for the 4.0 version of the module we will focus on bug fixes and security risks. New features and functionality will be implemented in the refactored 4.1 release of the module. If you have any questions in regards to this feel free to reach out to us.

## Additional Links

* [Getting Started Video](https://www.youtube.com/watch?v=tY6nQLNYRSE)
