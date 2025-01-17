
$ErrorActionPreference = 'Stop' # stop on all errors
$ms_home = Get-EnvironmentVariable -Name 'MAPSERVER_HOME' -Scope Machine
Uninstall-ChocolateyZipPackage -Packagename $env:ChocolateyPackageName -zipFileName 'release-1930-x64-gdal-3-9-1-mapserver-8-2-0.zip'
Uninstall-ChocolateyEnvironmentVariable -VariableName 'MAPSERVER_HOME' -VariableType Machine

# Uninstall-ChocolateyZipPackage will remove the files from the archive.
# If you wish to remove the directory they were extracted too,
# you'll additionally have to handle that in the script

Remove-Item $ms_home

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$script = Join-Path $toolsDir -ChildPath 'mapserveruninstall.ps1'

Write-Host "Executing script: $script"
& $script -extractPath $ms_home 

