param(
[parameter (Mandatory =$True)]
[string]
$resourceGroupName,

[parameter (Mandatory = $True)]
[string]
$location

)


#1. Login to Azure
Login-AzureRmAccount

#2. Getting Aaure Subscription and setting up Subscription as variable.

$getSub = Get-AzureRmSubscription | select -ExpandProperty 'SubscriptionName'
Write-Host "Select the numeric value for account that you want to use for setup" -ForegroundColor Yellow

for ($i = 0; $i -lt $getSub.Length ; $i++ ) {Write-Host $i + $getSub[$i]}

$getSubValue = Read-Host
$getSubName = $getSub[$getSubValue]


#3. Set Azure Subscription
Get-AzureRmSubscription -SubscriptionName $getSubName  | Select-AzureRmSubscription

#4. Create Variable and get the keys
$storageAccountName = "hidevstore"
$storageAccountkey = Get-AzureRmStorageAccountKey -ResourceGroupName 'dev-store-rg' -Name $storageAccountName 


#5. Select the first key
$key1 = $storageAccountkey | Where-Object KeyName -EQ "key1" |Select-Object -ExpandProperty value

#5. Set the context to be used in later cmdlet
$context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $key1

#6. Create a folder as working director
mkdir -Path 'c:\Sitecore9-Install' -Force
$dir = 'C:\Sitecore9-Install'

#7. Download the file from storage account
$fileName = "sitecore9\Sitecore-XM-Scaled\Sitecore Azure Toolkit 2.0.0 rev.171010.zip"
$localDirectory = "$dir\Sitecore Azure Toolkit 2.0.0 rev.171010.zip"
$containerName = "public"
$jsonParameter = "sitecore9\Sitecore-XM-Scaled\azuredeploy.parameters.json"
$license  ="sitecore9\Sitecore-XM-Scaled\license.xml"
$jsonParameterFilePath = "$dir\azuredeploy.parameters.json"
$licenseFilePath = "$dir\license.xml"

#8. Finally get the toolkit from storage account
Get-AzureStorageBlobContent -Blob $fileName -Container $containerName -Destination $localDirectory  -Context $context
Get-AzureStorageBlobContent -Blob $jsonParameter -Container $containerName -Destination $jsonParameterFilePath  -Context $context
Get-AzureStorageBlobContent -Blob $license -Container $containerName -Destination $licenseFilePath  -Context $context

#9. unarchive the Sitecore tool kit 
Expand-Archive -Path $localDirectory -DestinationPath $dir -Force 


#10. Local Path for license file
$localLicensePath = "$dir\license.xml"

#11. Local Path for Json Parameter file
$localArmParameterPath = "$dir\azuredeploy.parameters.json"

#12. Remote path for Json ARM Template
$remoteJsonPath = "https://raw.githubusercontent.com/mangleshvyas/Sitecore9/master/Sitecore9-XM-Scaled-Custom/azuredeploy.json"

#13. Import the modules from Sitecore toolkit that we downloaded
Import-Module $dir\tools\sitecore.cloud.cmdlets.psm1

#14. Go to the local folder
cd $dir

#15. Start the installation.
Start-SitecoreAzureDeployment -Name $resourceGroupName -Location $location -ArmTemplateUrl $remoteJsonPath  -ArmParametersPath $localarmParameterPath  -LicenseXmlPath $locallicensePath 
