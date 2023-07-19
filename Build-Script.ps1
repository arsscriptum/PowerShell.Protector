
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$ScriptPath,
    [Parameter(Position=1, Mandatory=$true)]
    [string]$OutputDir,
    [Parameter(Mandatory=$false)]
    [string]$IconPath,
    [Parameter(Mandatory=$false)]
    [switch]$GUI,
    [Parameter(Mandatory=$false)]
    [switch]$Admin,
    [Parameter(Mandatory=$false)]
    [bool]$UseResourceEncryption = $True,
    [Parameter(Mandatory=$false)]
    [ValidateSet('Debug','Release')]
    [string]$Configuration='Release'
) 
    
$BuildFunctions = "$PSScriptRoot\scripts\BuildFunctions.ps1"
. "$BuildFunctions"

$InstalledFrameworks = Get-Frameworks
if($($InstalledFrameworks.Count) -eq 0){
    throw "Microsoft .NET Frameworks NOT FOUND!`nThis script requires a Microsoft (R) .NET Framework."
}

$LatestFramework = Get-Frameworks -Latest

################################################################################################
# BUILDING CS CODE, OUTPUTING DLL and EXE
################################################################################################
Write-Output "`n`n"
Write-Output "#######################################"
Write-Output "             COMPILATION               "
Write-Output "#######################################"
$BinPath = Build-Script -ScriptPath "$ScriptPath" -OutputDir "$OutputDir" -IconPath "$IconPath" -GUI:$GUI -Admin:$Admin -Configuration "$Configuration" -UseResourceEncryption:$UseResourceEncryption

################################################################################################
# ILMERGE => MERGE DLL and EXE in EXE
################################################################################################
Write-Output "`n`n"
Write-Output "#######################################"
Write-Output "              ILMerge                  "
Write-Output "#######################################"
Write-Output "`n`n"
Write-Output "BinPath $BinPath"
Write-Output "Using Framework version $($LatestFramework.Name)"
Write-Output "Framework Path =>     `"$($LatestFramework.Path)`""
Invoke-ILMerge -InputDir "$BinPath" -OutputDir "$OutputDir" -GUI:$GUI
start-sleep 2
################################################################################################
# OBFUSCATION of EXE
################################################################################################
Write-Output "`n`n"
Write-Output "#######################################"
Write-Output "             Confuser                  "
Write-Output "#######################################"
Write-Output "BinPath $BinPath"
Write-Output "OutputDir $OutputDir"
Invoke-Confuser -InputDir "$BinPath" -OutputDir "$OutputDir" -Preset none