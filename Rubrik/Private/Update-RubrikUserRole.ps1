function Update-RubrikUserRole($role, $roleUri, $roleMethod) {
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
      # Build body for end_user add/delete
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
  $body = ConvertTO-Json $body
  $uri = New-URIString -server $Server -endpoint "$roleUri"
  $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
  $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
  $result = Test-FilterObject -filter ($resources.Filter) -result $result

  return $result

}