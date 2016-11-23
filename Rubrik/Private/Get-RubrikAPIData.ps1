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
        SuccessMock = '{"userId": "11111111-2222-3333-4444-555555555555","token": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"}'
        FailureCode = '422'
        FailureMock = '{"errorType":"user_error","message":"Incorrect Username/Password","cause":null}'
      }
      0 = @{
        URI         = '/login'
        Body        = @('userId', 'password')
        Method      = 'Post'
        SuccessCode = '200'
        SuccessMock = '{"status":"Success","description":"Successfully logged in","userId":"11111111-2222-3333-4444-555555555555","token":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"}'
        FailureCode = '200'
        FailureMock = '{"status": "Failure","description": "Incorrect Username/Password"}'
      }
    }
  } # End of API
  
  return $api.$endpoint
} # End of function
