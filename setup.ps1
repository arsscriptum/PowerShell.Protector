
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>

[CmdletBinding(SupportsShouldProcess)]
param ()


#===============================================================================
# Script Variables
#===============================================================================
$Script:ProjectRoot = (Resolve-Path "$PSScriptRoot").Path
$Script:ConsoleBuilderScript = (Resolve-Path "$Script:ProjectRoot\scripts\ConsoleBuilder.ps1").Path
#$Script:GuiBuilderScript = (Resolve-Path "$Script:ProjectRoot\scripts\GuiCompiler.ps1").Path
#$Script:GuiBuilder = Join-Path "$Script:ToolsPath" "GuiBuilder.exe"
$Script:ToolsPath = Join-Path "$Script:ProjectRoot" "tools"
$Script:IconFile = (Resolve-Path "$Script:ToolsPath\ico\DEFAULT_ICON_FILE.ico").Path
$Script:ScriptsPath = Join-Path "$Script:ProjectRoot" "scripts"
$Script:TmpBuildPath = Join-Path "$Script:ProjectRoot" "tmpbuild"
$Script:BuildScript = Join-Path "$Script:ProjectRoot" "Build-Script.ps1"
$Script:BuildFunctions = Join-Path "$Script:ScriptsPath" "BuildFunctions.ps1"
$Script:ConsoleBuilder = Join-Path "$Script:ToolsPath" "ConsoleBuilder.exe"



. "$Script:BuildFunctions"

#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "[WARNING] " -f DarkYellow -n
    Write-Host "You didn't run this script as an Administrator!" -f DarkRed 
    Write-Host "[WARNING] " -f DarkYellow -n
    Write-Host "This script will self elevate before continuing." -f DarkCyan -n
    Start-Sleep 2
    Start-Process pwsh.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

$RegPathPSBuilder="$ENV:OrganizationHKCU\PowerShellBuilder"
$PSBuilderRoot = (Get-ItemProperty -Path "$RegPathPSBuilder" -Name "PowerShellBuilderRoot").PowerShellBuilderRoot

function Initialize-PowerShellBuilder{
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    try{
        New-Item -Path "$Script:ToolsPath" -Force -ItemType Directory | Out-Null

        Write-Host "===============================================================================" -f DarkRed
        Write-Host "CONFIGURATION of DEVELOPMENT ENVIRONMENT for BUILD AUTOMATION " -f DarkYellow;
        Write-Host "===============================================================================" -f DarkRed    
        Write-Host "Current Path     `t" -NoNewLine -f DarkYellow ; Write-Host "$Script:ProjectRoot" -f Gray 
        Write-Host "Compile Script   `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:ConsoleBuilder" -f Gray 


        Write-Host "===============================================================================" -f DarkRed
        Write-Host "SETTING REGISTRY ENTRIES" -f DarkYellow;
        Write-Host "===============================================================================" -f DarkRed   

        $Script:RegPathPSBuilder="$ENV:OrganizationHKCU\PowerShellBuilder"
        $Null = Remove-Item -Path $Script:RegPathPSBuilder -Force -Recurse -ErrorAction ignore
        if((Get-Item -Path $Script:RegPathPSBuilder -ErrorAction ignore) -eq $null){
            Write-Host " (o) " -f DarkRed -NoNewLine
            (New-Item -Path $Script:RegPathPSBuilder -Force).Name
        }

        Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPathPSBuilder -Name "PowerShellBuilderRoot" -Value $Script:ProjectRoot -Force).PSPath
        Write-Host " (o) " -f DarkRed -NoNewLine ; (New-ItemProperty -Path $Script:RegPathPSBuilder -Name "ConsoleBuilder" -Value $Script:ConsoleBuilder -Force).PSPath  

        . "$Script:BuildScript" -ScriptPath "$Script:ConsoleBuilderScript"  -OutputDir "$Script:TmpBuildPath"
        Move-Item "$Script:TmpBuildPath\Program.exe" "$Script:ConsoleBuilder"
        Remove-Item -Path "$Script:TmpBuildPath" -Recurse -Force | Out-Null
        Write-Host "Compiler `"$Script:ConsoleBuilder`" Ready!" -f Green

        # TODO : MAke GUI Builder
    }catch{
        throw "$_"
    }
}



function Set-SystemFileAssociations{
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT  | Out-Null

    $RegPath = "HKCR:\SystemFileAssociations\.ps1\Shell\PowerShellBuilder"
    $null=New-Item -Path "$RegPath" -Force | Out-Null
    $null=New-ItemProperty -Path "$RegPath" -Name "MUIVerb" -PropertyType String -Value "PowerShell Builder"
    $null=New-ItemProperty -Path "$RegPath" -Name "Icon" -PropertyType String -Value "$Script:IconFile"


    $RegPath = "HKCR:\SystemFileAssociations\.ps1\Shell\PowerShellBuilder\command"
    $null=New-Item -Path $RegPath -Value "$Script:ConsoleBuilder `"%1`"" -Force 

    $RegPath = "HKCR:\SystemFileAssociations\.ps1\Shell\PowerShellBuilder_ext"
    $null=New-Item -Path "$RegPath" -Force | Out-Null
    $null=New-ItemProperty -Path "$RegPath" -Name "MUIVerb" -PropertyType String -Value "PowerShell Builder Extended"
    $null=New-ItemProperty -Path "$RegPath" -Name "Icon" -PropertyType String -Value "$Script:IconFile"
    $null=New-ItemProperty -Path "$RegPath" -Name "HasLuaShield" -PropertyType String -Value ""
    $null=New-ItemProperty -Path "$RegPath" -Name "Extended" -PropertyType String -Value ""
    $RegPath = "HKCR:\SystemFileAssociations\.ps1\Shell\PowerShellBuilder_ext\command"
    $null=New-Item -Path $RegPath -Value "$Script:GuiBuilder `"%1`"" -Force 
    Remove-PSDrive HKCR
}

try{
    Initialize-PowerShellBuilder
    Set-SystemFileAssociations

    Set-AppConsoleProperties "$Script:ConsoleBuilder" 10 10 120 50 -BackgroundColor Black -ForegroundColor LightAqua

}catch{
    Write-Error "$_"
}