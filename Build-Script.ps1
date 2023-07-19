
<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$ScriptPath,
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "$PSScriptRoot\out",
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
    

function Convert-FromBase64CompressedScriptBlock {

    [CmdletBinding()] param(
        [String]
        $ScriptBlock
    )

    # Base64 to Byte array of compressed data
    $ScriptBlockCompressed = [System.Convert]::FromBase64String($ScriptBlock)

    # Decompress data
    $InputStream = New-Object System.IO.MemoryStream(, $ScriptBlockCompressed)
    $MemoryStream = New-Object System.IO.MemoryStream
    $GzipStream = New-Object System.IO.Compression.GzipStream $InputStream, ([System.IO.Compression.CompressionMode]::Decompress)
    $GzipStream.CopyTo($MemoryStream)
    $GzipStream.Close()
    $MemoryStream.Close()
    $InputStream.Close()
    [Byte[]] $ScriptBlockEncoded = $MemoryStream.ToArray()

    # Byte array to String
    [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8
    $Encoding.GetString($ScriptBlockEncoded) | Out-String
}

function Invoke-EncryptScriptToResource {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$ScriptPath,
        [Parameter(Position=1, Mandatory=$true)]
        [string]$BinaryFilePath
    )
        $PlainText = Get-Content "$ScriptPath" -Raw -Encoding UTF8
        $CipherData = $PlainText | ConvertTo-SecureString -AsPlainText -Force
        $CipherText =  ConvertFrom-SecureString -key (1..16) -SecureString $CipherData
        [byte[]]$cipherBytes = [System.Text.Encoding]::UTF8.GetBytes($CipherText)
        if($PSVersionTable.PSEdition -eq 'Core'){
            Set-Content "$BinaryFilePath" -Value $cipherBytes -AsByteStream -Force
        }else{
            Set-Content "$BinaryFilePath" -Value $cipherBytes -Encoding Byte -Force
        }
}


function Get-CscExe{
    [CmdletBinding(SupportsShouldProcess)]
    param() 
    try{
     
        $Cmd = Get-Command 'csc.exe' -ErrorAction Ignore 
        if($Cmd -ne $Null){
            $Path = $Cmd.Source 
            return $Path
        }

        [string[]]$Files = Get-ChildItem -Path "C:\Windows\Microsoft.NET" -Depth 2 -Filter "csc.exe" -ErrorAction Ignore
        if($Files.Count -gt 0){
            $Path = $Files[$Files.Count-1] 
            return $Path
        }
        return $Null
    }catch{
        Write-Error $_
    }
}


################################################################################################
# FILES CONTENT, ENCODED AND COMPRESSED
################################################################################################

