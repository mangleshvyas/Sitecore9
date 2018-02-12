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
[parameter (Mandatory =$True)]
[string]
$ResourceGroupName,

[parameter (Mandatory = $True)]
[string]
$Location,

[parameter (Mandatory = $True)]
[string]
$StorageAccountName,

[parameter (Mandatory = $True)]
[string]
$WorkingDir

)

#1. Login to Azure
Login-AzureRmAccount

#2. Getting Azure Subscription and setting up Subscription as variable.

$GetSub = Get-AzureRmSubscription | select -ExpandProperty 'Name'
Write-Host "Select the numeric value for account that you want to use for setup" -ForegroundColor Yellow

for ($i = 0; $i -lt $GetSub.Length ; $i++ ) {Write-Host $i + $GetSub[$i]}

$GetSubValue = Read-Host
$GetSubName = $GetSub[$GetSubValue]


#3. Set Azure Subscription
Get-AzureRmSubscription -SubscriptionName $GetSubName  | Select-AzureRmSubscription


#4. Resource group available. 
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location 


#5. Create a folder as working director
#mkdir -Path 'c:\S9Single' -Force
#$dir = 'C:\S9Single'


#6. Storage account to be created
New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Location -SkuName Standard_LRS 

#7. Get Storage account keys and Create Container
$StorageAccountKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$Key0 = $StorageAccountKeys | Select-Object -First 1 -ExpandProperty Value
$Context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $Key0
New-AzureStorageContainer -Context $Context -Name 's9singlecontainer'


#8. Upload Files to storage account
Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.0 rev. 171002 (Cloud)_xp0xconnect.scwdp.zip" -Container 's9singlecontainer' -Context $Context
Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.0 rev. 171002 (Cloud)_single.scwdp.zip" -Container 's9singlecontainer' -Context $Context


#9. Set and Get blob access details. 
#Generate a blob SAS token for Sitecore 9 XP Xconnect package
$StartTime = Get-Date
$EndTime = $startTime.AddHours(9.0)
$uriXPConnect = New-AzureStorageBlobSASToken -Container "s9singlecontainer" -Blob "Sitecore 9.0.0 rev. 171002 (Cloud)_xp0xconnect.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri

$StartTime = Get-Date
$EndTime = $startTime.AddHours(9.0)
$uriXPSingle = New-AzureStorageBlobSASToken -Container "s9singlecontainer" -Blob "Sitecore 9.0.0 rev. 171002 (Cloud)_single.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri


#10. Add the SAS token to azuredeploy.parameters.json file
$a = Get-Content "$WorkingDir\azuredeploy.parameters.json" -Raw | ConvertFrom-Json
$a.parameters.xcSingleMsDeployPackageUrl.value = "$uriXPConnect"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.parameters.json"

$a = Get-Content "$WorkingDir\azuredeploy.parameters.json" -Raw | ConvertFrom-Json
$a.parameters.singleMsDeployPackageUrl.value = "$uriXPSingle"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.parameters.json"


#9. Local Path for license file
$toolkitPath = "$WorkingDir\Sitecore Azure Toolkit 2.0.0 rev.171010.zip"
$LicensePath = "$WorkingDir\license.xml"
$JsonParameterPath = "$WorkingDir\azuredeploy.parameters.json"
$JsonDeployPath = "https://raw.githubusercontent.com/Sitecore/Sitecore-Azure-Quickstart-Templates/master/Sitecore%209.0.0/XPSingle/azuredeploy.json"
$CertificateFile = "$WorkingDir\ED4B1C6021147A88C77284E414FA1EAC57107FCC.pfx"


$Parameters = @{

    "deploymentId"=$resourceGroupName;

    "authCertificateBlob" = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($CertificateFile))

}

#10. Unzip the Toolkit zip file
Expand-Archive -Path $toolkitPath -DestinationPath $WorkingDir -Force



#11. Import the modules from Sitecore toolkit that we downloaded
Import-Module $WorkingDir\tools\sitecore.cloud.cmdlets.psm1

#12. Go to the local folder
cd $WorkingDir

#13. Run the Siteccore Azure Deployment Cmdlet. 
Start-SitecoreAzureDeployment -Name $ResourceGroupName -Location $Location -ArmTemplateUrl $JsonDeployPath  -ArmParametersPath $JsonParameterPath  -LicenseXmlPath $LicensePath -SetKeyValue $Parameters