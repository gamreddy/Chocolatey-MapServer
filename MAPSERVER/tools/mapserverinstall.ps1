
param(
    [string]$extractPath = "C:\mapserver",
    [string]$mapServerConfig = "C:\apps\mapserver.conf",
    [string]$mapCacheConfig = "C:\apps\mapcache.xml"
)

#1. If not already installed, install IIS: 
$computerType = (Get-ComputerInfo).OsProductType

if($computerType -eq "WorkStation"){
    Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer, IIS-CGI, IIS-WebServerManagementTools
}else{
    Install-WindowsFeature -name Web-Server, Web-CGI -IncludeManagementTools
}

#2. Copy the required .exes into the same folder as the MapServer DLLs. 
# Define the source and destination directories
$source = $extractPath + "\bin\ms\apps"
$destination = $extractPath + "\bin"
if (Test-Path -Path $source) {
    # Create the destination directory if it doesn't exist
    if (-not (Test-Path -Path $destination)) {
        Write-Output "Destination directory does not exist: $destination"
    }else{
        # Copy the files from source to destination
        Copy-Item -Path "$source\*" -Destination $destination -Force

        Write-Output "Files have been successfully copied from $source to $destination."
    }

} else {
    Write-Output "Source directory does not exist: $source"
}

#3. IIS MapServer setup: Set mapserver.exe to be a FastCGI application and allow it to run in IIS:
# Import the WebAdministration module
Import-Module WebAdministration

$mapservexe = $destination + "\mapserv.exe"

# Define the FastCGI application settings
$fastCgiApp = @{
    FullPath = $mapservexe
    Arguments = ""
    StdoutLogEnabled = $true
    EnvironmentVariables = @{
        name='MAPSERVER_CONFIG_FILE';value=$mapServerConfig
    }
}

# Define the handler mapping settings
$handlerMapping = @{
    Name = "MapServerFCGIHandler"
    Path = "*.service.ows"
    Verb = "*"
    Modules = "FastCgiModule"
    ScriptProcessor = $mapservexe
    ResourceType = "Either"
    RequireAccess = "Script"
}

If ($null -ne (Get-WebHandler -Name $handlerMapping["Name"])) {
    Write-Output("FastCGI handler for MapServer already configured")
}
Else{    
    # Add the handler mapping
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/handlers" -name "." -value $handlerMapping
    Write-Output "FastCGI handler for MapServer has been configured successfully."
}

$FastCGIConfig = Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/fastCgi" -Name "." | Select-Object -ExpandProperty collection | Select-Object fullPath, Arguments
If(($FastCGIConfig.fullPath -eq $fastCgiApp["FullPath"]) -and ($FastCGIConfig.Arguments -eq $fastCgiApp["Arguments"])){
    Write-Output "FactCGI config for MapServer already set"
}
else{
    # Add the FastCGI application
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/fastCgi" -name "." -value $fastCgiApp
    #Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/fastCgi/application[@fullPath='" + $fastCgiApp.FullPath + "' and @arguments='" + $fastCgiApp.Arguments + "']/environmentVariables" -name "." -value $fastCgiApp.EnvironmentVariables    
    Write-Output "FastCGI config for MapServer configured successfully."
}

#4 IIS MapCache setup: Set mapcache.fcgi.exe to be a FastCGI application and allow it to run in IIS:
$mapcacheexe = $destination + "\mapcache.fcgi.exe"

# Define the FastCGI application settings
$fastCgiApp = @{
    FullPath = $mapcacheexe
    Arguments = "cache1"
    StdoutLogEnabled = $true
    EnvironmentVariables = @{
        name='MAPCACHE_CONFIG_FILE';value=$mapCacheConfig
    }
}

# Define the handler mapping for mapcache
$handlerMapping = @{
    Name = "MapCacheFCGIHandler"
    Path = "*.service.cache"
    Verb = "*"
    Modules = "FastCgiModule"
    ScriptProcessor = $mapcacheexe
    ResourceType = "Either"
    RequireAccess = "Script"
}

If ($null -ne (Get-WebHandler -Name $handlerMapping["Name"])) {
    Write-Output("FastCGI handler for MapCache already configured")
}
Else{    
    # Add the handler mapping
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/handlers" -name "." -value $handlerMapping
    Write-Output "FastCGI handler for MapCache has been configured successfully."
}

$FastCGIConfig = Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/fastCgi" -Name "." | Select-Object -ExpandProperty collection | Select-Object fullPath, Arguments
If(($FastCGIConfig.fullPath -eq $fastCgiApp["FullPath"]) -and ($FastCGIConfig.Arguments -eq $fastCgiApp["Arguments"])){
    Write-Output "FactCGI config for MapCache already set"
}
else{
    # Add the FastCGI application
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -filter "system.webServer/fastCgi" -name "." -value $fastCgiApp
    Write-Output "FastCGI config for Mapchache configured successfully."
}