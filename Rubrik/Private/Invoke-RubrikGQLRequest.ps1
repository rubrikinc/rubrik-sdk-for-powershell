function Invoke-RubrikGQLRequest {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        $query,
        $variables
    )

    $rscuri = "$($global:rubrikConnection.RSCInstance)/api/graphql"
    $rscheaders = $global:rubrikConnection.RSCHeaders
    $method = "POST"
 
    $query = Get-Content "$($MyInvocation.MyCommand.Module.ModuleBase)\GQLOperations\$query.gql"
    $query = ([String]::Join(" ",($query.split("`n")))).Trim()
    if ($variables) {
        $body = @{
            "query" = $query
            "variables" = $variables
          } | ConvertTo-Json -Compress -Depth 5
    } else {
        $body = @{
            "query" = $query
          } | ConvertTo-Json -Compress -Depth 5
    }
    $response = Invoke-WebRequest -Uri $rscuri -method $method -body $body -Headers $rscheaders
    return $response
}

