<#
    Helper JSON functions to resolve the ConvertFrom-JSON maxJsonLength limitation, which defaults to 2 MB
    http://stackoverflow.com/questions/16854057/convertfrom-json-max-length/27125027
#>

function ExpandPayload($response)
{
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Web.Extensions')
  return ParseItem -jsonItem ((New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer -Property @{
        MaxJsonLength = 67108864
  }).DeserializeObject($response.Content))
}
function ParseItem($jsonItem) 
{
  if($jsonItem.PSObject.TypeNames -match 'Array') 
  {
    return ParseJsonArray -jsonArray ($jsonItem)
  }
  elseif($jsonItem.PSObject.TypeNames -match 'Dictionary') 
  {
    return ParseJsonObject -jsonObj ([HashTable]$jsonItem)
  }
  else 
  {
    return $jsonItem
  }
}

function ParseJsonObject($jsonObj) 
{
  $result = New-Object -TypeName PSCustomObject
  foreach ($key in $jsonObj.Keys) 
  {
    $item = $jsonObj[$key]
    if ($null -ne $item) 
    {
      $parsedItem = ParseItem -jsonItem $item
    }
    else 
    {
      $parsedItem = $null
    }
    $result | Add-Member -MemberType NoteProperty -Name $key -Value $parsedItem
  }
  return $result
}

function ParseJsonArray($jsonArray) 
{
  $result = @()
  $jsonArray | ForEach-Object -Process {
    $result += , (ParseItem -jsonItem $_)
  }
  return $result
}

function ParseJsonString($json) 
{
  $config = $javaScriptSerializer.DeserializeObject($json)
  return ParseJsonObject -jsonObj ($config)
}