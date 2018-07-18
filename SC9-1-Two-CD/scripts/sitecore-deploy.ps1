param(
	[parameter (Mandatory=$true)]
	[string] $Subscription,

	[parameter (Mandatory=$false)]
	[ValidateSet("Integration","QA","UAT","Production A","Production B")] 
	[string] $WebEnvironment = "",

	[parameter (Mandatory=$false)]
	[ValidateSet("int","qa","uat","proda","prodb")] 
	[string] $WebEnvironmentShort = "",

	[parameter (Mandatory=$false)]
	[string] $ClientName = "pods",

	[parameter (Mandatory=$false)]
	[string] $ResourceGroupPrefix = "",

	[parameter (Mandatory=$false)]
	[string] $ResourceGroup = "$ResourceGroupPrefix$ClientName-$WebEnvironmentShort-rg",

	[parameter (Mandatory=$false)]
	[ValidateSet("East US","West US","Central US")] 
	[string] $Location = "East US",

	[parameter (Mandatory=$false)]
	[ValidateSet("single","hybrid","scaled")] 
	[string] $SitecoreDeploymentType = "single",

	[parameter (Mandatory=$false)]
	[switch] $LockResourceGroup = $False,

	[parameter (Mandatory=$false)]
	[switch] $EnableCPUAlerts = $False,

	[parameter (Mandatory=$false)]
	[switch] $EnableMemoryAlerts = $False,

	[parameter (Mandatory=$false)]
	[switch] $EnableAdditionalAppAvailabilityAlerts = $False,

	[parameter (Mandatory=$false)]
	[switch] $EnableAppAvailabilityAlerts = $False,

	[parameter (Mandatory=$false)]
	[string] $KeyVaultName = "$WebEnvironmentShort-$($ClientName)-vault",

	[parameter (Mandatory=$false)]
	[string] $KeyVaultResourceGroup = "$ClientName-keystore",

	[parameter (Mandatory=$false)]
	[string] $KeyVaultCertificate = "sitecore-certificate",

	[parameter (Mandatory=$false)]
	[string] $DeploymentStorageAccount = "$($ClientName)sitecoreartifacts",

	[parameter (Mandatory=$false)]
	[string] $DeploymentStorageAccountContainer = "sitecore9",

	[parameter (Mandatory=$false)]
	[string] $LicenseXmlBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/license/license.xml",

	[parameter (Mandatory=$false)]
	[string] $CertificateBlobName = "certificates/$ClientName-$WebEnvironmentShort.pfx",
	
	######Single Packages######
	[parameter (Mandatory=$false)]
	[string] $SingleSitecorePackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/packages/single/Sitecore 9.0.1 rev. 171219 (Cloud)_single.scwdp.zip",
	[parameter (Mandatory=$false)]
	[string] $SingleXConnectPackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/packages/single/Sitecore 9.0.1 rev. 171219 (Cloud)_xp0xconnect.scwdp.zip",

	######Hybrid Packages######
	##TODO

	######Scaled Packages######
	[parameter (Mandatory=$false)]
	[string] $ScaledSitecoreCMPackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/packages/scaled/Sitecore 9.0.1 rev. 171219 (Cloud)_cm.scwdp.zip",
	[parameter (Mandatory=$false)]
	[string] $ScaledSitecoreCDPackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/packages/scaled/Sitecore 9.0.1 rev. 171219 (Cloud)_cd.scwdp.zip",
	[parameter (Mandatory=$false)]
	[string] $ScaledSitecoreProcPackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/packages/scaled/Sitecore 9.0.1 rev. 171219 (Cloud)_prc.scwdp.zip",
	[parameter (Mandatory=$false)]
	[string] $ScaledSitecoreRepPackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/packages/scaled/Sitecore 9.0.1 rev. 171219 (Cloud)_rep.scwdp.zip",
	[parameter (Mandatory=$false)]
	[string] $ScaledSitecoreDdsPackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/packages/scaled/Sitecore 9.0.1 rev. 171219 (Cloud)_dds.scwdp.zip",


	[parameter (Mandatory=$false)]
	[string] $ScaledXp1CollectionPackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/packages/scaled/Sitecore 9.0.1 rev. 171219 (Cloud)_xp1collection.scwdp.zip",
	[parameter (Mandatory=$false)]
	[string] $ScaledXp1CollectionSearchPackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/packages/scaled/Sitecore 9.0.1 rev. 171219 (Cloud)_xp1collectionsearch.scwdp.zip",
	[parameter (Mandatory=$false)]
	[string] $ScaledXp1MarketingAutomationPackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/packages/scaled/Sitecore 9.0.1 rev. 171219 (Cloud)_xp1marketingautomation.scwdp.zip",
	[parameter (Mandatory=$false)]
	[string] $ScaledXp1MarketingAutomationReportingPackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/packages/scaled/Sitecore 9.0.1 rev. 171219 (Cloud)_xp1marketingautomationreporting.scwdp.zip",
	[parameter (Mandatory=$false)]
	[string] $ScaledXp1ReferenceDataPackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/packages/scaled/Sitecore 9.0.1 rev. 171219 (Cloud)_xp1referencedata.scwdp.zip",
	[parameter (Mandatory=$false)]
	[string] $ScaledExmPatchPackageBlobUrl = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/sitecore9/packages/scaled/Sitecore.Patch.EXM (Cloud)_CM.zip"

)

