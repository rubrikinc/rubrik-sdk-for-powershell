function Update-RubrikUserRole($role, $roleUri, $roleMethod) {
  <#
    .SYNOPSIS
    Updates a users role within Rubrik

    .DESCRIPTION
    The Update-RubrikUserRole function is used to create and submit the proper request to the proper endpoint in order to update a users role within the Rubrik cluster.

    .PARAMETER role
    The role to update (admin/end_user/no_access/etc)
    
    .PARAMETER roleUri
    The URI to use when constructing the API request

    .PARAMETER roleMethod
    The HTTP Method to apply to the API request.
  #>
   
  # Set the Method
  $resources.Method = $roleMethod

  # Build body based on role
  switch ($role) {
    "admin" {
      $body = @{
        principals = @($id)
        privileges = @{
          fullAdmin = @("Global:::All")
        }
      } 
    }
    "end_user" {
      $body = @{
        principals = @($id)
        privileges = @{
          viewEvent              = $EventObjects
          restoreWithoutDownload = $RestoreWithoutDownloadObjects
          destructiveRestore     = $RestoreWithOverwriteObjects
          onDemandSnapshot       = $OnDemandSnapshotObjects
          viewReport             = $ReportObjects
          restore                = $RestoreObjects
          provisionOnInfra       = $InfrastructureObjects
        }
      }
    }
    "read_only_admin" {
      $body = @{
        principals = @($id)
        privileges = @{
          basic = @("Global:::All")
        }
      } 
    }
    "end_user_clear" {
      # Retrieve current end user privileges from user to use in deletion body
      $endUserPrivileges = (Get-RubrikUserRole -id $id).endUser
      # Set empty properties of privileges to empty array, set single results to array of 1
      if ($null -ne $endUserPrivileges) {
        $endUserPrivileges.PSObject.Properties | ForEach-Object { 
          if ($_.Value.Count -eq 0) { $_.Value = @() }
          elseif ($_.Value.Count -eq 1) { $_.Value = @($_.Value) } 
        }
      }
      # Build body for end_user 
      $body = @{
        principals = @($id)
        privileges = $endUserPrivileges
      }
    }
  }
  $body = ConvertTo-Json $body
  $uri = New-URIString -server $Server -endpoint "$roleUri"
  $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
  $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
  $result = Test-FilterObject -filter ($resources.Filter) -result $result

  return $result

}