################################################################################################################
# Information:
#
#
# a. Provide Resource group name
# b. Provide Location of your web app where you want to build
# c. Provide storageaccount name to copy the Sitecore application zip files
# d. WorkingDir: should be the local path in your system where you have your toolkit, powershell script, license, certificate etc.
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
$WorkingDir,

[parameter (Mandatory = $True)]
[string]
$ContainerName

)

#1. Login to Azure
Login-AzureRmAccount

#2. Getting Azure Subscription and setting up Subscription as variable.

$GetSub = Get-AzureRmSubscription | select -ExpandProperty 'SubscriptionName'
Write-Host "Select the numeric value for account that you want to use for setup" -ForegroundColor Yellow

for ($i = 0; $i -lt $GetSub.Length ; $i++ ) {Write-Host $i + $GetSub[$i]}

$GetSubValue = Read-Host
$GetSubName = $GetSub[$GetSubValue]


#3. Set Azure Subscription
Get-AzureRmSubscription -SubscriptionName $GetSubName  | Select-AzureRmSubscription


#4. Resource group available. 
#New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location 


#5. Storage account to be created
New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Location -SkuName Standard_LRS 

#6. Get Storage account keys and Create Container
$StorageAccountKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$Key0 = $StorageAccountKeys | Select-Object -First 1 -ExpandProperty Value
$Context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $Key0
New-AzureStorageContainer -Context $Context -Name $ContainerName


#7. Upload Files to storage account
Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.1 rev. 171219 (Cloud)_cd.scwdp.zip" -Container $ContainerName -Context $Context -Verbose
Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.1 rev. 171219 (Cloud)_cm.scwdp.zip" -Container $ContainerName -Context $Context -Verbose
Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.1 rev. 171219 (Cloud)_dds.scwdp.zip" -Container $ContainerName -Context $Context -Verbose
Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.1 rev. 171219 (Cloud)_prc.scwdp.zip" -Container $ContainerName -Context $Context -Verbose
Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.1 rev. 171219 (Cloud)_rep.scwdp.zip" -Container $ContainerName -Context $Context -Verbose

Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.1 rev. 171219 (Cloud)_xp1collection.scwdp.zip" -Container $ContainerName -Context $Context -Verbose
Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.1 rev. 171219 (Cloud)_xp1collectionsearch.scwdp.zip" -Container $ContainerName -Context $Context -Verbose
Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.1 rev. 171219 (Cloud)_xp1marketingautomation.scwdp.zip" -Container $ContainerName -Context $Context -Verbose
Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.1 rev. 171219 (Cloud)_xp1marketingautomationreporting.scwdp.zip" -Container $ContainerName -Context $Context -Verbose
Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore 9.0.1 rev. 171219 (Cloud)_xp1referencedata.scwdp.zip" -Container $ContainerName -Context $Context -Verbose
Set-AzureStorageBlobContent -File "$WorkingDir\Sitecore.Patch.EXM (Cloud)_CM.zip" -Container $ContainerName -Context $Context -Verbose


#8. Set and Get blob access details. 
#Generate a blob SAS token for Sitecore 9 XP Xconnect package
$StartTime = Get-Date
$EndTime = $startTime.AddHours(48.0)
$uriCD = New-AzureStorageBlobSASToken -Container $ContainerName -Blob "Sitecore 9.0.1 rev. 171219 (Cloud)_cd.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri

$StartTime = Get-Date
$EndTime = $startTime.AddHours(48.0)
$uriCM = New-AzureStorageBlobSASToken -Container $ContainerName -Blob "Sitecore 9.0.1 rev. 171219 (Cloud)_cm.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri


$StartTime = Get-Date
$EndTime = $startTime.AddHours(48.0)
$uriexmDDS = New-AzureStorageBlobSASToken -Container $ContainerName -Blob "Sitecore 9.0.1 rev. 171219 (Cloud)_dds.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri


$StartTime = Get-Date
$EndTime = $startTime.AddHours(48.0)
$uriPRC = New-AzureStorageBlobSASToken -Container $ContainerName -Blob "Sitecore 9.0.1 rev. 171219 (Cloud)_prc.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri


$StartTime = Get-Date
$EndTime = $startTime.AddHours(48.0)
$uriREP = New-AzureStorageBlobSASToken -Container $ContainerName -Blob "Sitecore 9.0.1 rev. 171219 (Cloud)_rep.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri


$StartTime = Get-Date
$EndTime = $startTime.AddHours(48.0)
$uriXCcol = New-AzureStorageBlobSASToken -Container $ContainerName -Blob "Sitecore 9.0.1 rev. 171219 (Cloud)_xp1collection.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri


$StartTime = Get-Date
$EndTime = $startTime.AddHours(48.0)
$uriXCSearch = New-AzureStorageBlobSASToken -Container $ContainerName -Blob "Sitecore 9.0.1 rev. 171219 (Cloud)_xp1collectionsearch.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri


$StartTime = Get-Date
$EndTime = $startTime.AddHours(48.0)
$uriXCmkt = New-AzureStorageBlobSASToken -Container $ContainerName -Blob "Sitecore 9.0.1 rev. 171219 (Cloud)_xp1marketingautomation.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri


