<#
Helper JSON functions to resolve the ConvertFrom-JSON maxJsonLength limitation, which defaults to 2 MB
http://stackoverflow.com/questions/16854057/convertfrom-json-max-length/27125027
#>
function ParseItem($jsonItem) 
{
    if($jsonItem.PSObject.TypeNames -match 'Array') 
    {
        return ParseJsonArray($jsonItem)
    }
    elseif($jsonItem.PSObject.TypeNames -match 'Dictionary') 
    {
        return ParseJsonObject([HashTable]$jsonItem)
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
        if ($item) 
        {
            $parsedItem = ParseItem $item
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
        $result += , (ParseItem $_)
    }
    return $result
}

function ParseJsonString($json) 
{
    $config = $javaScriptSerializer.DeserializeObject($json)
    return ParseJsonObject($config)
}