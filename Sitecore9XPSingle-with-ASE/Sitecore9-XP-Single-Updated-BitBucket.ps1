###############################################################################################################
# Before you run this script, check following points.
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

$getSub = Get-AzureRmSubscription | select -ExpandProperty 'SubscriptionName'
Write-Host "Select the numeric value for account that you want to use for setup" -ForegroundColor Yellow

for ($i = 0; $i -lt $getSub.Length ; $i++ ) {Write-Host $i + $getSub[$i]}

$getSubValue = Read-Host
$getSubName = $getSub[$getSubValue]


#3. Set Azure Subscription
Get-AzureRmSubscription -SubscriptionName $getSubName  | Select-AzureRmSubscription


#4. Resource group available. 
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location 


#5. Create a folder as working director
#mkdir -Path 'c:\S9Single' -Force
#$dir = 'C:\S9Single'


#5. Storage account to be created
New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Location -SkuName Standard_LRS 



#7. Local Path for license file
$toolkitPath = "$dir\Sitecore Azure Toolkit 2.0.0 rev.171010.zip"
$LicensePath = "$dir\license.xml"
$JsonParameterPath = "$dir\azuredeploy.parameters.json"
$JsonDeployPath = "https://bitbucket.org/horizontal/hi-devops/raw/99cba7ab4cef2fd69fff4e2d8115bb82154d1eb8/Sitecore9XPSingle/azuredeploy.json"
$CertificateFile = "$dir\ED4B1C6021147A88C77284E414FA1EAC57107FCC.pfx"

$Parameters = @{

    "deploymentId"=$resourceGroupName;

    "authCertificateBlob" = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($CertificateFile))

}

#8. Unzip the Toolkit zip file
Expand-Archive -Path $toolkitPath -DestinationPath $dir -Force

#9. Import the modules from Sitecore toolkit that we downloaded
Import-Module $dir\tools\sitecore.cloud.cmdlets.psm1

#10. Go to the local folder
cd $dir

#11. Start the installation.
Start-SitecoreAzureDeployment -Name $resourceGroupName -Location $location -ArmTemplateUrl $JsonDeployPath  -ArmParametersPath $JsonParameterPath  -LicenseXmlPath $LicensePath -SetKeyValue $Parameters


