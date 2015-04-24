function GetRootNode
{	param($wholeXml)
	return $wholeXml.ArchitectureGraph
}

function GetLinksFromRoot
{	param($rootXml)
	return $rootXml.Reference
}

function GetIdFromModule
{	param($moduleXml)
	return $moduleXml.Identifier
}

function GetNameFromModule
{	param($moduleXml)
	return $moduleXml.Name
}

function GetModulesFromRoot
{	param($rootXml)
	return $rootXml.Module
}

function GetLinkSource
{	param($link)
	return $link.SourceId
}

function GetLinkTarget
{	param($link)
	return $link.TargetId
}