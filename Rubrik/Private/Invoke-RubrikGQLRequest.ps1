function Invoke-RubrikGQLRequest {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        $query
    )

    $rscuri = "$($global:rubrikConnection.RSCInstance)/api/graphql"
    $rscheaders = $global:rubrikConnection.RSCHeaders
    $method = "POST"
 

    $response = Invoke-WebRequest -Uri $rscuri -method $method -body $query -Headers $rscheaders

    return $response
}