$BaseDll_Console = "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"
$BaseDll_GUI = "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"
$Program = "H4sIAAAAAAAACu1XbW/bNhD+HiD/gfOXSKinImmBDQjyIbNdx0hSG5bbdG0Kg5YuNlGK1Egqtjv0v+8oS5b1YifLvmzA5BiOjnfPPfdCHZVoJubEX2sD0fnxUbJz63Uk5xAYJoX2+iBAsaCqcsPEH1XZBFamJlsooCEKvAnV3/R2+VaGCYf3NAI/pgEUchYoqeWD8e6YeHNWhRsnwrAIvIEwoGTsg3pkAeiqGtqGcqlztXp8USwFCIMsgFdXu9TQmkzRJd6i2H4E0taWNhlpZIQJuozj46M/j48IXgGnWpORknNFo40oW7HXly7nA3SvjNP6oEG9OfNCzlvu10JFG2pYQDCboATBGEZGkT6YbsfJbhZLEbopmRfDMmHIGDhQDWXcdu4xDPa7mIfsWR4sa7Al6tBYb72EQTtdFQMRwqrsJcN4lCxEfhpMB7tQcrgToQ/GYBG04xbqO5ndWCtbNRrHI2oW5CKv32DoWQF2s+kyhb0t1do2n5P3FTxkHe9dag3RjK+tbm8FQWJ95kLH9W5kgAylsLQbXOMPWr1jHMoMXuCh2YGCeU8YtUbosi90EXNsSufk/v6kTU6mJ+5eBIb/rn/D2mckW1mWW4ctKtr39y3yakuoYjrObK5hTb7h92Ir8TqJUrj7bJ96wxiEn8xQy6nyahOjEnAP4OrUEKHRQQUppdSMwB6Ik1n+dEFEwvlOQzU0lb1evyaki9vFgCbU+rUhURHid02CBeNhJtSYjyBRmj0CVpiYBZAzq6bmSYQxE6aJkYTNhVRAQCmpNJGCREynzxuLUPduw9t43wQ4UQA7QT5QrmtR/ihuf+zbYFcshGJ//b+v/q37qmycPUZjxSKa8t2dDd5nnHi1jsfG6/b868lw9LE3nox7Plqdnv6yX+1qOP6cq/3aoEYDk1A+Yivg+lNGoXjQZ9TaFTT3CaDfnwTK2NefCeVBliahnWeoPGByx7FMiZcD+Zm8PW9UtdTKVOuqWVEXsPpIeQIW3TrxJtJPV5zWp7ct97CR9WPd1Y0azZbpQcdn3+EKVmhawLwqeDREVNh1IcAkcbRFOQ5JpcEpobbzCdbnckY5+57OJu99Es1A+WbNQXuotrmvE83SfFohkaW0Kv57uftHSRtJ/ZKcodn+lG0wX5Cx/+DovHju6Cx56uDrQD7FnvC1M8AKGA8PgWmFnNbdtktb7Vpx2ttgU+1rXPa6d1Klx+ZnwCISs1XbQu/slYPYz5i6A4HQti8AXxsODN2ZlBzPC/2E9QSdcQgxh9PpaDzsjy9vp/0Pg+m7m8v+dFqJqLiqtXN2wdyGUlXPA9WK4IMPGsz2ntPPD1a0kqrmZN1SJpzNxv3y1R6j9P6EVRKL3svrFgtXCB7ijP3FDoZlLq2xLd9lNp5vKL4ApTx29LPI8Af/jv4CEXR6fFwPAAA="
$WinManifest = "H4sIAAAAAAAACo2QT2vDMAzF74V9B6N7mnW7jFKvlM5jhbCW0ZbdjOconcF/mOWE5tvPCaz0sEMvQhK833vSYnl2lnUYyQTPYTa9B4Zeh9r4E4fD/rV4AkZJ+VrZ4JFDjwTL57vJQhGh+7I9ywBPHNro56S/0SkqnNExUGhSoYObK3LTbgbMKW8apHS8dhtQKbaUNr4JN7IeRhWhbqNJ/dBH/GkzGetdNJ2xeEK6kfU4si56cc7UlNNV2KFldqgcpNxVq7V421Yv4kOKT7E+7Dfbd1mJo6ikBNaaldZI2a5RlhDKAVr+k2rcXycvL8eP099X8zD5BcQ7/AecAQAA"


