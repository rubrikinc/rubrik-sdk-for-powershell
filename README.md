# Rubrik SDK for PowerShell

[![Build status](https://ci.appveyor.com/api/projects/status/52cv3jshak2w7624?svg=true)](https://ci.appveyor.com/project/chriswahl/powershell-module)

This is a community project that provides a Microsoft PowerShell module for managing and monitoring Rubrik's Cloud Data Management fabric by way of published RESTful APIs. If you're looking to perform interactive automation, setting up scheduled tasks, leverage an orchestration engine, or need ad-hoc operations, this module is intended to be valuable to your needs.

# :hammer: Installation

Load the module by using:

`Import-Module Rubrik`

If you wish to load a specific version, use:

`Import-Module Rubrik -RequiredVersion #.#.#.#`

Where `#.#.#.#` represents the version number.

# :mag: Example

The Rubrik SDK for PowerShell provides two mechanisms for supplying credentials to the Connect-Rubrik function. A combination of username and password or a credential object. Credentials in the credential object may be entered manually or provided as an object. The example below prompts for a username and password to create a credential object, connects to a cluster and displays the running version.

```
$Credential = Get-Credential
Connect-Rubrik -Server 192.168.10.10 -Credential $Credential
Get-RubrikVersion
```

# :blue_book: Documentation

Here are some resources to get you started! If you find any challenges from this project are not properly documented or are unclear, please [raise an issue](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/new/choose) and let us know! This is a fun, safe environment - don't worry if you're a GitHub newbie! :heart:

* [Quick Start Guide](https://github.com/rubrikinc/rubrik-sdk-for-powershell/blob/master/docs/quick-start.md)
* [Rubrik SDK for PowerShell Documentation](http://rubrikinc.github.io/rubrik-sdk-for-powershell/)
* [Rubrik API Documentation](https://github.com/rubrikinc/api-documentation)

## Additional Links

* [VIDEO: Getting Started with the Rubrik SDK for PowerShell](https://www.youtube.com/watch?v=tY6nQLNYRSE)
* [BLOG: Get-Started with the Rubrik PowerShell Module](https://www.rubrik.com/blog/get-started-rubrik-powershell-module/)
* [BLOG: Using Automation to Validate Applications and Services in Rubrik Backups](https://www.rubrik.com/blog/automation-to-validate-in-rubrik-backups/)
* [BLOG: PowerShell and RESTful APIs - Making Backup Awesome Again](https://www.rubrik.com/blog/powershell-and-restful-apis-making-backup-awesome-again/)

# :muscle: How You Can Help

We glady welcome contributions from the community. From updating the documentation to adding more functions, all ideas are welcome. Thank you in advance for all of your issues pull requests, and comments! :star:

* [Contributing Guide](CONTRIBUTING.md)
* [Code of Conduct](CODE_OF_CONDUCT.md)

## Important Note
As we continue to improve our Community PowerShell module we have begun work on the next version of the module. As we are working on refactoring the module we will focus our attention on the refactor branch. As a result of this code rewrite we are focussed on the 
`rubrik-sdk-for-powershell/Refactor` branch. We do still take issues and pull requests but we are mostly focussed on bug fixes in the existing branch.

### Moving forward
We will continue to support the issues and pull requests coming in, but for the 4.0 version of the module we will focus on bug fixes and security risks. New features and functionality will be implemented in the refactored 4.1 release of the module. If you have any questions in regards to this feel free to reach out to us.

# :pushpin: License

* [MIT License](LICENSE)

# :point_right: About Rubrik Build

We encourage all contributors to become members. We aim to grow an active, healthy community of contributors, reviewers, and code owners. Learn more in our [Welcome to the Rubrik Build Community](https://github.com/rubrikinc/welcome-to-rubrik-build) page.

We'd love to hear from you! Email us: build@rubrik.com :love_letter: