
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
        $BaseXmlCfgEncoded = "H4sIAAAAAAAACpWPSwoDIRAF90LuIH2AcR/UVQ6QKxinJxr80bbg8TNMvEB29aAoeLpR/aBnWQe3wY9IBkC+XMeFM6fSDQTmdlfK13KMjrT5umNLOE/IYIWUmkZC2RwzUjHANBBkLAEpsoHDpX5udZm57ssNBp5U3+TyhhOvzl8l9UtZodX6YW9CfAESi9Sj1AAAAA=="   #$BaseXmlCfgEncoded = "H4sIAAAAAAAACqXQOwrDMBAE0F6QO4g9gNUHyRBImSKkSS3ba6ygz7JagY8f47hME9LNwPCKscTlhaPo0oSaXAM7AD34ikdcU8zVwSJCZ2PGkudWkbuxTEgR1y0k6JXWlltETV4EOTsQbgg65AU5iIPZx7p1sy9TmY7t4uBeHy1n5AtRhyvu1k+a+XDf5Cd7IuRbGLopxj9oa46b+pNSb7gc24MzAQAA"
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
            $BaseXmlCfg.project.module.rule.inherit = "true"
            $BaseXmlCfg.project.module.rule.SetAttribute("preset","$Preset")
           
        }else{
            $BaseXmlCfg.project.module.rule.inherit = "true"
            
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



function Get-Frameworks{
    [CmdletBinding(SupportsShouldProcess)]
    Param() 

    Try{
        $FrameWorks = @()
        $Dirs = Get-ChildItem "C:\Windows\Microsoft.NET\Framework64" -Dir -Filter "v*"
        ForEach($d in $Dirs){
            $Name = $d.Name
            $Fullname = $d.Fullname
            $Name = $Name.Replace('v','')
            $Name = $Name.SubString(0,3)
            $o = [PsCustomObject]@{
                Name = $Name
                Path = $Fullname
            }
            $FrameWorks += $o  
        }
        $FrameWorks

    }catch{
        Write-Error $_ 
    }

}

function Invoke-ILMerge{
    [CmdletBinding(SupportsShouldProcess=$true,DefaultParameterSetName="Flex")]
    param(
        [parameter(position = 0)]
        [ValidateScript({
            [string[]]$ns = (Get-Frameworks).Name

            if(-Not ($ns.Contains("$_")) ){
                throw "Invalid Framework"
            }
            
            return $true 
        })]
        [ArgumentCompleter( {
            param($Command, $Parameter, $WordToComplete, $CommandAst, $FakeBoundParams)
            switch ($Parameter) {
                'Framework' {
                    if ([string]::IsNullOrEmpty($WordToComplete)) {

                        (Get-Frameworks).Name -replace '(.*\s.*)',"'`$1'"
                    }
                    else {
                        (Get-Frameworks).Name -replace '(.*\s.*)',"'`$1'" | Where-Object { $_.StartsWith($WordToComplete) }
                    }
                }
                Default {
                }
            }
        })]
        [string]$Framework = '4.0'
    ) 

    try {
        $TargetDef = ""
        if($GUI){
            $TargetDef = "/target:winexe"
        }else{
            $TargetDef = "/target:exe"
        }
        $ILMergePath = "$PSScriptRoot\ILMerge"
        $ILMergeExePath = "$ILMergePath\ILMerge.exe"
        $Basename = (Get-Item "$ScriptPath").Basename
        $MergedExe = "$InputDir\{0}.exe" -f "Program"

        $f = Get-Frameworks | Where Name -eq $Framework
        $n = $f.Name
        $p = $f.Path
        $tp = "/targetplatform:$n,`"$p`""

        $DllPath = (Get-ChildItem -Path $InputDir -File -Filter "*.dll").Fullname
        $ExePath = (Get-ChildItem -Path $InputDir -File -Filter "*.exe").Fullname
        $ArgsList = @("$TargetDef","/ndebug", "/copyattrs","$tp", "/out:$MergedExe" ,"$ExePath" ,"$DllPath")
        Start-Process -FilePath $ILMergeExePath -ArgumentList $ArgsList -NoNewWindow -Wait
        $Null = Remove-Item -Path $DllPath -Force -ErrorAction Ignore
        $Null = Remove-Item -Path $ExePath -Force -ErrorAction Ignore

    }catch { 
        #$formatstring = "ERROR: {0}`n{1}"
        $formatstring = "ERROR: {0}"
        $fields = $_.FullyQualifiedErrorId,$_.Exception.ToString()
        $ExceptMsg=($formatstring -f $fields)
        Write-Output $ExceptMsg
    }
}



################################################################################################
# BUILDING CS CODE, OUTPUTING DLL and EXE
################################################################################################

$BinPath = Build-Script -ScriptPath "$ScriptPath" -IconPath "$IconPath" -GUI:$GUI -Admin:$Admin -Configuration "$Configuration" -UseResourceEncryption:$UseResourceEncryption

################################################################################################
# ILMERGE => MERGE DLL and EXE in EXE
################################################################################################

Invoke-ILMerge -InputDir "$BinPath" -GUI:$GUI

################################################################################################
# OBFUSCATION of EXE
################################################################################################

Invoke-Confuser -InputDir "$BinPath" -OutputDir "$OutputDir" -Preset none