function Build-Script{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$ScriptPath,
        [Parameter(Mandatory=$false)]
        [string]$OutputDir = "$PSScriptRoot\out",
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

    $Null = Remove-Item -Path $OutputDir -Recurse -Force -ErrorAction Ignore
    $Null = New-Item -Path $OutputDir -ItemType directory -Force -ErrorAction Ignore

    $DebugCfg = $Configuration -eq 'Debug'
    $ReleaseCfg = $Configuration -eq 'Release'
    $RootPath = "$PSScriptRoot\obj"
    $BinPath = "$PSScriptRoot\bin"
    $DbgLevel = ""
    if($ReleaseCfg){
        $DbgLevel = "/o+"
        $BinPath = "$BinPath\Release"
    }else{
        $DbgLevel = "/debug:full"
        $BinPath = "$BinPath\Debug"
    }
    $DllBin = "$BinPath\PsWrapperLib.dll"
    $AppBin = "$BinPath\PsRunnerApp.exe"
    $DllSource = "$RootPath\PsWrapperLib.cs"
    $ManifestSource = "$RootPath\PsRunnerApp.win32manifest"
    $AppSource = "$RootPath\PsRunnerApp.cs"
    $PackagedTemplates = "$RootPath\cs.zip"
    $AutomationRef = "$PSScriptRoot\References\System.Management.Automation.dll"
    $PresentationFrameworkRef = "$PSScriptRoot\References\PresentationFramework.dll"
    $ScriptRes = "$RootPath\logic.bin"

    try {
        $ExecutionLevel = 'asInvoker'
        if($Admin){
            $ExecutionLevel = 'requireAdministrator'
        }
    	
        $Null = Remove-Item -Path $BinPath -Recurse -Force -ErrorAction Ignore
        $Null = Remove-Item -Path $RootPath -Recurse -Force -ErrorAction Ignore
    	$Null = New-Item -Path $RootPath -ItemType directory -Force -ErrorAction Ignore
        if(!(Test-Path "$BinPath")){
            $Null = New-Item -Path $BinPath -ItemType directory -Force -ErrorAction Ignore
        }

        $CscExe = Get-CscExe
        if([string]::IsNullOrEmpty($CscExe) -eq $True){
            throw "Microsoft (R) Visual C# Compiler NOT FOUND!`nThis compiler is provided as part of the Microsoft (R) .NET Framework."
        }
    	Convert-FromBase64CompressedScriptBlock -ScriptBlock $Program | Set-Content $AppSource
        Convert-FromBase64CompressedScriptBlock -ScriptBlock $WinManifest | Set-Content $ManifestSource
        if($GUI){
            Convert-FromBase64CompressedScriptBlock -ScriptBlock $BaseDll_GUI | Set-Content $DllSource
        }else{
            Convert-FromBase64CompressedScriptBlock -ScriptBlock $BaseDll_Console | Set-Content $DllSource
        }

        $EncryptedScriptResourceDef = ""
        if($UseResourceEncryption){
            $DllCode = Get-Content -Path "$DllSource" -Raw -Encoding UTF8
            $DllCode = $DllCode.Replace('__USE_ENCRYPTED_SCRIPT_RESOURCE_VALUE__', 'true')
            Invoke-EncryptScriptToResource -ScriptPath $ScriptPath -BinaryFilePath $ScriptRes
            Set-Content -Path "$DllSource" -Value "$DllCode" -Encoding UTF8 -ErrorAction Stop
            $EncryptedScriptResourceDef = "/res:$ScriptRes"
        }else{
            $DllCode = Get-Content -Path "$DllSource" -Raw -Encoding UTF8
            $DllCode = $DllCode.Replace('__USE_ENCRYPTED_SCRIPT_RESOURCE_VALUE__', 'false')
            $ScriptContent = Get-Content "$ScriptPath" -Raw -Encoding UTF8
            $ScriptContentBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($ScriptContent))
            $DllCode = $DllCode.Replace('__BASE64_ENCODED_SCRIPT_CODE__', $ScriptContentBase64)
            Set-Content -Path "$DllSource" -Value "$DllCode" -Encoding UTF8 -ErrorAction Stop
        }


        if($GUI){
            $ProgramCode = Get-Content -Path "$AppSource" -Raw -Encoding UTF8
            $ProgramCode = $ProgramCode.Replace('__PROGRAM_GUI_FLAG__', 'true')
            Set-Content -Path "$AppSource" -Value "$ProgramCode" -Encoding UTF8 -ErrorAction Stop
        }else{
            $ProgramCode = Get-Content -Path "$AppSource" -Raw -Encoding UTF8
            $ProgramCode = $ProgramCode.Replace('__PROGRAM_GUI_FLAG__', 'false')
            Set-Content -Path "$AppSource" -Value "$ProgramCode" -Encoding UTF8 -ErrorAction Stop
        }
        
        $IconDef = ""
        if([string]::IsNullOrEmpty($IconPath) -eq $False){
            $IconDef = "/win32icon:$IconPath"
        }

        $ManifestCode = Get-Content "$ManifestSource" -Raw -Encoding UTF8
        $ManifestCode = $ManifestCode.Replace('__PLACEHOLDER_EXECUTION_LEVEL__', $ExecutionLevel)
        Set-Content -Path "$ManifestSource" -Value "$ManifestCode" -Encoding UTF8 -ErrorAction Stop


        &"$CscExe" "/nologo" "/warn:0" "/target:library" "/reference:$AutomationRef" "$EncryptedScriptResourceDef" "$DbgLevel" "/out:$DllBin" "$DllSource"   

        &"$CscExe" "/nologo" "/warn:0" "/target:exe" "/reference:$DllBin" "/reference:$PresentationFrameworkRef" "/win32manifest:$ManifestSource" "$IconDef" "$DbgLevel" "/out:$AppBin" "$AppSource"   
    
        $Null = Remove-Item -Path $RootPath -Recurse -Force -ErrorAction Ignore

        if(( Test-Path "$AppBin") -And ( Test-Path "$DllBin") ){
            #Write-Output "[SUCCESS] `"$AppBin`""
            return "$BinPath"
        }else{
            throw "Failed to build `"$AppBin`""
        }
    }   
    catch { 
        #$formatstring = "ERROR: {0}`n{1}"
        $formatstring = "ERROR: {0}"
        $fields = $_.FullyQualifiedErrorId,$_.Exception.ToString()
        $ExceptMsg=($formatstring -f $fields)
        Write-Output $ExceptMsg
    }
}


