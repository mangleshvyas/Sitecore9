################################################################################################################
# Information:
#
#
#
#
#
#
#
#
#
#
#
#
#
###############################################################################################################

param(
	[parameter (Mandatory=$true)]
	[string] $Subscription,

	[parameter (Mandatory=$false)]
	[string] $WebEnvironment = "",

	[parameter (Mandatory=$false)]
	[string] $WebEnvironmentShort = "",

	[parameter (Mandatory=$false)]
	[string] $ClientName = "pods",

	[parameter (Mandatory=$false)]
	[string] $ResourceGroupPrefix = "",

	[parameter (Mandatory=$false)]
	[string] $ResourceGroup = "$ResourceGroupPrefix$ClientName-$WebEnvironmentShort-rg",

	[parameter (Mandatory=$false)]
	[string] $Location = "East US",

	[parameter (Mandatory=$false)]
	[string] $SitecoreDeploymentType = "single",

	[parameter (Mandatory=$false)]
	[string] $KeyVaultName = "$WebEnvironmentShort-$($ClientName)-vault",

	[parameter (Mandatory=$false)]
	[string] $KeyVaultResourceGroup = "$ClientName-keystore",

	[parameter (Mandatory=$false)]
	[string] $KeyVaultCertificate = "sitecore-certificate",

	[parameter (Mandatory=$false)]
	[string] $DeploymentResourceGroupName = "$ClientName-deploy-rg",

	[parameter (Mandatory=$false)]
	[string] $DeploymentStorageAccount = "$($ClientName)sitecoreartifacts",

	[parameter (Mandatory=$false)]
	[string] $DeploymentStorageAccountContainer = "sitecore9",

	[parameter (Mandatory=$false)]
	[string] $LicenseXmlBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/license/non_prod/license.xml",

	[parameter (Mandatory=$false)]
	[string] $CertificateBlobName = "certificates/$ClientName-$WebEnvironmentShort.pfx",

	[parameter (Mandatory=$false)]
	[switch] $Redeploy,

	######Single Packages######
	[parameter (Mandatory=$false)]
	[string] $SingleSitecorePackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/Sitecore 9.0.1 rev. 171219 (Cloud)_single.scwdp.zip",
	[parameter (Mandatory=$false)]
	[string] $SingleXConnectPackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/Sitecore 9.0.1 rev. 171219 (Cloud)_xp0xconnect.scwdp.zip"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = ".\.."
if(!([string]::IsNullOrEmpty($PSScriptRoot))) {
	$ProjectRoot = "$PSScriptRoot\.."
}

function Main {
	if ($WebEnvironment -eq '') {
		Write-Error "You must supply a valid Web Environment parameter. (Call this deployment script with override parameters)"
	}

	try {
		Import-Module "$ProjectRoot\Sitecore.AzureToolkit\tools\sitecore.cloud.cmdlets.psm1" -ErrorAction "Stop"
	}
	catch {
		Write-Error "Error loading Sitecore Azure Toolkit PSModule."
		return
	}

	try {
		$testLogin = Get-AzureRmResourceGroup
		Write-Host "Already logged in."
	}
	catch {
		Write-Host "No active Azure RM login found Logging in..."
		Login-AzureRmAccount -Subscription $Subscription
	}

	Write-Host "Setting subscription to $Subscription"
	Select-AzureRmSubscription -Subscription $Subscription | out-null

	EnsureTargetResourceGroupExists -ResourceGroup $ResourceGroup -Location $Location

	#Should probably find a better way, but this works out well.
	if($Redeploy) {
		$SingleSitecorePackageBlobUrl = $SingleSitecorePackageBlobUrl -replace "(Cloud)","(Cloud-NoDB)"
		$SingleXConnectPackageBlobUrl = $SingleXConnectPackageBlobUrl -replace "(Cloud)","(Cloud-NoDB)"
	}

	#SAS Tokens
	$sasToken = GenerateSasForStorageURI -StorageAccountName "$($DeploymentStorageAccount)" -ContainerName "$($DeploymentStorageAccountContainer)" -Permission "r"
	$uploadSasToken = GenerateSasForStorageURI -StorageAccountName "$($DeploymentStorageAccount)" -ContainerName "$($DeploymentStorageAccountContainer)" -Permission "rwdl"

	#Sitecore Packages
	$_singleMsDeployPackageUrl = "$SingleSitecorePackageBlobUrl$sasToken"
	$_xcSingleMsDeployPackageUrl = "$SingleXConnectPackageBlobUrl$sasToken"

	#License
	$sas_licenseUrl = "$LicenseXmlBlobUrl$sasToken"
	$licenseXml = (Invoke-WebRequest -Uri $sas_licenseUrl -UseBasicParsing -ContentType "text/plain").Content

	#Certificate
	$ReadContext = New-AzureStorageContext -StorageAccountName $DeploymentStorageAccount -SasToken $sasToken
	$certificateFromStorage = Get-AzureStorageBlob -Container $DeploymentStorageAccountContainer -Blob $CertificateBlobName -Context $ReadContext | Get-AzureStorageBlobContent -Force
	$certificateBlob = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Get-Item ".\$CertificateBlobName")))

	#Upload templates per environment
	$UploadContext = New-AzureStorageContext -StorageAccountName $DeploymentStorageAccount -SasToken $uploadSasToken
	$TemplateDirectoryPath = "$ProjectRoot\templates\$SitecoreDeploymentType"
	$directory = Get-Item -Path $TemplateDirectoryPath
	Write-Host "Clean 'template-deployments/$ResourceGroup' storage..."
	Get-AzureStorageBlob -Context $UploadContext -Container $DeploymentStorageAccountContainer -Blob "template-deployments/$ResourceGroup/*" | Remove-AzureStorageBlob
	Write-Host "Uploading templates to storage account..."
	Get-ChildItem "$TemplateDirectoryPath" -File -Recurse | ForEach-Object {
		$relativePath = ("$($_.FullName)" | Out-String).Replace("$($directory.FullName)","").Replace("\","/").Trim()
		$destinationPath = "template-deployments/$ResourceGroup/$SitecoreDeploymentType$relativePath"
		Write-Host "Uploading: $destinationPath"
		Set-AzureStorageBlobContent -File $_.FullName -Container $DeploymentStorageAccountContainer -Context $UploadContext -Blob "$destinationPath"
	}

	#Json
	$JsonParameterPath = "$ProjectRoot\parameters\$WebEnvironmentShort.parameters.json"
	$JsonTemplateURL = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/$DeploymentStorageAccountContainer/template-deployments/$ResourceGroup/$SitecoreDeploymentType/azuredeploy.json$sasToken"

	$Parameters = @{
	    "deploymentId" = $ResourceGroup
	    "licenseXml"= $licenseXml
	    "singleMsDeployPackageUrl" = $_singleMsDeployPackageUrl
	    "xcSingleMsDeployPackageUrl" = $_xcSingleMsDeployPackageUrl
	    "authCertificateBlob" = $certificateBlob
	    "templateLinkAccessToken" = $sasToken
	}

	#$Parameters | Format-List | Out-Host

	Start-SitecoreAzureDeployment -Name $ResourceGroup -Location $Location -ArmTemplateUrl $JsonTemplateURL -ArmParametersPath $JsonParameterPath -SetKeyValue $Parameters -Verbose
}

