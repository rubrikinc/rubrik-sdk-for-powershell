Contribution
========================

Everyone is welcome to contribute to this project. Here are the high level steps involved:

1. Create a fork of the project into your own repository.
2. From your fork, create a new feature branch (other than master) that expresses your feature or enhancement.
3. Make all your necessary changes in your feature branch.
4. Create a pull request with a description on what was added or removed and details explaining the changes in lines of code.

If approved, project owners will merge it.

Creating a New Function
------------------------

To keep the module simple, each function is saved as its own ps1 file and stored in ``Rubrik\Public``. The naming format is ``Verb-RubrikNoun.ps1`` in which ``Verb`` is a Microsoft approved verb (Use ``Get-Verb`` to see the list) and the noun is singular. Therefore "Get-RubrikVM" is acceptable but "Get-RubrikVMs" is not. You can quickly bootstrap this process by using either the ``template\Verb-RubrikNoun.ps1`` file as a template or pick from an existing function that contains code you'd like to re-use.

Every function needs to have two specific variables included and should not be removed:

1. ``[String]$Server = $global:RubrikConnection.server`` - Stores the Rubrik cluster's IP or FQDN
2. ``[String]$api = $global:RubrikConnection.api`` - Stores the API version

Storing API Data
------------------------

All API specific data for a function is abstracted into a helper function located in ``Rubrik\Private`` named ``Get-RubrikAPIData.ps1``. This separates function logic from function data and allows for simple iterations to cross different API versions while also making unit testing much simpler. If your function is going to call the API directly, all API specific requirements should be stored in ``Get-RubrikAPIData.ps1``. Data is stored in a hashtable like the sample below:

.. code:: PowerShell

    EndpointMethod = @{
        v1 = @{
            URI         = '/api/v1/endpoint'
            Body        = @{
                Body1Key  = 'body_value'
                Body2Key  = 'body_value'
            }
            Params      = @{
                Param1Key = 'param_value'
                Param2Key = 'param_value'
            }
            Method      = 'Get'
            Result      = 'data'
            Filter      = @{
                '$Var1' = 'filter_key'
                '$Var2' = 'filter_key'
            }
            SuccessCode = '200'
            SuccessMock = '{paste JSON data here}'
            FailureCode = '401'
            FailureMock = '{paste JSON data here}'
            }
        }

The list below contains detailed information on each key/value pair in the hashtable:

* v1 = The API version in which the data supplied applies.
* URI = The URI path details needed to reach the endpoint. Do not include the server information.
* Body = Any parameters to pass into the body of the request. The key will be used for lookups to return the parameter name, since parameter names may change from one version of the API to another.
* Params = Any parameters to pass into the header of the request. The key will be used for lookups to return the parameter name, since parameter names may change from one version of the API to another.
* Method = The method used on the endpoint's resource.
* Filter = If there are any filters to apply on the data returned from the API call, supply them here. The key will be used for lookups against a user's input variable against a specific field found in the return.
* SuccessCode = The return code to indicate the call was successful.
* SuccessMock = A mocked success return value to be used for unit testing the function.
* FailureCode = The return code to indicate the call has failed.
* FailureMock = A mocked failure return value to be used for unit testing the function.

The final step is to update the module manifest and add the new function to the ``FunctionsToExport`` value. This is done in the ``Rubrik\Rubrik.psd1`` file.