$ErrorActionPreference = "Stop"
$ProjectRoot = ".\.."
if(!([string]::IsNullOrEmpty($PSScriptRoot))) {
	$ProjectRoot = "$PSScriptRoot\.."
}

function Main {
	Write-Host "Subscription: $Subscription"
	Write-Host "ResourceGroup: $ResourceGroup"
	Write-Host "Location: $Location"
	Write-Host "Deployment Type: $SitecoreDeploymentType"
	Write-Host "Lock Resource Group: $LockResourceGroup"
	Write-Host "Enable CPU Alerts: $EnableCPUAlerts"
	Write-Host "Enable Memory Alerts: $EnableMemoryAlerts"
	Write-Host "Enable App Availability Alerts: $EnableAppAvailabilityAlerts"
	Write-Host "Enable Additional App Availability Alerts: $EnableAdditionalAppAvailabilityAlerts"
	Write-Host "------------------"


	if ($WebEnvironment -eq '') {
		Write-Error "You must supply a valid Web Environment parameter. (Call this deployment script with override parameters)"
	}

	try {
		Import-Module "$ProjectRoot\Sitecore.AzureToolkit\tools\sitecore.cloud.cmdlets.psm1" -ErrorAction "Stop"
	}
	catch {
		Write-Error "Error loading Sitecore Azure Toolkit PSModule."
		exit 1
	}

	#Used later, but fail early in deployment if this path does not exist.
	$TemplateDirectoryPath = "$ProjectRoot/templates/$SitecoreDeploymentType"
	#Test if the deployment template path we are uploading exists.
	if(!(Test-Path "$TemplateDirectoryPath" -PathType Container)) {
		Write-Error "Template path does not exist: $TemplateDirectoryPath"
		exit 1
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

	$DeployInfrastructureOnly = [System.Convert]::ToBoolean((EnsureTargetResourceGroupExists -ResourceGroup $ResourceGroup -Location $Location)[-1])

	if($DeployInfrastructureOnly) {
		Write-Host "DeployInfrastructureOnly switch is set. Deploying infrastructure ONLY!" -ForegroundColor Red
	}

	#SAS Tokens
	Write-Host "Generating SAS token for accessing deployment storage account."
	$sasToken = GenerateSasForStorageURI -StorageAccountName "$($DeploymentStorageAccount)" -ContainerName "$($DeploymentStorageAccountContainer)"

	Write-Host "Creating new storage context using SAS token."
	$StorageContext = New-AzureStorageContext -StorageAccountName $DeploymentStorageAccount -SasToken $sasToken
	
	#License
	Write-Host "Getting license.xml content from storage account."
	$sas_licenseUrl = "$LicenseXmlBlobUrl$sasToken"
	$licenseXml = (Invoke-WebRequest -Uri $sas_licenseUrl -UseBasicParsing -ContentType "text/plain").Content

	#Certificate
	Write-Host "Retrieving certificate used for client authenication by Sitecore."
	$certificateFromStorage = Get-AzureStorageBlob -Container $DeploymentStorageAccountContainer -Blob $CertificateBlobName -Context $StorageContext | Get-AzureStorageBlobContent -Force
	Write-Host "Converting certificate to base64 string."
	$certificateBlob = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Get-Item ".\$CertificateBlobName")))


	#Upload templates per resource group (prevents conflicts between parallel cloud deployments)
	Write-Host "Uploading ARM templates to storage account."
	UploadTemplatesToStorage -StorageAccount $DeploymentStorageAccount -StorageAccountContainer $DeploymentStorageAccountContainer -TemplateDeploymentResourceGroup $ResourceGroup -TemplateDirectory $TemplateDirectoryPath
	$JsonParameterPath = "$ProjectRoot\parameters\$WebEnvironmentShort.parameters.json"

	$JsonTemplateURL = "https://$($ClientName)sitecoreartifacts.blob.core.windows.net/$DeploymentStorageAccountContainer/templates/$ResourceGroup/azuredeploy.json"
	

	Write-Host "Setting dynamic ARM template parameters."
	if($SitecoreDeploymentType -eq "single") {
		$Parameters = @{
		    "deploymentId" = $ResourceGroup
		    "licenseXml" = $licenseXml
		    "location" = $Location
		    "authCertificateBlob" = $certificateBlob
		    "templateLinkAccessToken" = $sasToken
			"lockResourceGroup" = [System.Convert]::ToBoolean("$LockResourceGroup")
			"enableCPUAlerts" = [System.Convert]::ToBoolean("$EnableCPUAlerts")
			"enableMemoryAlerts" = [System.Convert]::ToBoolean("$EnableMemoryAlerts")
			"enableAdditionalAppAvailabilityAlerts" = [System.Convert]::ToBoolean("$EnableAdditionalAppAvailabilityAlerts")
			"enableAppAvailabilityAlerts" = [System.Convert]::ToBoolean("$EnableAppAvailabilityAlerts")
   		    "singleMsDeployPackageUrl" = "$SingleSitecorePackageBlobUrl$sasToken"
		    "xcSingleMsDeployPackageUrl" = "$SingleXConnectPackageBlobUrl$sasToken"
			"deployInfrastructureOnly" = $DeployInfrastructureOnly
		}
	}
	elseif($SitecoreDeploymentType -eq "scaled") {
		$parameters = @{
		    "deploymentId" = $ResourceGroup
		    "licenseXml" = $licenseXml
		    "location" = $Location
		    "authCertificateBlob" = $certificateBlob
		    "templateLinkAccessToken" = $sasToken
			"lockResourceGroup" = [System.Convert]::ToBoolean("$LockResourceGroup")
			"enableCPUAlerts" = [System.Convert]::ToBoolean("$EnableCPUAlerts")
			"enableMemoryAlerts" = [System.Convert]::ToBoolean("$EnableMemoryAlerts")
			"enableAdditionalAppAvailabilityAlerts" = [System.Convert]::ToBoolean("$EnableAdditionalAppAvailabilityAlerts")
			"enableAppAvailabilityAlerts" = [System.Convert]::ToBoolean("$EnableAppAvailabilityAlerts")
			"cmMsDeployPackageUrl" = "$ScaledSitecoreCMPackageBlobUrl$sasToken"
			"cdMsDeployPackageUrl" = "$ScaledSitecoreCDPackageBlobUrl$sasToken"
			"prcMsDeployPackageUrl" = "$ScaledSitecoreProcPackageBlobUrl$sasToken"
			"repMsDeployPackageUrl" = "$ScaledSitecoreRepPackageBlobUrl$sasToken"
			"exmDdsMsDeployPackageUrl" = "$ScaledSitecoreDdsPackageBlobUrl$sasToken"
		 	"xcCollectMsDeployPackageUrl" = "$ScaledXp1CollectionPackageBlobUrl$sasToken"
			"xcSearchMsDeployPackageUrl" = "$ScaledXp1CollectionSearchPackageBlobUrl$sasToken"
			"maOpsMsDeployPackageUrl" = "$ScaledXp1MarketingAutomationPackageBlobUrl$sasToken"
			"maRepMsDeployPackageUrl" = "$ScaledXp1MarketingAutomationReportingPackageBlobUrl$sasToken"
			"xcRefDataMsDeployPackageUrl" = "$ScaledXp1ReferenceDataPackageBlobUrl$sasToken"
			"exmCmMsDeployPackageUrl" = "$ScaledExmPatchPackageBlobUrl$sasToken"
			"deployInfrastructureOnly" = $DeployInfrastructureOnly
		}
	}
	else {
		Write-Error "Deployment Type '$SitecoreDeploymentType' is Not Yet Implemented"
		exit 1
	}

	#$Parameters | Format-List | Out-Host

	Write-Host "Beginning Sitecore deployment."
	Write-Host "`tDeployment Template URL: $JsonTemplateURL"
	Write-Host "`tDeployment Paramater Path: $JsonParameterPath"
	Start-SitecoreAzureDeployment -Name $ResourceGroup -Location $Location -ArmTemplateUrl "$JsonTemplateURL$sasToken" -ArmParametersPath $JsonParameterPath -SetKeyValue $Parameters -Verbose

}

