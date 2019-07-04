<#
    Helper JSON functions to resolve the ConvertFrom-JSON maxJsonLength limitation, which defaults to 2 MB
    http://stackoverflow.com/questions/16854057/convertfrom-json-max-length/27125027
#>

function ExpandPayload($response) {
<#
.SYNOPSIS
This function use the .Net JSON Serializer in order to 
#>
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Web.Extensions')
  return ParseItem -jsonItem ((New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{
        MaxJsonLength = 67108864
  }).DeserializeObject($response.Content))
}


function ParseItem($jsonItem) {
<#
.SYNOPSIS
Main function that determines the type of object and calls 
#>
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
Expands the array and feeds this back into ParseItem
#>
  $result = @()
  $jsonArray | ForEach-Object -Process {
    $result += , (ParseItem -jsonItem $_)
  }
  return $result
}