function Invoke-Confuser{
    [CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName="Flex")]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$InputDir,
        [Parameter(Position=1, Mandatory=$true)]
        [string]$OutputDir,
        [Parameter(ParameterSetName="Preset",Mandatory=$false)]
        [ValidateSet('none','minimum','normal','aggressive','maximum')]
        [string]$Preset,
        [Parameter(ParameterSetName="Flex",Mandatory=$false, HelpMessage="Encode and Compress Constants in the Code")]
        [switch]$Constants,
        [Parameter(ParameterSetName="Flex",Mandatory=$false, HelpMessage="Encode and Compress Embedded Resources in the Code")]
        [switch]$Resources,
        [Parameter(ParameterSetName="Flex",Mandatory=$false, HelpMessage="Mangles the Code in methods so that it's less readable.")]
        [switch]$ControlFlow,
        [Parameter(ParameterSetName="Flex",Mandatory=$false, HelpMessage="Replace Types with Generics")]
        [switch]$TypeScrambler,
        [Parameter(ParameterSetName="Flex",Mandatory=$false, HelpMessage="Obfuscate the symbols names")]
        [switch]$Names,
        [Parameter(ParameterSetName="Flex",Mandatory=$false, HelpMessage="Adds Invalid Metadata")]
        [switch]$InvalidMetaData,
        [Parameter(ParameterSetName="Flex",Mandatory=$false, HelpMessage="Encodes and Hides references to types/methods")]
        [switch]$ReferencesProxy,
        [Parameter(ParameterSetName="Flex",Mandatory=$false, HelpMessage="Prevent Assembly from being Debugged")]
        [switch]$AntiDebug,
        [Parameter(ParameterSetName="Flex",Mandatory=$false, HelpMessage="Prevent Assembly from being Dumped")]
        [switch]$AntiDump,
        [Parameter(ParameterSetName="Flex",Mandatory=$false, HelpMessage="Ensure Application Integrity")]
        [switch]$AntiTamper,
        [Parameter(ParameterSetName="Flex",Mandatory=$false, HelpMessage="Mark Module with Attribute that...")]
        [switch]$AntiIlDasm,
        [Parameter(Mandatory=$false, HelpMessage="Compress")]
        [Parameter(ParameterSetName="Preset")]
        [Parameter(ParameterSetName="Flex")]
        [switch]$Compress
    ) 

    try {
        #$BaseXmlCfgEncoded = "H4sIAAAAAAAACpVPyw3DIAy9I3UH5AHCvQo5dYCuQInT0AK2jJEyfqM0HaC39/R+eiMLvTCqpa7c9ZbEA9hHaHjCreTaPKyqfHUuUl16QxkizcgZtx0UmIy1o/SMloMqSvWg0hFsqitKUg9LyG3n7nByiG8Um2YPe5oFWyP5iYXms2j1cBd6SigDbniM/DXjvlWTGd15croY8wG7U6QT8QAAAA=="
        $BaseXmlCfgEncoded = "H4sIAAAAAAAACqXQOwrDMBAE0F6QO4g9gNUHyRBImSKkSS3ba6ygz7JagY8f47hME9LNwPCKscTlhaPo0oSaXAM7AD34ikdcU8zVwSJCZ2PGkudWkbuxTEgR1y0k6JXWlltETV4EOTsQbgg65AU5iIPZx7p1sy9TmY7t4uBeHy1n5AtRhyvu1k+a+XDf5Cd7IuRbGLopxj9oa46b+pNSb7gc24MzAQAA"
        #$BaseXmlCfgEncoded = "H4sIAAAAAAAACqWQsQrDMAxE90D/wegD4r3EgULHDqVLZsdWiFvHFrIM+fwGEjp1Kd3u0N07UEecn+hE5SpU5RrYAKjRFjzkusRUDMwidNba5TTVgty67JEirptYoD81SnVcIyqyIsjJgHBFUCHNyEEMTDaWzes9Sta9kFXwBrY+MZaS+XNdsj9Qs4F7edSUkC9ELa64b/22pnfgV/jAlgj5FsbWx/gfvdPHM/vmDY/7LdxXAQAA"
        [xml]$BaseXmlCfg =( (Convert-FromBase64CompressedScriptBlock -ScriptBlock $BaseXmlCfgEncoded) -as [xml] )
        $ConfuserExPath = "$PSScriptRoot\ConfuserEx"
        $ILMergePath = "$PSScriptRoot\ILMerge"
        $ILMergeExePath = "$ILMergePath\ILMerge.exe"
        $ConfigPath = "$PSScriptRoot\tmp"
        $ConfigFilePath = "$PSScriptRoot\tmp\confuser.crproj"
        $Null = Remove-Item -Path $ConfigPath -Recurse -Force -ErrorAction Ignore
        $Null = New-Item -Path $ConfigPath -ItemType directory -Force -ErrorAction Ignore
        $ConfuserCLI = "$ConfuserExPath\Confuser.CLI.exe"
        $ConfigLevelFile = "$ConfigPath\{0}.crproj" -f $Level

        $BaseXmlCfg.project.baseDir = "$InputDir"
        $BaseXmlCfg.project.outputDir = "$OutputDir"

        if ($PSCmdlet.ParameterSetName -eq 'Preset') {
            #$BaseXmlCfg.project.rule.inherit = "true"
            #$BaseXmlCfg.project.rule.SetAttribute("preset","$Preset")
            $BaseXmlCfg.project.module[0].rule.inherit = "true"
            $BaseXmlCfg.project.module[0].rule.SetAttribute("preset","$Preset")
            $BaseXmlCfg.project.module[1].rule.inherit = "true"
            $BaseXmlCfg.project.module[1].rule.SetAttribute("preset","$Preset")
        }else{
            $BaseXmlCfg.project.module[0].rule.inherit = "true"
            $BaseXmlCfg.project.module[1].rule.inherit = "true"
            if($Constants){
                $child = $BaseXmlCfg.CreateElement("protection",$BaseXmlCfg.project.rule.NamespaceURI)
                $child.SetAttribute("id", "constants")
                $Null = $BaseXmlCfg.project.rule.AppendChild($child)
            }
            if($Resources){
                $child = $BaseXmlCfg.CreateElement("protection",$BaseXmlCfg.project.rule.NamespaceURI)
                $child.SetAttribute("id", "resources")
                $Null = $BaseXmlCfg.project.rule.AppendChild($child)
            }
            if($ControlFlow){
                $child = $BaseXmlCfg.CreateElement("protection",$BaseXmlCfg.project.rule.NamespaceURI)
                $child.SetAttribute("id", "ctrl flow")
                $Null = $BaseXmlCfg.project.rule.AppendChild($child)
            }
            if($TypeScrambler){
                $child = $BaseXmlCfg.CreateElement("protection",$BaseXmlCfg.project.rule.NamespaceURI)
                $child.SetAttribute("id", "typescramble")
                $BaseXmlCfg.project.rule.AppendChild($child)
            }
            if($Names){
                $child = $BaseXmlCfg.CreateElement("protection",$BaseXmlCfg.project.rule.NamespaceURI)
                $child.SetAttribute("id", "rename")
                $Null = $BaseXmlCfg.project.rule.AppendChild($child)
            }
            if($InvalidMetaData){
                $child = $BaseXmlCfg.CreateElement("protection",$BaseXmlCfg.project.rule.NamespaceURI)
                $child.SetAttribute("id", "invalid metadata")
                $Null = $BaseXmlCfg.project.rule.AppendChild($child)
            }
            if($AntiDebug){
                $child = $BaseXmlCfg.CreateElement("protection",$BaseXmlCfg.project.rule.NamespaceURI)
                $child.SetAttribute("id", "anti debug")
                $Null = $BaseXmlCfg.project.rule.AppendChild($child)
            }
            if($AntiDump){
                $child = $BaseXmlCfg.CreateElement("protection",$BaseXmlCfg.project.rule.NamespaceURI)
                $child.SetAttribute("id", "anti dump")
                $Null = $BaseXmlCfg.project.rule.AppendChild($child)
            }
            if($AntiTamper){
                $child = $BaseXmlCfg.CreateElement("protection",$BaseXmlCfg.project.rule.NamespaceURI)
                $child.SetAttribute("id", "anti tamper")
                $BaseXmlCfg.project.rule.AppendChild($child)
            }
            if($AntiIlDasm){
                $child = $BaseXmlCfg.CreateElement("protection",$BaseXmlCfg.project.rule.NamespaceURI)
                $child.SetAttribute("id", "anti ildasm")
                $Null = $BaseXmlCfg.project.rule.AppendChild($child)
            }
        }

        if($Compress){
            $child = $BaseXmlCfg.CreateElement("packer",$BaseXmlCfg.project.NamespaceURI)
            $child.SetAttribute("id", "compressor")
            $Null = $BaseXmlCfg.project.InsertAfter($child,$BaseXmlCfg.project.rule)
        }

        $Null = $BaseXmlCfg.Save($ConfigFilePath)

        &"$ConfuserCLI" "$ConfigFilePath"

        $Null = Remove-Item -Path $ConfigPath -Recurse -Force -ErrorAction Ignore
        $Null = Remove-Item -Path $InputDir -Recurse -Force -ErrorAction Ignore

    }catch { 
        #$formatstring = "ERROR: {0}`n{1}"
        $formatstring = "ERROR: {0}"
        $fields = $_.FullyQualifiedErrorId,$_.Exception.ToString()
        $ExceptMsg=($formatstring -f $fields)
        Write-Output $ExceptMsg
    }
}



