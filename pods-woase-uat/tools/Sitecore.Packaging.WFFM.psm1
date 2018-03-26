Import-Module "$PSScriptRoot\Sitecore.Cloud.Cmdlets.dll"

# public funcitons
Function Start-SitecoreAzureWFFMPackaging {
    <#
        .SYNOPSIS
        Using this command you can create Sitecore Azure WFFM Module web deploy packages

        .DESCRIPTION
        Creates valid Sitecore Azure WFFM Module web deploy packages for all SKU

        .PARAMETER WffmPath
        Path to the Sitecore's wffm module package zip file

        .PARAMETER ReportingWffmPath
        Path to the Sitecore's wffm reporting module package zip file

        .PARAMETER DestinationFolderPath
        Destination folder path which web deploy packages will be generated into

        .PARAMETER CargoPayloadFolderPath
        Path to the root folder containing cargo payloads (*.sccpl files)

        .PARAMETER ParameterXmlPath
        Path to the root folder containing MS Deploy xml files (parameters.xml)

        .EXAMPLE
        Start-WFFMAzurePackaging -WffmPath "D:\Sitecore\Modules\Web Forms for Marketers 8.2 rev. 161129.zip" -ReportingWffmPath "D:\Sitecore\Modules\Web Forms for Marketers Reporting 8.2 rev. 161129.zip" -DestinationFolderPath "D:\Work\WFFMPackaging\Wdps" -CargoPayloadFolderPath "D:\Project\Source\GitRepos\Cloud.Services.Provisioning.Data\Resources\WFFM 8.2.1\CargoPayloads" -ParameterXmlPath "D:\Project\Source\GitRepos\Cloud.Services.Provisioning.Data\Resources\WFFM 8.2.1\MsDeployXmls"
    #>

    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]
		[string]$WffmPath,
        [parameter(Mandatory=$false)]
		[string]$ReportingWffmPath,
        [parameter(Mandatory=$true)]
        [string]$DestinationFolderPath,
        [parameter(Mandatory=$true)]
        [string]$CargoPayloadFolderPath,
        [parameter(Mandatory=$true)]
        [string]$ParameterXmlPath
    )

    try {
        $cdCargoPayloadPath = "$CargoPayloadFolderPath\WFFM.Cloud.RoleSpecific_CD.sccpl"
        $prcCargoPayloadPath = "$CargoPayloadFolderPath\WFFM.Cloud.RoleSpecific_PRC.sccpl"
        $xdbSingleCargoPayloadPath = "$CargoPayloadFolderPath\WFFM.Cloud.Role_Specific_XDBSingle.sccpl"
        $repCargoPayloadPath = ""
        $captchaHandlersEmbedCargoPayloadPath = "$CargoPayloadFolderPath\WFFM.Cloud.Embed.CaptchaHandlers.sccpl"
        $singleEmbedCargoPayloadPath = "$CargoPayloadFolderPath\WFFM.Cloud.Embed.RoleSpecific_Single.sccpl"
        $cdEmbedCargoPayloadPath="$CargoPayloadFolderPath\WFFM.Cloud.Embed.RoleSpecific_CD.sccpl"
        $cmEmbedCargoPayloadPath="$CargoPayloadFolderPath\WFFM.Cloud.Embed.RoleSpecific_CM.sccpl"
        $cdWdpParametersXml = "$ParameterXmlPath\CD\parameters.xml"
        $prcWdpParametersXml = "$ParameterXmlPath\PRC\parameters.xml"
        $singleWdpParametersXml = "$ParameterXmlPath\Single\parameters.xml"
        $xdbSingleWdpParametersXml = "$ParameterXmlPath\XDBSingle\parameters.xml"

        if (!$ReportingWffmPath) {
            $ReportingWffmPath = $WffmPath
            $repCargoPayloadPath = "$CargoPayloadFolderPath\WFFM.Cloud.RoleSpecific_REP.sccpl"
            $singleEmbedCargoPayloadPath = $captchaHandlersEmbedCargoPayloadPath
            $cdEmbedCargoPayloadPath = $captchaHandlersEmbedCargoPayloadPath
            $cmEmbedCargoPayloadPath = $captchaHandlersEmbedCargoPayloadPath
            #XDBSingle
            $xdbSingleDestFolder = "$DestinationFolderPath\XDBSingle"
            CreateXDBSingleWffmWdps $xdbSingleDestFolder $WffmPath $xdbSingleWdpParametersXml $xdbSingleCargoPayloadPath
        }

        #XPSingle
        $xpSingleDestFolder = "$DestinationFolderPath\XPSingle"
        CreateSingleWffmWdps $xpSingleDestFolder  $WffmPath $singleEmbedCargoPayloadPath $singleWdpParametersXml

        #XP
        $xpDestFolder = "$DestinationFolderPath\XP"
        CreateCmWffmWdps $xpDestFolder $WffmPath $cmEmbedCargoPayloadPath
        CreateCdWffmWdps $xpDestFolder $WffmPath $cdCargoPayloadPath $cdEmbedCargoPayloadPath $cdWdpParametersXml
        CreatePrcWffmWdps $xpDestFolder $WffmPath $prcCargoPayloadPath $prcWdpParametersXml
        CreateRepWffmWdps $xpDestFolder $ReportingWffmPath $repCargoPayloadPath

        #XDB
        $xdbDestFolder = "$DestinationFolderPath\XDB"
        CreatePrcWffmWdps $xdbDestFolder $WffmPath $prcCargoPayloadPath $prcWdpParametersXml
        CreateRepWffmWdps $xdbDestFolder $ReportingWffmPath $repCargoPayloadPath
    }
    catch {
        Write-Host $_.Exception.Message
        Break
    }
}

# Export public functions
Export-ModuleMember -Function Start-SitecoreAzureWFFMPackaging

Function CreateCmWffmWdps  {
    param(
        [string]$DestFolder,
        [string]$PackageSource,
        [string]$EmbedCargoPayload
        )

        #Create the Wffm Wdp
        $wdpPath = ConvertTo-SCModuleWebDeployPackage -Path $PackageSource -Destination $DestFolder
        Update-SCWebDeployPackage -Path $wdpPath -EmbedCargoPayloadPath $EmbedCargoPayload

        #Rename the wdps to be CM specific
        Rename-Item $wdpPath ($wdpPath -replace ".scwdp.zip", "_cm.scwdp.zip")
}

Function CreateCdWffmWdps {
    param(
        [string]$DestFolder,
        [string]$PackageSource,
        [string]$CargoPayload,
        [string]$EmbedCargoPayload,
        [string]$WdpParametersXml
        )

        #Create the Wffm Wdp
        $wdpPath = ConvertTo-SCModuleWebDeployPackage -Path $PackageSource -Destination $DestFolder -Exclude "*.sql","*App_Data\poststeps\*"
        Update-SCWebDeployPackage -Path $wdpPath -EmbedCargoPayloadPath $EmbedCargoPayload
        Update-SCWebDeployPackage -Path $wdpPath -CargoPayloadPath $CargoPayload

        #Update the archive/parameters xmls
        Update-SCWebDeployPackage -Path $wdpPath -ParametersXmlPath $WdpParametersXml

        #Rename the wdps to be CD specific
        Rename-Item $wdpPath ($wdpPath -replace ".scwdp.zip", "_cd.scwdp.zip")
}

Function CreatePrcWffmWdps {
    param(
        [string]$DestFolder,
        [string]$PackageSource,
        [string]$CargoPayload,
        [string]$WdpParametersXml
        )

        #Create the Wffm Wdp
        $wdpPath = ConvertTo-SCModuleWebDeployPackage -Path $PackageSource -Destination $DestFolder -Exclude "core.sql","master.sql","*App_Data\poststeps\*"
        Update-SCWebDeployPackage -Path $wdpPath -CargoPayloadPath $CargoPayload

        #Update the archive/parameters xmls
        Update-SCWebDeployPackage -Path $wdpPath -ParametersXmlPath $WdpParametersXml

        #Rename the wdps to be PRC specific
        Rename-Item $wdpPath ($wdpPath -replace ".scwdp.zip", "_prc.scwdp.zip")
}

Function CreateRepWffmWdps {
    param(
        [string]$DestFolder,
        [string]$PackageSource,
        [string]$CargoPayload
        )

        #Create the Wffm Wdp
        $wdpPath = ConvertTo-SCModuleWebDeployPackage -Path $PackageSource -Destination $DestFolder -Exclude "core.sql","master.sql","*App_Data\poststeps\*"

        if ($CargoPayload) {
            Update-SCWebDeployPackage -Path $wdpPath -CargoPayloadPath $CargoPayload
        }

        #Rename the wdps to be REP specific
        Rename-Item $wdpPath ($wdpPath -replace ".scwdp.zip", "_rep.scwdp.zip")
}

Function CreateSingleWffmWdps {
    param(
        [string]$DestFolder,
        [string]$PackageSource,
        [string]$EmbedCargoPayload,
        [string]$ParametersXml
        )

        #Create the Wffm Wdp

        $wdpPath = ConvertTo-SCModuleWebDeployPackage -Path $PackageSource -Destination $DestFolder

        Update-SCWebDeployPackage -Path $wdpPath -EmbedCargoPayloadPath $EmbedCargoPayload

        #Update the archive/parameters xmls
        Update-SCWebDeployPackage -Path $wdpPath -ParametersXmlPath $ParametersXml

        #Rename the wdps to be Single specific
        Rename-Item $wdpPath ($wdpPath -replace ".scwdp.zip", "_single.scwdp.zip")
}

Function CreateXDBSingleWffmWdps {
    param(
        [string]$DestFolder,
        [string]$PackageSource,
        [string]$ParametersXml,
        [string]$CargoPayload
        )

        #Create the Wffm Wdp
        $wdpPath = ConvertTo-SCModuleWebDeployPackage -Path $PackageSource -Destination $DestFolder -Exclude "core.sql","master.sql","*App_Data\poststeps\*"
        Update-SCWebDeployPackage -Path $wdpPath -CargoPayloadPath $CargoPayload

        #Update the archive/parameters xmls
        Update-SCWebDeployPackage -Path $wdpPath -ParametersXmlPath $ParametersXml

        #Rename the wdps to be XDBSingle specific
        Rename-Item $wdpPath ($wdpPath -replace ".scwdp.zip", "_xdbsingle.scwdp.zip")
}