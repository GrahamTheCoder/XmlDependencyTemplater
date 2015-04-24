function GetModuleNameFromId
{	param($moduleName)
	return $moduleName.Split(" ")[0]
}

function GetRootNode
{	param($wholeXml)
	return $wholeXml.DirectedGraph
}

function GetLinksFromRoot
{	param($rootXml)
	return $rootXml.Links.Link
}

function GetIdFromModule
{	param($moduleXml)
	return GetModuleNameFromId($moduleXml.Id)
}

function GetNameFromModule
{	param($moduleXml)
	return GetModuleNameFromId($moduleXml.Id)
}

function GetModulesFromRoot
{	param($rootXml)
	return $rootXml.Nodes.Node
}

function GetLinkSource
{	param($link)
	return GetModuleNameFromId($link.Source)
}

function GetLinkTarget
{	param($link)
	return GetModuleNameFromId($link.Target)
}