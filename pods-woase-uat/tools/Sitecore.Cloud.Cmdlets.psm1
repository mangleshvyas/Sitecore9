if (Test-Path "$PSScriptRoot\Sitecore.Cloud.Cmdlets.dll") {
  Import-Module "$PSScriptRoot\Sitecore.Cloud.Cmdlets.dll"
}
elseif (Test-Path "$PSScriptRoot\bin\Sitecore.Cloud.Cmdlets.dll") {
  Import-Module "$PSScriptRoot\bin\Sitecore.Cloud.Cmdlets.dll"
}
else {
  throw "Failed to find Sitecore.Cloud.Cmdlets.dll, searched $PSScriptRoot and $PSScriptRoot\bin"
}

# public funcitons
Function Start-SitecoreAzureDeployment{
    <#
        .SYNOPSIS
        You can deploy a new Sitecore instance on Azure for a specific SKU

        .DESCRIPTION
        Deploys a new instance of Sitecore on Azure

        .PARAMETER location
        Standard Azure region (e.g.: North Europe)
        .PARAMETER Name
        Name of the deployment
        .PARAMETER ArmTemplateUrl
        Url to the ARM template
        .PARAMETER ArmTemplatePath
        Path to the ARM template
        .PARAMETER ArmParametersPath
        Path to the ARM template parameter
        .PARAMETER LicenseXmlPath
        Path to a valid Sitecore license
        .PARAMETER SetKeyValue
        This is a hash table, use to set the unique values for the deployment parameters in Arm Template Parameters Json

        .EXAMPLE
        Import-Module -Verbose .\Cloud.Services.Provisioning.SDK\tools\Sitecore.Cloud.Cmdlets.psm1
        $SetKeyValue = @{
        "deploymentId"="xP0-QA";
        "Sitecore.admin.password"="!qaz2wsx";
        "sqlserver.login"="xpsqladmin";
        "sqlserver.password"="Password12345";    "analytics.mongodb.connectionstring"="mongodb://17.54.72.145:27017/xP0-QA-analytics";
        "tracking.live.mongodb.connectionstring"="mongodb://17.54.72.145:27017/xP0-QA-tracking_live";
        "tracking.history.mongodb.connectionstring"="mongodb://17.54.72.145:27017/xP0-QA-tracking_history";
        "tracking.contact.mongodb.connectionstring"="mongodb://17.54.72.145:27017/xP0-QA-tracking_contact"
        }
        Start-SitecoreAzureDeployment -Name $SetKeyValue.deploymentId -Region "North Europe" -ArmTemplatePath "C:\dev\azure\xP0.Template.json" -ArmParametersPath "xP0.Template.params.json" -LicenseXmlPath "D:\xp0\license.xml" -SetKeyValue $SetKeyValue
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]
        [alias("Region")]
        [string]$Location,
        [parameter(Mandatory=$true)]
        [string]$Name,
        [parameter(ParameterSetName="Template URI", Mandatory=$true)]
        [string]$ArmTemplateUrl,
        [parameter(ParameterSetName="Template Path", Mandatory=$true)]
        [string]$ArmTemplatePath,
        [parameter(Mandatory=$true)]
        [string]$ArmParametersPath,
        [parameter(Mandatory=$true)]
        [string]$LicenseXmlPath,
        [hashtable]$SetKeyValue
    )

    try {
        Write-Host "Deployment Started..."

        if ([string]::IsNullOrEmpty($ArmTemplateUrl) -and [string]::IsNullOrEmpty($ArmTemplatePath)) {
            Write-Host "Either ArmTemplateUrl or ArmTemplatePath is required!"
            Break
        }

        if ($SetKeyValue -eq $null) {
            $SetKeyValue = @{}
        }

        # Set the Parameters in Arm Template Parameters Json
        $paramJson = Get-Content $ArmParametersPath -Raw | ConvertFrom-Json

        Write-Verbose "Setting ARM template parameters..."

        if ($paramJson."`$schema") {
            $paramJson = $paramJson.parameters
        }

        $SetKeyValue.Keys | % { 
            $paramJson | Add-Member -NotePropertyName $_ -NotePropertyValue @{ "value" = $SetKeyValue[$_] } -Force
        }

        # Read and Set the license.xml
        $licenseXml = Get-Content $LicenseXmlPath -Raw -Encoding UTF8
        $paramJson | Add-Member -NotePropertyName "licenseXml" -NotePropertyValue @{ "value" = "$licenseXml" } -Force

        # Save to a temporary file
        $paramJsonFile = "temp_$([System.IO.Path]::GetRandomFileName())"
        $paramJson | ConvertTo-Json -Depth 100 | Set-Content $paramJsonFile -Encoding UTF8

        Write-Verbose "ARM template parameters are set!"

        # Deploy Sitecore in given Location
        Write-Verbose "Deploying Sitecore Instace..."
        $notPresent = Get-AzureRmResourceGroup -Name $Name -ev notPresent -ea 0
        if (!$notPresent) {
            New-AzureRmResourceGroup -Name $Name -Location $Location -Tag @{ "provider" = "b51535c2-ab3e-4a68-95f8-e2e3c9a19299" }
        }
        else {
            Write-Verbose "Resource Group Already Exists."
        }

        if ([string]::IsNullOrEmpty($ArmTemplateUrl)) {
            $PSResGrpDeployment = New-AzureRmResourceGroupDeployment -Name $Name -ResourceGroupName $Name -TemplateFile $ArmTemplatePath -TemplateParameterFile $paramJsonFile
        }else{
            # Replace space character in the url, as it's not being replaced by the cmdlet itself
            $PSResGrpDeployment = New-AzureRmResourceGroupDeployment -Name $Name -ResourceGroupName $Name -TemplateUri ($ArmTemplateUrl -replace ' ', '%20') -TemplateParameterFile $paramJsonFile
        }
        $PSResGrpDeployment
    }
    catch {
        Write-Error $_.Exception.Message
        Break
    }
    finally {
      if ($paramJsonFile) {
        Remove-Item $paramJsonFile
      }
    }
}

