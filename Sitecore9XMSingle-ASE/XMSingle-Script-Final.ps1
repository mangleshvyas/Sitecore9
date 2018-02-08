

#1. Login to Azure
Login-AzureRmAccount

#2. Set Azure Subscription
Get-AzureRmSubscription -SubscriptionId db7a438e-6b8b-492c-b8fc-320de8e549f7 | Select-AzureRmSubscription

#3. Create Variable and get the keys
$storageAccountName = "hidevstore"
$storageAccountkey = Get-AzureRmStorageAccountKey -ResourceGroupName dev-store-rg -Name $storageAccountName 


#4. Select the first key
$key1 = $storageAccountkey | Where-Object KeyName -EQ "key1" |Select-Object -ExpandProperty value

#5. Set the context to be used in later cmdlet
$context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $key1

#4. Create a folder as working director
mkdir -Path 'c:\Sitecore9-Install' -Force
$dir = 'C:\Sitecore9-Install'

#6. Download the file from storage account
$blobName = "sitecore9\Sitecore Azure Toolkit 2.0.0 rev.171010.zip"
$localTargetDirectory = "C:\Sitecore9-Install\Sitecore Azure Toolkit 2.0.0 rev.171010.zip"
$containerName = "public"

#7. Finally get the toolkit from storage account
Get-AzureStorageBlobContent -Blob $blobName -Container $containerName -Destination $localTargetDirectory  -Context $context

#8. unarchive the Sitecore tool kit 
Expand-Archive -Path $localTargetDirectory -DestinationPath 'C:\Sitecore9-Install' -Force


#9. Local Path for license file
$locallicensePath = "$dir\license.xml"

#10. Local Path for Json Parameter file
$localarmParameterPath = "$dir\azuredeploy.parameters.json"

#11. Remote path for Json ARM Template
$localjsonPath = "https://raw.githubusercontent.com/Sitecore/Sitecore-Azure-Quickstart-Templates/master/Sitecore 9.0.0/XMSingle/azuredeploy.json"


#12. Import the modules from Sitecore toolkit that we downloaded
Import-Module $dir\tools\sitecore.cloud.cmdlets.psm1

#13. Go to the local folder
cd c:\Sitecore9-Install

#14. Start the installation.
Start-SitecoreAzureDeployment -Name 'Sitecore9xm-Single-rg' -Location 'centralus' -ArmTemplateUrl $localjsonPath  -ArmParametersPath $localarmParameterPath  -LicenseXmlPath $locallicensePath 



