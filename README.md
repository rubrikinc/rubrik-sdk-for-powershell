# Rubrik SDK for PowerShell

This is a community project that provides a Microsoft PowerShell module for managing and monitoring Rubrik's Multi-Cloud Data Control fabric by way of published RESTful APIs. If you're looking to perform interactive automation, setting up scheduled tasks, leverage an orchestration engine, or need ad-hoc operations, this module is intended to be valuable to your needs.

# :hammer: Installation

Load the module by using:

`Import-Module Rubrik`

If you wish to load a specific version, use:

`Import-Module Rubrik -RequiredVersion #.#.#`

Where `#.#.#` represents the version number, for example 5.3.1

# :mag: Example

The Rubrik SDK for PowerShell provides two mechanisms for supplying credentials to the Connect-Rubrik function. A combination of username and password or a credential object. Credentials in the credential object may be entered manually or provided as an object. The example below prompts for a username and password to create a credential object, connects to a cluster and displays the running version.

```powershell
$Credential = Get-Credential
Connect-Rubrik -Server 192.168.10.10 -Credential $Credential
Get-RubrikDebugInfo
```

# :blue_book: Documentation

Here are some resources to get you started! If you find any challenges from this project are not properly documented or are unclear, please [raise an issue](https://github.com/rubrikinc/rubrik-sdk-for-powershell/issues/new/choose) and let us know! This is a fun, safe environment - don't worry if you're a GitHub newbie! :heart:

* [Quick Start Guide](/docs/quick-start.md)
* [Rubrik SDK for PowerShell Documentation](https://rubrik.gitbook.io/rubrik-sdk-for-powershell/)
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

# :pushpin: License

* [MIT License](LICENSE)

# :point_right: About Rubrik Build

We encourage all contributors to become members. We aim to grow an active, healthy community of contributors, reviewers, and code owners. Learn more in our [Welcome to the Rubrik Build Community](https://github.com/rubrikinc/welcome-to-rubrik-build) page.

We'd love to hear from you! Email us: build@rubrik.com :love_letter:
