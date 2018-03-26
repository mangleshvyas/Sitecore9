Import-Module "$PSScriptRoot\Sitecore.Cloud.Cmdlets.psm1"

# public funcitons
Function Start-SitecoreAzureExmPackaging {
    <#
        .SYNOPSIS
        Using this command you can create Sitecore Azure EXM Module web deploy packages

        .DESCRIPTION
        Creates valid Sitecore Azure EXM Module web deploy packages

        .PARAMETER SourceFolderPath
        Source folder path to the Sitecore's exm module package zip files

        .PARAMETER DestinationFolderPath
        Destination folder path which web deploy packages will be generated into

        .PARAMETER CargoPayloadFolderPath
        Root folder path which contain cargo payloads (*.sccpl files)
		
		.PARAMETER AdditionalWdpContentsFolderPath
        Root folder path which contain folders with additinal contents to Wdp

        .PARAMETER ParameterXmlPath
        Root folder path wich contain the msdeploy xml files (parameters.xml)

		.PARAMETER ConfigFilePath
        File path of SKU and Role config json files

        .EXAMPLE
		Start-SitecoreAzureExmPackaging -SourceFolderPath "D:\Sitecore\Modules\Email Experience Manager 3.5.0 rev. 170310" -DestinationFolderPath "D:\Work\EXM\WDPs" -CargoPayloadFolderPath "D:\Resources\EXM 3.5\CargoPayloads" -AdditionalWdpContentsFolderPath "D:\Work\EXM\AdditionalFiles" -ParameterXmlFolderPath "D:\Resources\EXM 3.5\MsDeployXmls" -ConfigFile "D:\Resources\EXM 3.5\Configs\EXM0.Packaging.config.json"
    #>

    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]
		[string]$SourceFolderPath,        
        [parameter(Mandatory=$true)]
        [string]$DestinationFolderPath,
        [parameter(Mandatory=$true)]
        [string]$CargoPayloadFolderPath,
		[parameter(Mandatory=$true)]
        [string]$AdditionalWdpContentsFolderPath,
        [parameter(Mandatory=$true)]
        [string]$ParameterXmlFolderPath,
		[parameter(Mandatory=$true)]
        [string]$ConfigFilePath
    )

    try {
        Start-SitecoreAzureModulePackaging -SourceFolderPath $SourceFolderPath -DestinationFolderPath "$DestinationFolderPath" -CargoPayloadFolderPath $CargoPayloadFolderPath -AdditionalWdpContentsFolderPath $AdditionalWdpContentsFolderPath -ParameterXmlFolderPath $ParameterXmlFolderPath -ConfigFilePath $ConfigFilePath
    }
    catch {
        Write-Host $_.Exception.Message
        Break 
    }
}

# Export public functions
Export-ModuleMember -Function Start-SitecoreAzureEXMPackaging

