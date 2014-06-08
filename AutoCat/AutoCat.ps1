

param (
    [string]$Path = "",
    [switch]$SkipReportTransform = $false
)

function WriteHeader
{
    write-host "    _____          __         _________         __   "
    write-host "   /  _  \  __ ___/  |_  ____ \_   ___ \_____ _/  |_ "
    write-host "  /  /_\  \|  |  \   __\/  _ \/    \  \/\__  \\   __\"
    write-host " /    |    \  |  /|  | (  <_> )     \____/ __ \|  |  "
    write-host " \____|__  /____/ |__|  \____/ \______  (____  /__|  "
    write-host "         \/                           \/     \/      "
    Write-Host ""
    write-host " AutoCat.ps1 - Recursive DLL scanning with CAT.NET"
    write-host " Ensure CAT.NET path is added to %PATH%!" -ForegroundColor Red
    write-host ""
}

if($Path -eq "")
{
    WriteHeader
    Write-host "USAGE: .\AutoCat.ps1 'PATH TO PROJECT' -SkipReportTransform (optional)"
    return
}
else
{
    WriteHeader
    $PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
    $ReportDir = $PSScriptRoot + "\reports\"
    #create the report DIR
    if(!(Test-Path $ReportDir))
    {
       New-Item -ItemType directory -Path $ReportDir | out-null
    }  
    $cat = "CATNetCmd.exe"
    
    #find all bin files
    Write-Host "[*] Analysing..." -ForegroundColor Yellow
    write-host ""
    $count = 0
    $duplicateCount = 0
    $AlreadyScanned = @()
    get-childitem $Path -recurse | where {$_.extension -eq ".dll"} | %{
         #calculate the hash of the current DLL
         $hash = Get-FileHash -Path $_.FullName -Algorithm MD5
         if(!$AlreadyScanned -contains $hash)
         {
            $AlreadyScanned +=$hash;
            $comand =  "catnetcmd /file:""" + $_.FullName + '"' +" /report:""" + $ReportDir  + $_.Name + ".xml"""
            #Write-Host $CatPath
            Write-Host ""
            write-host "[*] " $_.Name -ForegroundColor Yellow
            Write-Host ""
            Invoke-Expression -Command:$comand
            $count += 1
         }
         else
         {
            $duplicateCount += 1
         }
    }
    write-host ""
    Write-Host "[*] ANALYSIS COMPLETE" -ForegroundColor Green
    write-host "[*] "  $count  " files analysed"
    write-host "[*] "  $duplicateCount  " duplicate files skipped"
    write-host ""
    
    if(!$SkipReportTransform)
    {
        write-host "[*] Generating transformed reports" -ForegroundColor Yellow 
        write-host ""
        $xsl = "C:\Program Files (x86)\Microsoft\CAT.NET\Config\report.xsl"
        $xslt = new-object System.Xml.Xsl.XslCompiledTransform
        $settings = New-Object System.Xml.Xsl.XsltSettings($false, $true)
        $resolver = New-Object System.Xml.XmlUrlResolver
        $TransformDir = $ReportDir + "\transformed\"
        
        if(!(Test-Path $TransformDir))
        {
            New-Item -ItemType directory -Path $TransformDir | out-null
        }  

        get-childitem $ReportDir -recurse | where {$_.extension -eq ".xml"} | %{
            $OutPutFile = $TransformDir + $_.Name + ".html"
            $xslt.Load($xsl, $settings, $resolver)
            $xslt.Transform($_.FullName, $OutPutFile)    
        }
        write-host "[*] REPORT GENERATION COMPLETE" -ForegroundColor green 
    }
        
}



