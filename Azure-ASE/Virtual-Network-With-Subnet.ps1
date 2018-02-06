######################################################################
# Created by: Hardeep Bhamra
# Date:       06th Feb, 2018
# Version:    1.0
#
# a. This script will create one Virtual network with  network
#    Prefix as 192.168.0.0/16 at location northcentralus, it will
#    also add subnet under the virtual network, with subnet as
#    192.168.1.0/24.
#    
#    In the second phase the script will create a Azure Service Environment
#
#
######################################################################


param(
[parameter (Mandatory =$True, HelpMessage="Enter Resource Group Name")]
[string]
$ResourceGroupName,

[parameter (Mandatory = $True, HelpMessage="Enter Location for Resource Group")]
[string]
$Location,

[parameter (Mandatory = $True, HelpMessage="Enter Virtual Network Name")]
[string]
$VnetName,

[parameter (Mandatory = $True, HelpMessage="Enter the name of Subnet")]
[string]
$SubnetName,

[parameter (Mandatory = $True, HelpMessage="Enter Virtual Network address")]
[string]
$VNetworkAddress,

[parameter (Mandatory = $True, HelpMessage="Enter Subnet Address in Virtual Network")]
[string]
$SubnetAddress,

[parameter (Mandatory = $True, HelpMessage="Enter Subnet Address in Virtual Network")]
[string]
$ASEName

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
Write-Host "Setting Azure Subscription $GetSubName" -ForegroundColor Yellow
Get-AzureRmSubscription -SubscriptionName $GetSubName  | Select-AzureRmSubscription


#4. Resource group available.
Write-Host "Creating New Resource Group $ResourceGroupName at $Location" -ForegroundColor Yellow 
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location


#5. Creating a Virtual Network
Write-Host "Creating Virutal Network $VnetName with Network Address $VNetworkAddress" -ForegroundColor Yellow
New-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName `
-Name $VnetName -AddressPrefix $VNetworkAddress -Location $Location


#6. Getting information realted to new virtual network, needed to add subnets under virtual network
Write-Host "Collecting $VnetName information for Subnet addition" -ForegroundColor Yellow
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName


#7. Adding one subnet under virtual network
Write-Host "Adding $SubnetName with subnet address $SubnetAddress in Virtual Network $VnetName" -ForegroundColor Yellow
Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName `
-VirtualNetwork $vnet -AddressPrefix $SubnetAddress



#8. sets the goal state for an Azure virtual network.
Write-Host "Setting the state for Virtual Network." -ForegroundColor Yellow
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet


#9. Get Virtual Network ID so as to set in the Parameter file
$ID = Get-AzureRmVirtualNetwork -Name $VnetName -ResourceGroupName $ResourceGroupName `
| select -ExpandProperty ID


#10. Updating the Azure Parameter JSon file with values
$a = Get-Content "C:\Users\hbhamra.HZI\Downloads\DevOps\Manglesh\Sitecore9XPSingle\Pods\ASE-Deploy\azuredeploy.parameters.json" -Raw | ConvertFrom-Json
$a.parameters.existingVnetResourceId.value = "$ID"  
$a | ConvertTo-Json | Set-Content "C:\Users\hbhamra.HZI\Downloads\DevOps\Manglesh\Sitecore9XPSingle\Pods\ASE-Deploy\azuredeploy.parameters.json"

$a = Get-Content "C:\Users\hbhamra.HZI\Downloads\DevOps\Manglesh\Sitecore9XPSingle\Pods\ASE-Deploy\azuredeploy.parameters.json" -Raw | ConvertFrom-Json
$a.parameters.subnetName.value = "$SubnetName"  
$a | ConvertTo-Json | Set-Content "C:\Users\hbhamra.HZI\Downloads\DevOps\Manglesh\Sitecore9XPSingle\Pods\ASE-Deploy\azuredeploy.parameters.json"



#11. Go to where parameter files are
cd C:\Users\hbhamra.HZI\Downloads\DevOps\Manglesh\Sitecore9XPSingle\Pods\ASE-Deploy


#12. Deploying Azure Service Environment.
Write-Host "Deploying Azure Service Environment." -ForegroundColor Yellow
New-AzureRmResourceGroupDeployment -Name $ASEName -ResourceGroupName $ResourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-web-app-asev2-create/azuredeploy.json