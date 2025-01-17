
$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
# $url = "https://www.gisinternals.com/query.html?content=filelist&file=release-1930-x64-gdal-3-10-0-mapserver-8-2-2.zip"
# $destination = "C:\temp\mapserver"

$pp = Get-PackageParameters

if(!$pp.ZipUrl){
  $pp.ZipUrl = "https://www.gisinternals.com/query.html?content=filelist&file=release-1930-x64-gdal-3-10-0-mapserver-8-2-2.zip"
}

if(!$pp.InstallationPath){
  $pp.InstallationPath = "$env:SystemDrive\mapserver"
}

if(!$pp.MapServerConfig){
  $pp.MapServerConfig = "$env:SystemDrive\apps\mapserver.conf"
}

if(!$pp.MapCacheConfig){
  $pp.MapCacheConfig = "$env:SystemDrive\apps\mapcache.xml"
}

$zipArgs = @{
  Packagename = $env:ChocolateyPackageName
  url = $pp.ZipUrl
  unzipLocation = $pp.InstallationPath
}

Install-ChocolateyZipPackage @zipArgs
Install-ChocolateyEnvironmentVariable -VariableName "MAPSERVER_HOME" -VariableValue $pp.InstallationPath -VariableType Machine

$script = Join-Path $toolsDir -ChildPath 'mapserverinstall.ps1'

Write-Host "Executing script: $script"
& $script -extractPath $pp.InstallationPath -mapServerConfig $pp.MapServerConfig -mapCacheConfig $pp.MapCacheConfig