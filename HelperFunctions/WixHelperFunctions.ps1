function GetWixDependencyXml
{	param($moduleDependencyNames)
	return $moduleDependencyNames  | Foreach-Object {"`r`n			<FragmentRef Id=`"$_`"/>"}
}