function EnsureTargetResourceGroupExists {
	#Returns whether resource group exists
	Param(
		[parameter (Mandatory=$true)]
		[string] $ResourceGroup,

		[parameter (Mandatory=$true)]
		[string] $Location
	)
	try {
		Get-AzureRmResourceGroup -Name $ResourceGroup -Location $Location | out-null
		Write-Host "Resource Group '$ResourceGroup' already exists!"
		return $true
	}
	catch {
		Write-Host "Resource Group does not exist. Creating resource group '$ResourceGroup'."
		New-AzureRmResourceGroup -Name $ResourceGroup -Location $Location
		return $false
	}
}

#https://github.com/robhabraken/Sitecore-Azure-Scripts/blob/master/Scripts/00%20Functions/functions-module.psm1
function GenerateSasForStorageURI {
    param (
		[parameter (Mandatory=$true)]
        $StorageAccountName,

		[parameter (Mandatory=$true)]
        $ContainerName,

		[parameter (Mandatory=$false)]
		$Permission = "r",

		[parameter (Mandatory=$false)]
		[int] $Duration = 4 #hours
    )

    process {
        #Processes input string and, if it storage URI - tries to generate a short living SAS for it

        $storageAccount = Get-AzureRmStorageAccount | Where-Object {$_.StorageAccountName -eq $storageAccountName}
        if ($null -eq $storageAccount) {
            Write-Warning "Could not get a valid storage context."
            return ""
        }

        $now = [System.DateTime]::Now
        #construct SAS token for a container
        $SAStokenQuery = New-AzureStorageContainerSASToken -Name $containerName -Context $storageAccount.Context -Permission $Permission -StartTime $now.AddHours(-1) -ExpiryTime $now.AddHours($Duration)

        return $SAStokenQuery
    }
}

