<#
    Helper function to retrieve API data from Rubrik
#>
function GetRubrikAPIData($endpoint)
{
  $api = @{
    Login = @{
      1 = @{
        URI         = '/api/v1/login'
        Body        = @('username', 'password')
        Method      = 'Post'
        SuccessCode = '200'
        SuccessBody = @("userId","token")
        FailureCode = '422'
        Failurebody = @('errorType', 'message', 'cause')
      }
      0 = @{
        URI         = '/login'
        Body        = @('userId', 'password')
        Method      = 'Post'
        SuccessCode = '200'
        SuccessBody = @("status","description","userId","token")
        FailureCode = '200'
        FailureBody = @('status', 'description')
      }
    }
  } # End of API
  
  return $api.$endpoint
} # End of function