function EnsureTargetResourceGroupExists {
	Param(
		[parameter (Mandatory=$true)]
		[string] $ResourceGroup,

		[parameter (Mandatory=$true)]
		[string] $Location
	)
	try {
		Get-AzureRmResourceGroup -Name $ResourceGroup -Location $Location | out-null
		Write-Host "Resource Group '$ResourceGroup' already exists!"
	}
	catch {
		Write-Host "Resource Group does not exist. Creating resource group '$ResourceGroup'."
		New-AzureRmResourceGroup -Name $ResourceGroup -Location $Location
	}
}

#https://github.com/robhabraken/Sitecore-Azure-Scripts/blob/master/Scripts/00%20Functions/functions-module.psm1
function GenerateSasForStorageURI {
    param (
        $StorageAccountName,
        $ContainerName,
		$Permission
    )

    process {
        #Processes input string and, if it storage URI - tries to generate a short living (10 hours) SAS for it
        $storageAccount = Get-AzureRmStorageAccount | Where-Object {$_.StorageAccountName -eq $storageAccountName}
        if ($null -eq $storageAccount) {
            #could not get storage account :(
            return ""
        }

        $now = [System.DateTime]::Now
        #construct SAS token for a container
        $SAStokenQuery = New-AzureStorageContainerSASToken -Name $containerName -Context $storageAccount.Context -Permission $Permission -StartTime $now.AddHours(-1) -ExpiryTime $now.AddHours(10)
        return $SAStokenQuery
    }
}

Main