$BinPath = Build-Script -ScriptPath "$ScriptPath" -IconPath "$IconPath" -GUI:$GUI -Admin:$Admin -Configuration "$Configuration" -UseResourceEncryption:$UseResourceEncryption
Start-Sleep 1

if($false){
    $TargetDef = ""
    if($GUI){
        $TargetDef = "/target:winexe"
    }else{
        $TargetDef = "/target:exe"
    }
    $ILMergePath = "$PSScriptRoot\ILMerge"
    $ILMergeExePath = "$ILMergePath\ILMerge.exe"
    $Basename = (Get-Item "$ScriptPath").Basename
    $MergedExe = "$BinPath\{0}.exe" -f "Program"
    $DllPath = (Get-ChildItem -Path $BinPath -File -Filter "*.dll").Fullname
    $ExePath = (Get-ChildItem -Path $BinPath -File -Filter "*.exe").Fullname
    Start-Process -FilePath $ILMergeExePath -ArgumentList @("$TargetDef","/out:$MergedExe" ,"$ExePath" ,"$DllPath") -NoNewWindow -Wait
    $Null = Remove-Item -Path $DllPath -Force -ErrorAction Ignore
    $Null = Remove-Item -Path $ExePath -Force -ErrorAction Ignore
}


Invoke-Confuser -InputDir "$BinPath" -OutputDir "$OutputDir" -ControlFlow -Constants -Resources -ReferencesProxy -AntiDebug