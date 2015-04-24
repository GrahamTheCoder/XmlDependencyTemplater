param($architectureXml = "Input\FromReSharperAnalyseProjectDependencies.argr", $wixOutputDir = '..\Install\WiX2\Source Files\Export', $nuspecOutputDir = '..\Nuspec', $saOutputDir = '..\MSBuild\sa')

$powershellDirectory = Split-Path $MyInvocation.MyCommand.Path
$helperFunctionsDirectory = Join-Path $powershellDirectory 'HelperFunctions'
. $helperFunctionsDirectory\WixHelperFunctions.ps1
. $helperFunctionsDirectory\NuspecHelperFunctions.ps1

#HACK: Consider using .NET types for their polymorphism instead
if ($architectureXml.EndsWith("argr")) { 
. $helperFunctionsDirectory\ResharperDependenciesHelperFunctions.ps1
}
elseif ($architectureXml.EndsWith("dgml")) {
 . $helperFunctionsDirectory\NugetDependenciesHelperFunctions.ps1
}

. $helperFunctionsDirectory\DependencyMappingsHelperFunctions.ps1

if(!(Test-Path -Path $wixOutputDir )){
    New-Item -ItemType directory -Path $wixOutputDir
}

if(!(Test-Path -Path $nuspecOutputDir )){
    New-Item -ItemType directory -Path $nuspecOutputDir
}

function GetUndottedModuleName
{	param($moduleName)
	$titleCaseModuleName = $moduleName -creplace "SQL","Sql" -creplace "IO","Io"
	return [string]::join('', $titleCaseModuleName.split("."))
}

function HashStringToGuid
{	param($inputString)
	$historicalWix = @{"ExampleExistingWixFragment" = "{BD4D1647-C1B0-47a1-A72A-BB7EF699073E}"}
	if ($historicalWix.ContainsKey($inputString)) { return $historicalWix.Item($inputString) }
    $provider = new-object System.Security.Cryptography.MD5CryptoServiceProvider
	$enc = [system.Text.Encoding]::UTF8
    $bytes = [System.Byte[]] $enc.GetBytes($inputString)
	$hashedBytes = $provider.ComputeHash(($bytes))
    $guid = new-object -TypeName System.Guid -ArgumentList (,$hashedBytes) #Wrap in another array because powershell is dumb
	return $guid.ToString("B").ToUpper()
}

function CreateFileFor
{	param([string] $sourceFile = 'Templates\template', $moduleName, $dependencyXml, $outputFolder, $suffix, $undottedFilename = $true)
	$undottedModuleName = GetUndottedModuleName($moduleName)
	$moduleNameWithSpaces = $moduleName.split(".")
	$lastPart = $moduleName.split(".")[-1]
	$shortName = "Rg" + $lastPart.Substring(0,  [Math]::Min($lastPart.Length, 6))
	$fileToEdit = if ($undottedFilename) {"$undottedModuleName$suffix" } else { "$moduleName$suffix" }
	$guid1 = HashStringToGuid $undottedModuleName
	$guid2 = HashStringToGuid ($undottedModuleName + "Docs")
	$template = (Get-Content $sourceFile$suffix)
	$withNamesReplaced = $template | Foreach-Object {$_ -replace "_moduleName_",$moduleName -replace "_undottedModuleName_",$undottedModuleName -replace "_shortName_",$shortName -replace "_moduleNameWithSpaces_", $moduleNameWithSpaces}
	$withGuidsReplaced = $withNamesReplaced | Foreach-Object {$_ -replace "_guid1_", $guid1 -replace "_guid2_", $guid2}
	$withDependencies = $withGuidsReplaced | Foreach-Object {$_ -replace "_dependencies_", $dependencyXml}
	Set-Content "$outputFolder\$fileToEdit" $withDependencies
}

#Create this file by saving ReSharper's Analyze project dependencies graph
$modules = GetDependencyMappings($architectureXml)

foreach($module in $modules.Values)
{
	$undottedReferences = $module.References | Foreach-Object { GetUndottedModuleName($_) }
	$wixDependencyXml = GetWixDependencyXml $undottedReferences
	CreateFileFor -moduleName $module.Name -outputFolder $wixOutputDir -dependencyXml $wixDependencyXml -suffix ".wxs"
	
	$nuspecDependencyXml = GetNuspecDependencyXml($module.References)
	CreateFileFor -moduleName $module.Name -outputFolder $nuspecOutputDir -dependencyXml $nuspecDependencyXml -suffix ".nuspec"
	
	$nuspecObfuscatedDependencyXml = GetNuspecDependencyXml($module.References) -dependencyIdSuffix ".Obfuscated"
	CreateFileFor -moduleName $module.Name -outputFolder $nuspecOutputDir -dependencyXml $nuspecObfuscatedDependencyXml -suffix ".Obfuscated.nuspec"
	
	CreateFileFor -moduleName $module.Name -outputFolder $saOutputDir -dependencyXml "" -suffix ".dll.saproj" -undottedFilename $false
}
