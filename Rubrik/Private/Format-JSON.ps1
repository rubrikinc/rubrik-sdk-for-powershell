<#
    Helper JSON functions to resolve the ConvertFrom-JSON maxJsonLength limitation, which defaults to 2 MB
    http://stackoverflow.com/questions/16854057/convertfrom-json-max-length/27125027
#>

function ExpandPayload($response) {
  <#
    .SYNOPSIS
    This function use the .Net JSON Serializer in order to bypass the maxJson Length limitation
  #>
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Web.Extensions')

  if ($rubrikOptions.ModuleOption.LegacyJSONConversion -eq 'Experimental' -or $rubrikOptions.ModuleOption.LegacyJSONConversion -eq 'AlwaysExperimental') {
    return ParseItemExp -jsonItem ((New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{
      MaxJsonLength = $response.length
    }).DeserializeObject($response))
  } else {
    return ParseItem -jsonItem ((New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{
      MaxJsonLength = 67108864
    }).DeserializeObject($response))
  }
}


function ParseItem($jsonItem) {
  <#
    .SYNOPSIS
    Main function that determines the type of object and calls either ParseJsonObject or ParseJsonArray
  #>
  Write-Verbose 'Using ParseItem to Write-Verbose to convert JSON to PowerShell Object'
  if($jsonItem.PSObject.TypeNames -match 'Array') {
    return ParseJsonArray -jsonArray ($jsonItem)
  } elseif($jsonItem.PSObject.TypeNames -match 'Dictionary') {
    return ParseJsonObject -jsonObj ([HashTable]$jsonItem)
  } else  {
    return $jsonItem
  }
}

function ParseJsonObject($jsonObj) {
  <#
    .SYNOPSIS
    Converts JSON to PowerShell Custom objects
  #>
  $result = New-Object -TypeName PSCustomObject
  foreach ($key in $jsonObj.Keys) 
  {
    $item = $jsonObj[$key]

    if ($null -ne $item) {
      $parsedItem = ParseItem -jsonItem $item
    } else {
      $parsedItem = $null
    }

    $result | Add-Member -MemberType NoteProperty -Name $key -Value $parsedItem
  }
  return $result
}

function ParseJsonArray($jsonArray) {
  <#
    .SYNOPSIS
    Expands the array and feeds this back into ParseItem, in case of nested arrays this might occur multiple times
  #>
  $result = @()
  $jsonArray | ForEach-Object -Process {
    $result += , (ParseItem -jsonItem $_)
  }
  return $result
}

function ParseItemExp($jsonItem) {
  <#
    .SYNOPSIS
    Experimental faster: main function that determines the type of object and calls either ParseJsonObjectExp or ParseJsonArrayExp
  #>
  Write-Verbose 'Using ParseItemExp to Write-Verbose to convert JSON to PowerShell Object'
  if($jsonItem.PSObject.TypeNames -match 'Array') {
    ParseJsonArrayExp -jsonArray ($jsonItem)
  } elseif($jsonItem.PSObject.TypeNames -match 'Dictionary') {
    ParseJsonObjectExp -jsonObj ([HashTable]$jsonItem)
  } else  {
    $jsonItem
  }
}

function ParseJsonObjectExp($jsonObj) {
  <#
    .SYNOPSIS
    Experimental faster: Converts JSON to PowerShell Custom objects
  #>
  $result = @{}
  foreach ($key in $jsonObj.Keys) 
  {
    
    if (-not [string]::IsNullOrEmpty($jsonObj[$key])) {
      $result[$key] = ParseItemExp -jsonItem $jsonObj[$key]
    } else {
      $result[$key] = $null
    }
  }
  [pscustomobject]$result
}

function ParseJsonArrayExp($jsonArray) {
  <#
    .SYNOPSIS
    Experimental faster: Expands the array and feeds this back into ParseItem, in case of nested arrays this might occur multiple times
  #>
  @(
    $jsonArray | ForEach-Object -Process {
      ParseItemExp -jsonItem $_
    }
  )
}