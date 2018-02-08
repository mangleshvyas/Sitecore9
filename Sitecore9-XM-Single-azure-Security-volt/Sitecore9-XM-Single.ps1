param(
[parameter (Mandatory =$True)]
[string]
$resourceGroupName,

[parameter (Mandatory = $True)]
[string]
$Location,

[parameter (Mandatory = $True)]
[string]
$StorageAccountName,

[parameter (Mandatory = $True)]
[string]
$WorkingDir,

[parameter (Mandatory = $True)]
[string]
$ContainerName
)


#1. Login to Azure
Login-AzureRmAccount

#2. Getting Aaure Subscription and setting up Subscription as variable.

Write-Host -ForegroundColor Yellow "Getting Subsuription ID From Script Runner"

$getSub = Get-AzureRmSubscription | select -ExpandProperty 'SubscriptionName'
Write-Host "Select the numeric value for account that you want to use for setup" -ForegroundColor Yellow

for ($i = 0; $i -lt $getSub.Length ; $i++ ) {Write-Host $i + $getSub[$i]}


$getSubValue = Read-Host
$getSubName = $getSub[$getSubValue]


#3. Set Azure Subscription
Write-Host -ForegroundColor Yellow "Setting Up Subscriptoin to Use"

Get-AzureRmSubscription -SubscriptionName $getSubName  | Select-AzureRmSubscription

#4. Resource Group available.
Write-Host -ForegroundColor Yellow "Now checking for Resource Group and if it is available use same OR Create New"
New-AzureRmResourceGroup -Name $resourceGroupName -Location $Location

#5. Storage account to be created
Write-Host -ForegroundColor Yellow "Creating Storage to Upload Sitecore PackageZip"

New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $StorageAccountName -Location $Location -SkuName Standard_LRS

#6. Get Storage account keys and create container.

$StorageAccountKeys= Get-AzureRmStorageAccountKey  -ResourceGroupName $resourceGroupName -Name $StorageAccountName
$key0 = $StorageAccountKeys | Select-Object -First 1 -ExcludeProperty Valu
$context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $key0
New-AzureStorageContainer -Context $context -Name $ContainerName

#7. Upload Files to storage account

Write-Host -ForegroundColor Yellow "Uploading Sitecore PackageZip"

Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.0 rev. 171002 (Cloud)_xp0xconnect.scwdp.zip" -Container $ContainerName -Context $Context
Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.0 rev. 171002 (Cloud)_single.scwdp.zip" -Container $ContainerName -Context $Context


#8. Set and Get blob access details. 
#Generate a blob SAS token for Sitecore 9 XP Xconnect package
$StartTime = Get-Date
$EndTime = $startTime.AddHours(9.0)
$uriXPConnect = New-AzureStorageBlobSASToken -Container "s9singlecontainer" -Blob "Sitecore 9.0.0 rev. 171002 (Cloud)_xp0xconnect.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri

$StartTime = Get-Date
$EndTime = $startTime.AddHours(9.0)
$uriXPSingle = New-AzureStorageBlobSASToken -Container "s9singlecontainer" -Blob "Sitecore 9.0.0 rev. 171002 (Cloud)_single.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri


#9. Add the SAS token to azuredeploy.parameters.json file
$a = Get-Content "$WorkingDir\azuredeploy.parameters.json" -Raw | ConvertFrom-Json
$a.parameters.xcSingleMsDeployPackageUrl.value = "$uriXPConnect"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.parameters.json"

$a = Get-Content "$WorkingDir\azuredeploy.parameters.json" -Raw | ConvertFrom-Json
$a.parameters.singleMsDeployPackageUrl.value = "$uriXPSingle"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.parameters.json"


#10. Local Path for license file
$toolkitPath = "$WorkingDir\Sitecore Azure Toolkit 2.0.0 rev.171010.zip"
$LicensePath = "$WorkingDir\license.xml"
$JsonParameterPath = "$WorkingDir\azuredeploy.parameters.json"
$JsonDeployPath = "https://raw.githubusercontent.com/Sitecore/Sitecore-Azure-Quickstart-Templates/master/Sitecore%209.0.0/XPSingle/azuredeploy.json"
$CertificateFile = "$WorkingDir\ED4B1C6021147A88C77284E414FA1EAC57107FCC.pfx"


$Parameters = @{

    "deploymentId"=$resourceGroupName;

    "authCertificateBlob" = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($CertificateFile))

}

#11. Unzip the Toolkit zip file
Expand-Archive -Path $toolkitPath -DestinationPath $WorkingDir -Force



#12. Import the modules from Sitecore toolkit that we downloaded
Import-Module $WorkingDir\tools\sitecore.cloud.cmdlets.psm1

#13. Go to the local folder
cd $WorkingDir

#14. Run the Siteccore Azure Deployment Cmdlet. 

Write-Host -ForegroundColor Yellow "Starting Deployment"
Start-SitecoreAzureDeployment -Name $ResourceGroupName -Location $Location -ArmTemplateUrl $JsonDeployPath  -ArmParametersPath $JsonParameterPath  -LicenseXmlPath $LicensePath -SetKeyValue $Parameters