function UploadTemplatesToStorage {
    param (
        $StorageAccount,
        $StorageAccountContainer,
        $TemplateDeploymentResourceGroup,
        $TemplateDirectory
    )

    process {
 		Write-Host "Creating short-lived, write-access SAS token and context for uploading templates."
		$WriteSasToken = GenerateSasForStorageURI -StorageAccountName $StorageAccount -ContainerName $StorageAccountContainer -Permission "rwdl" -Duration 1
		$WriteContext = New-AzureStorageContext -StorageAccountName $StorageAccount -SasToken $WriteSasToken
		
		Write-Host "Cleaning out existing templates."
		Get-AzureStorageBlob -Context $WriteContext -Container $StorageAccountContainer -Blob "templates/$TemplateDeploymentResourceGroup/*" | Remove-AzureStorageBlob

    	Write-Host "Uploading templates to storage account."
    	$directory = Get-Item -Path $TemplateDirectory
    	Get-ChildItem "$TemplateDirectory" -File -Recurse | ForEach-Object {
    		$relativeDir = ("$($_.FullName)" | Out-String).Replace("$($directory.FullName)","").Replace("\","/")  #may contain \ that will need to be switched to /
    		$BlobPath = ("templates/$TemplateDeploymentResourceGroup$relativeDir").Trim() #For some reason, there is a new-line in the string, so trim that off.
    		Write-Host "Uploading '$BlobPath'"
    		Set-AzureStorageBlobContent -File $_.FullName -Container $StorageAccountContainer -Context $WriteContext -Blob $BlobPath -Force | Out-Null
    	}
    }
}

Main