$StartTime = Get-Date
$EndTime = $startTime.AddHours(48.0)
$uriXCmktrep = New-AzureStorageBlobSASToken -Container $ContainerName -Blob "Sitecore 9.0.1 rev. 171219 (Cloud)_xp1marketingautomationreporting.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri


$StartTime = Get-Date
$EndTime = $startTime.AddHours(48.0)
$uriXCref = New-AzureStorageBlobSASToken -Container $ContainerName -Blob "Sitecore 9.0.1 rev. 171219 (Cloud)_xp1referencedata.scwdp.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri


$StartTime = Get-Date
$EndTime = $startTime.AddHours(48.0)
$uriExmCM = New-AzureStorageBlobSASToken -Container $ContainerName -Blob "Sitecore.Patch.EXM (Cloud)_CM.zip" -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $Context -FullUri

#9. Add the SAS token to APP-Parameters.json file
$a = Get-Content "$WorkingDir\azuredeploy.Parameters.json" -Raw | ConvertFrom-Json
$a.parameters.cmMsDeployPackageUrl.value = "$uriCM"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.Parameters.json"

$a = Get-Content "$WorkingDir\azuredeploy.Parameters.json" -Raw | ConvertFrom-Json
$a.parameters.cdMsDeployPackageUrl.value = "$uriCD"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.Parameters.json"

$a = Get-Content "$WorkingDir\azuredeploy.Parameters.json" -Raw | ConvertFrom-Json
$a.parameters.prcMsDeployPackageUrl.value = "$uriPRC"
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.Parameters.json"

$a = Get-Content "$WorkingDir\azuredeploy.Parameters.json" -Raw | ConvertFrom-Json
$a.parameters.repMsDeployPackageUrl.value = "$uriREP"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.Parameters.json"

$a = Get-Content "$WorkingDir\azuredeploy.Parameters.json" -Raw | ConvertFrom-Json
$a.parameters.xcRefDataMsDeployPackageUrl.value = "$uriXCref"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.Parameters.json"

$a = Get-Content "$WorkingDir\azuredeploy.Parameters.json" -Raw | ConvertFrom-Json
$a.parameters.xcCollectMsDeployPackageUrl.value = "$uriXCcol"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.Parameters.json"

$a = Get-Content "$WorkingDir\azuredeploy.Parameters.json" -Raw | ConvertFrom-Json
$a.parameters.xcSearchMsDeployPackageUrl.value = "$uriXCSearch"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.Parameters.json"

$a = Get-Content "$WorkingDir\azuredeploy.Parameters.json" -Raw | ConvertFrom-Json
$a.parameters.maOpsMsDeployPackageUrl.value = "$uriXCmkt"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.Parameters.json"

$a = Get-Content "$WorkingDir\azuredeploy.Parameters.json" -Raw | ConvertFrom-Json
$a.parameters.maRepMsDeployPackageUrl.value = "$uriXCmktrep"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.Parameters.json"

$a = Get-Content "$WorkingDir\azuredeploy.Parameters.json" -Raw | ConvertFrom-Json
$a.parameters.exmDdsMsDeployPackageUrl.value = "$uriexmDDS"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.Parameters.json"

$a = Get-Content "$WorkingDir\azuredeploy.Parameters.json" -Raw | ConvertFrom-Json
$a.parameters.exmCmMsDeployPackageUrl.value = "$uriExmCM"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\azuredeploy.Parameters.json"


#10. Local Path for license file
$toolkitPath = "$WorkingDir\Sitecore Azure Toolkit 2.0.1 rev. 171218.zip"
$LicensePath = "$WorkingDir\license.xml"
$JsonParameterPath = "$WorkingDir\azuredeploy.Parameters.json"
#$JsonDeployPath = "https://raw.githubusercontent.com/mangleshvyas/Sitecore9/master/Sitecore9XPScaled-ASE/azuredeploy.json"
$JsonDeployPath = "https://raw.githubusercontent.com/mangleshvyas/Sitecore9/master/pods-ProdA-TM/azuredeploy.json"
$CertificateFile = "$WorkingDir\ED4B1C6021147A88C77284E414FA1EAC57107FCC.pfx"


$Parameters = @{
    
    "authCertificateBlob" = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($CertificateFile))
}

#11. Unzip the Toolkit zip file
Expand-Archive -Path $toolkitPath -DestinationPath $WorkingDir -Force



#12. Import the modules from Sitecore toolkit that we downloaded
Import-Module $WorkingDir\tools\sitecore.cloud.cmdlets.psm1 -Verbose

#13. Go to the local folder
cd $WorkingDir 

#14. Run the Siteccore Azure Deployment Cmdlet. 
Start-SitecoreAzureDeployment -Name $ResourceGroupName -Location $Location -ArmTemplateUrl $JsonDeployPath  -ArmParametersPath $JsonParameterPath  -LicenseXmlPath $LicensePath -SetKeyValue $Parameters -Verbose






