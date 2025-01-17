param(
    [string]$extractPath = "C:\mapserver",
    [string]$mapServerConfig = "C:\apps\mapserver.conf",
    [string]$mapCacheConfig = "C:\apps\mapcache.xml"
)

#2. Copy the required .exes into the same folder as the MapServer DLLs. 
# Define the source and destination directories
$destination = $extractPath + "\bin"

#3. Set mapserver.exe to be a FastCGI application and allow it to run in IIS:
# Import the WebAdministration module
Import-Module WebAdministration

$mapservexe = $destination + "\mapserv.exe"

# MapServer FastCGI application settings
$fastCgiApp = @{
    FullPath = $mapservexe
    Arguments = ""
    StdoutLogEnabled = $true
    EnvironmentVariables = @{
        name='MAPSERVER_CONFIG_FILE';value=$mapServerConfig
    }
}

# MapServer handler mapping settings
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
    # Remove the handler mapping
    Remove-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/handlers" -Name "." -AtElement @{name=$handlerMapping["Name"]} 
    Write-Output("FastCGI handler for MapServer removed")
}
Else{        
    Write-Output "No FastCGI handler for MapServer."
}

$FastCGIConfig = Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/fastCgi" -Name "." | Select-Object -ExpandProperty collection | Select-Object fullPath, Arguments
If(($FastCGIConfig.fullPath -eq $fastCgiApp["FullPath"]) -and ($FastCGIConfig.Arguments -eq $fastCgiApp["Arguments"])){
    # Remove the FastCGI application  
    Remove-WebConfigurationProperty  -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/fastCgi" -name "." -AtElement @{fullPath=$mapservexe;arguments=''}
    Write-Output "FactCGI config for MapServer removed"
}
else{
    Write-Output "No FastCGI config for MapServer."
}

#4 IIS MapCache setup
$mapcacheexe = $destination + "\mapcache.fcgi.exe"

# MapCache FastCGI application settings
$fastCgiApp = @{
    FullPath = $mapcacheexe
    Arguments = "cache1"
    StdoutLogEnabled = $true
    EnvironmentVariables = @{
        name='MAPCACHE_CONFIG_FILE';value=$mapCacheConfig
    }
}

# MapCache handler mapping settings
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
    # Remove the handler mapping
    Remove-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/handlers" -Name "." -AtElement @{name=$handlerMapping["Name"]} 
    Write-Output("FastCGI handler for MapCache removed")
}
Else{        
    Write-Output "No FastCGI handler for MapCache."
}

$FastCGIConfig = Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "system.webServer/fastCgi" -Name "." | Select-Object -ExpandProperty collection | Select-Object fullPath, Arguments
If(($FastCGIConfig.fullPath -eq $fastCgiApp["FullPath"]) -and ($FastCGIConfig.Arguments -eq $fastCgiApp["Arguments"])){
    # Remove the FastCGI application
    Remove-WebConfigurationProperty  -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/fastCgi" -name "." -AtElement @{fullPath=$mapcacheexe;arguments='cache1'}
    Write-Output "FactCGI config for MapCache removed"
}
else{    
    Write-Output "No FastCGI config for Mapchache."
}