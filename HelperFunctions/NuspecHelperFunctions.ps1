function GetNuspecDependencyXml
{	param($moduleDependencyNames, $dependencyIdSuffix = '')
	return $moduleDependencyNames  | Foreach-Object {"`r`n	  <dependency id=`"$_$dependencyIdSuffix`" version=`"[`$version`$]`" />"}
}
