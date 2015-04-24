#Must have loaded definitions for all the graph traversal methods first!

function GetDependencyMappings
{	param($architectureXmlFileName)
	[xml]$architectureXml = Get-Content $architectureXmlFileName
	$modules = @{}
	
	Write-Host $architectureXml
	$graph = GetRootNode($architectureXml)
	foreach ($module in GetModulesFromRoot($graph))
	{
		$references = New-Object Collections.Generic.List[String]
		$identifier = GetIdFromModule($module)
		$properties = @{'Id'=$identifier; 'Name'=GetNameFromModule($module); 'References' = $references}
		
		$modules[$identifier] = (New-Object PSObject -property $properties)
	}
	$mappings = GetLinksFromRoot($graph)
	foreach ($mapping in $mappings)
	{
		$source = GetLinkSource($mapping)
		$target = GetLinkTarget($mapping)
		
		$sourceModule = $modules.Item($source)
		$targetModule = $modules.Item($target)
		$sourceModule.References.Add($targetModule.Name)
	}
	
	return $modules
}