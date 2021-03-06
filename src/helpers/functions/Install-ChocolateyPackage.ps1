﻿function Install-ChocolateyPackage {
<#
.SYNOPSIS
Installs a package

.DESCRIPTION
This will download a file from a url and install it on your machine.

.PARAMETER PackageName
The name of the package we want to download - this is arbitrary, call it whatever you want.
It's recommended you call it the same as your nuget package id.

.PARAMETER FileType
This is the extension of the file. This should be either exe or msi.

.PARAMETER SilentArgs
OPTIONAL - These are the parameters to pass to the native installer.
Try any of these to get the silent installer - /s /S /q /Q /quiet /silent /SILENT /VERYSILENT
With msi it is always /quiet. Please pass it in still but it will be overridden by chocolatey to /quiet.
If you don't pass anything it will invoke the installer with out any arguments. That means a nonsilent installer.

Please include the notSilent tag in your chocolatey nuget package if you are not setting up a silent package.

.PARAMETER Url
This is the url to download the file from. 

.PARAMETER Url64bit
OPTIONAL - If there is an x64 installer to download, please include it here. If not, delete this parameter

.PARAMETER options
OPTIONAL - Specify custom headers

Example:
-------- 
	$options = 
	@{
		Headers = @{
			Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'; 
			'Accept-Charset' = 'ISO-8859-1,utf-8;q=0.7,*;q=0.3';
			'Accept-Language' = 'en-GB,en-US;q=0.8,en;q=0.6';
			Cookie = 'products.download.email=ewilde@gmail.com';
			Referer = 'http://submain.com/download/ghostdoc/';
		}
	}
	
	Get-ChocolateyWebFile 'ghostdoc' 'http://submain.com/download/GhostDoc_v4.0.zip' -options $options
	
.EXAMPLE
Install-ChocolateyPackage '__NAME__' 'EXE_OR_MSI' 'SILENT_ARGS' 'URL' '64BIT_URL_DELETE_IF_NO_64BIT'

.OUTPUTS
None

.NOTES
This helper reduces the number of lines one would have to write to download and install a file to 1 line.
This method has error handling built into it.

.LINK
Get-ChocolateyWebFile
Install-ChocolateyInstallPackage
#>
param(
  [string] $packageName, 
  [string] $fileType = 'exe',
  [string] $silentArgs = '',
  [string] $url,
  [string] $url64bit = $url,
  [hashtable] $options = @{Headers=@{}},
  $validExitCodes = @(0)
)
  
  try {
    Write-Debug "Running 'Install-ChocolateyPackage' for $packageName with url:`'$url`', args: `'$silentArgs`' ";

    $chocTempDir = Join-Path $env:TEMP "chocolatey"
    $tempDir = Join-Path $chocTempDir "$packageName"
    if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
    $file = Join-Path $tempDir "$($packageName)Install.$fileType"
  
    Get-ChocolateyWebFile $packageName $file $url $url64bit -options $options
    Install-ChocolateyInstallPackage $packageName $fileType $silentArgs $file -validExitCodes $validExitCodes
    Write-ChocolateySuccess $packageName
  } catch {
    Write-ChocolateyFailure $packageName $($_.Exception.Message)
    throw 
  }
}