Function Start-SitecoreAzurePackaging{
    <#
        .SYNOPSIS
        Using this command you can create SKU specific Sitecore Azure web deploy packages

        .DESCRIPTION
        Creates valid Azure web deploy packages for SKU specfied in the sku configuration file

        .PARAMETER sitecorePath
        Path to the Sitecore's zip file
        .PARAMETER destinationFolderPath
        Destination folder path which web deploy packages will be generated into
        .PARAMETER cargoPayloadFolderPath
        Path to the root folder containing cargo payloads (*.sccpl files)
        .PARAMETER commonConfigPath
        Path to the common.packaging.config.json file
        .PARAMETER skuConfigPath
        Path to the sku specific config file (e.g.: xp1.packaging.config.json)
        .PARAMETER parameterXmlPath
        Path to the root folder containing MS Deploy xml files (parameters.xml)
        .PARAMETER fileVersion
        Generates a text file called version.txt, containing value passed to this parameter and puts it in the webdeploy package for traceability purposes - this parameter is optional

        .EXAMPLE
        Start-SitecoreAzurePackaging -sitecorePath "C:\Sitecore\Sitecore 8.2 rev. 161103.zip" ` -destinationPath .\xp1 `
        -cargoPayloadFolderPath .\Cloud.Services.Provisioning.SDK\tools\CargoPayloads `
        -commonConfigPath .\Cloud.Services.Provisioning.SDK\tools\Configs\common.packaging.config.json `
        -skuConfigPath .\Cloud.Services.Provisioning.SDK\tools\Configs\xp1.packaging.config.json `
        -parameterXmlPath .\Cloud.Services.Provisioning.SDK\tools\MSDeployXmls
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]
        [string]$SitecorePath,
        [parameter(Mandatory=$true)]
        [string]$DestinationFolderPath,
        [parameter(Mandatory=$true)]
        [string]$CargoPayloadFolderPath,
        [parameter(Mandatory=$true)]
        [string]$CommonConfigPath,
        [parameter(Mandatory=$true)]
        [string]$SkuConfigPath,
        [parameter(Mandatory=$true)]
        [string]$ParameterXmlPath,
        [parameter(Mandatory=$false)]
        [string]$FileVersion
    )

    try {

        $DestinationFolderPath = AddTailBackSlashToPathIfNotExists($DestinationFolderPath)
        $cargoPayloadFolderPath = AddTailBackSlashToPathIfNotExists($CargoPayloadFolderPath)
        $ParameterXmlPath = AddTailBackSlashToPathIfNotExists($ParameterXmlPath)

        # Create the Raw Web Deploy Package
        Write-Verbose "Creating the Raw Web Deploy Package..."
        if ($FileVersion -eq $null) {
            $sitecoreWebDeployPackagePath = New-SCWebDeployPackage -Path $SitecorePath -Destination $DestinationFolderPath
        }
        else {
            $sitecoreWebDeployPackagePath = New-SCWebDeployPackage -Path $SitecorePath -Destination $DestinationFolderPath -FileVersion $FileVersion -Force
        }
        Write-Verbose "Raw Web Deploy Package Created Successfully!"

        # Read and Apply the common Configs
        $commonConfigs = (Get-Content $CommonConfigPath -Raw) | ConvertFrom-Json
        $commonSccplPaths = @()
        foreach($sccpl in $commonConfigs.sccpls)
        {
            $commonSccplPaths += $CargoPayloadFolderPath + $sccpl;
        }

        Write-Verbose "Applying Common Cloud Configurations..."
        Update-SCWebDeployPackage -Path $sitecoreWebDeployPackagePath -CargoPayloadPath $commonSccplPaths
        Write-Verbose "Common Cloud Configurations Applied Successfully!"

        # Read the SKU Configs
        $skuconfigs = (Get-Content $SkuConfigPath -Raw) | ConvertFrom-Json
        foreach($scwdp in $skuconfigs.scwdps)
        {
            # Create the role specific scwdps
            $roleScwdpPath =  $sitecoreWebDeployPackagePath -replace ".scwdp", ("_" + $scwdp.role + ".scwdp")
            Copy-Item $sitecoreWebDeployPackagePath $roleScwdpPath -Verbose

            # Apply the role specific cargopayloads
            $sccplPaths = @()
            foreach($sccpl in $scwdp.sccpls)
            {
                $sccplPaths += $CargoPayloadFolderPath + $sccpl;
            }
            if ($sccplPaths.Length -gt 0) {
                Write-Verbose "Applying $($scwdp.role) Role Specific Configurations..."
                Update-SCWebDeployPackage -Path $roleScwdpPath -CargoPayloadPath $sccplPaths
                Write-Verbose "$($scwdp.role) Role Specific Configurations Applied Successfully!"
            }

            # Set the role specific parameters.xml and archive.xml
            Write-Verbose "Setting $($scwdp.role) Role Specific Web Deploy Package Parameters XML and Generating Archive XML..."
            Update-SCWebDeployPackage -Path $roleScwdpPath -ParametersXmlPath ($ParameterXmlPath + $scwdp.parametersXml)
            Write-Verbose "$($scwdp.role) Role Specific Web Deploy Package Parameters and Archive XML Added Successfully!"
        }

        # Remove the Raw Web Deploy Package
        Remove-Item -Path $sitecoreWebDeployPackagePath
    }
    catch {
        Write-Host $_.Exception.Message
        Break
    }
}

Function Start-SitecoreAzureModulePackaging {
    <#
        .SYNOPSIS
        Using this command you can create Sitecore Azure Module web deploy packages

        .DESCRIPTION
        Creates valid Sitecore Azure Module web deploy packages

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
		Start-SitecoreAzureModulePackaging -SourceFolderPath "D:\Sitecore\Modules\Email Experience Manager 3.5.0 rev. 170310" -DestinationFolderPath "D:\Work\EXM\WDPs" -CargoPayloadFolderPath "D:\Resources\EXM 3.5\CargoPayloads" -AdditionalWdpContentsFolderPath "D:\Work\EXM\AdditionalFiles" -ParameterXmlFolderPath "D:\Resources\EXM 3.5\MsDeployXmls" -ConfigFile "D:\Resources\EXM 3.5\Configs\EXM0.Packaging.config.json"
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

    # Read the role config
    $skuconfigs = (Get-Content $ConfigFilePath -Raw) | ConvertFrom-Json
    ForEach($scwdp in $skuconfigs.scwdps) {

        # Find source package path
        Get-ChildItem $SourceFolderPath | Where-Object { $_.Name -match $scwdp.sourcePackagePattern } |
        Foreach-Object {
            $packagePath = $_.FullName
        }

        # Create the Wdp
        $wdpPath = ConvertTo-SCModuleWebDeployPackage -Path $packagePath -Destination $DestinationFolderPath

        # Apply the Cargo Payloads
        ForEach($sccpl in $scwdp.sccpls) {
            $cargoPayloadPath = $sccpl
            Update-SCWebDeployPackage -Path $wdpPath -CargoPayloadPath "$CargoPayloadFolderPath\$cargoPayloadPath"
        }

        # Embed the Cargo Payloads
        ForEach($embedSccpl in $scwdp.embedSccpls) {
            $embedCargoPayloadPath = $embedSccpl
            Update-SCWebDeployPackage -Path $wdpPath -EmbedCargoPayloadPath "$CargoPayloadFolderPath\$embedCargoPayloadPath"
        }

		# Add additional Contents To Wdp from given Folders
		ForEach($additionalContentFolder in $scwdp.additionalWdpContentsFolders) {
			$additionalContentsFolderPath = $additionalContentFolder
			Update-SCWebDeployPackage -Path $wdpPath -SourcePath "$AdditionalWdpContentsFolderPath\$additionalContentsFolderPath"
		}

		# Update the ParametersXml
		if($scwdp.parametersXml) {
			$parametersXml = $scwdp.parametersXml
			Update-SCWebDeployPackage -Path $wdpPath -ParametersXmlPath "$ParameterXmlFolderPath\$parametersXml"
		}

        # Rename the Wdp to be more role specific
        $role = $scwdp.role
        Rename-Item $wdpPath ($wdpPath -replace ".scwdp.zip", "_$role.scwdp.zip")
    }
}

Function ConvertTo-SitecoreWebDeployPackage {
    <#
        .SYNOPSIS
        Using this command, you can convert a Sitecore package to a web deploy package

        .DESCRIPTION
        Creates a new webdeploypackage from the Sitecore package passed to it

        .PARAMETER Path
        Path to the Sitecore installer package
        .PARAMETER Destination
        Destination folder that web deploy package will be created into - optional parameter, if not passed will use the current location
        .PARAMETER Force
        If set, will overwrite existing web deploy package with the same name

        .EXAMPLE
        ConvertTo-SitecoreWebDeployPackage -Path "C:\Sitecore\Modules\Web Forms for Marketers 8.2 rev. 160801.zip" -Force

        .REMARKS
        Currently, this CmdLet creates a webdeploy package only from "files" folder of the package
    #>
    param(
    [parameter(Mandatory=$true)]
    [string]$Path,
    [parameter()]
    [string]$Destination,
    [parameter()]
    [switch]$Force
    )

    if(!$Destination -or $Destination -eq "") {
        $Destination = (Get-Location).Path
    }

    if($Force) {
        return ConvertTo-SCWebDeployPackage -PSPath $Path -Destination $Destination -Force
    } else {
        return ConvertTo-SCWebDeployPackage -PSPath $Path -Destination $Destination
    }
}

Function Set-SitecoreAzureTemplates {
    <#
        .SYNOPSIS
        Using this command you can upload Sitecore ARM templates to an Azure Storage

        .DESCRIPTION
        Uploads all the ARM Templates files in the given folder and the sub folders to given Azure Storage in the same folder hiherachy

        .PARAMETER Path
        Path to the Sitecore ARM Templates folder
        .PARAMETER StorageContainerName
        Name of the target container in the Azure Storage Account
        .PARAMETER AzureStorageContext
        Azure Storage Context object returned by New-AzureStorageContext
        .PARAMETER StorageConnectionString
        Connection string of the target Azure Storage Account
        .PARAMETER Force
        If set, will overwrite existing templates with the same name in the target container

        .EXAMPLE
        $StorageContext = New-AzureStorageContext -StorageAccountName "samplestorageaccount" -StorageAccountKey "3pQEA23emk0aio2RK6luL0MfP2P81lg9JEo4gHSEHkejL9+/9HCU4IjhsgAbcXnQz6j72B3Xq8TZZpwj4GI+Qw=="
        Set-SitecoreAzureTemplates -Path "D:\Work\UploadSitecoreTemplates\Templates" -StorageContainerName "samplecontainer" -AzureStorageContext $StorageContext
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$Path,
        [parameter(Mandatory=$true)]
        [string]$StorageContainerName,
        [parameter(ParameterSetName="context",Mandatory=$true)]
        [System.Object]$AzureStorageContext,
        [parameter(ParameterSetName="connstring",Mandatory=$true)]
        [string]$StorageConnectionString,
        [parameter()]
        [switch]$Force
    )

    if ([string]::IsNullOrEmpty($StorageConnectionString) -and ($AzureStorageContext -eq $null)) {
        Write-Host "Either StorageConnectionString or AzureStorageContext is required!"
        Break
    }

    if ($StorageConnectionString) {
        $AzureStorageContext = New-AzureStorageContext -ConnectionString $StorageConnectionString
    }

    $absolutePath = Resolve-Path -Path $Path
    $absolutePath = AddTailBackSlashToPathIfNotExists($absolutePath)

    $urlList = @()
    $files = Get-ChildItem $Path -Recurse -Filter "*.json"

    foreach($file in $files)
    {
        $localFile = $file.FullName
        $blobFile = $file.FullName.Replace($absolutePath, "")

        if ($Force) {
            $blobInfo = Set-AzureStorageBlobContent -File $localFile -Container $StorageContainerName -Blob $blobFile -Context $AzureStorageContext -Force
        } else{
            $blobInfo = Set-AzureStorageBlobContent -File $localFile -Container $StorageContainerName -Blob $blobFile -Context $AzureStorageContext
        }

        $urlList += $blobInfo.ICloudBlob.uri.AbsoluteUri
    }

    return ,$urlList
}

# Export public functions
Export-ModuleMember -Function Start-SitecoreAzureDeployment
Export-ModuleMember -Function Start-SitecoreAzurePackaging
Export-ModuleMember -Function Start-SitecoreAzureModulePackaging
Export-ModuleMember -Function ConvertTo-SitecoreWebDeployPackage
Export-ModuleMember -Function Set-SitecoreAzureTemplates
Export-ModuleMember -Cmdlet New-SCCargoPayload

# Internal functions
Function AddTailBackSlashToPathIfNotExists {
 param( [string]$Path)

    $Path = $Path.Trim()
    if (!$Path.EndsWith("\"))
    {
        $Path = $Path + "\"
    }

    return $Path
}
