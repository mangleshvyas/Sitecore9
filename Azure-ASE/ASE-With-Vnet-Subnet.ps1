##############################################################################################################################
# Created by: Hardeep Bhamra
# Date:       06th Feb, 2018
# Version:    1.0
#
# a. This script will create one Virtual network with  network
#    Prefix as eg: 192.168.0.0/16 at location northcentralus, it will
#    also add subnet under the virtual network, with subnet as eg:
#    192.168.1.0/24.
#    
# b. In the second phase the script will create a Azure Service Environment
#
# c. Param
#    $ResourceGroupName:          New ResourceGroupName
#    $Location:                   Location where you want to create the resources
#    $VnetName:                   Name of the Virtual Network
#    $SubnetName:                 Name of the Subnet under Virutal Network
#    $VNetworkAddress:            Network Address space eg: 192.168.0.0/16
#    $SubnetAddress:              Subnet Address under Virtual Network eg: 192.168.1.0/24
#    $ASEName:                    App Service Environment Name
#    $ASEWorkingDir:              Location path where all ASE realted files are available eg: Parameter, Deploy Json files
#
# d. This needs two files template.json and parameter.json which should be available in your $ASEWorkingDir Path.
#
#
##############################################################################################################################


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

[parameter (Mandatory = $True, HelpMessage="Enter ASE name which you want to create")]
[string]
$ASEName,

[parameter (Mandatory = $True, HelpMessage="Enter Working Dir path for ASE")]
[string]
$ASEWorkingDir

)

#$ASEWorkingDir = 'C:\Users\hbhamra.HZI\Downloads\DevOps\Sitecore9PAAS\DeployASE'

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

#Get Subscription ID for later use.
Write-Host "Setting Azure Subscription ID For $GetSubName" -ForegroundColor Yellow
$SubID = Get-AzureRmSubscription | ?{$_.Name -eq $GetSubName} | select -ExpandProperty ID


#4. Create new Resource group.
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
#a. Updating the Vnet name in parameters.json file.
$a = Get-Content "$ASEWorkingDir\parameters.json" -Raw | ConvertFrom-Json
$a.parameters.vnetName.value = "$VnetName"  
$a | ConvertTo-Json | Set-Content "$ASEWorkingDir\parameters.json"

#b. Updating the location in parameters.json file.
$a = Get-Content "$ASEWorkingDir\parameters.json" -Raw | ConvertFrom-Json
$a.parameters.location.value = "$Location"  
$a | ConvertTo-Json | Set-Content "$ASEWorkingDir\parameters.json" 

#c. Updating the subnetName in the parameters.json file
$a = Get-Content "$ASEWorkingDir\parameters.json" -Raw | ConvertFrom-Json
$a.parameters.subnetName.value = "$SubnetName"  
$a | ConvertTo-Json | Set-Content "$ASEWorkingDir\parameters.json"

#d. Updating the vnetID in the parameters.json file
$a = Get-Content "$ASEWorkingDir\parameters.json" -Raw | ConvertFrom-Json
$a.parameters.vnetId.value = "$ID"  
$a | ConvertTo-Json | Set-Content "$ASEWorkingDir\parameters.json"

#e. Updating the vnetResourceGroupName in the parameters.json file
$a = Get-Content "$ASEWorkingDir\parameters.json" -Raw | ConvertFrom-Json
$a.parameters.VNetResourceGroupName.value = "$ResourceGroupName"  
$a | ConvertTo-Json | Set-Content "$ASEWorkingDir\parameters.json"

#f. Updating the vnetAddress in the parameters.json file
$a = Get-Content "$ASEWorkingDir\parameters.json" -Raw | ConvertFrom-Json
$a.parameters.vnetAddress.value = "$VNetworkAddress"  
$a | ConvertTo-Json | Set-Content "$ASEWorkingDir\parameters.json"

#g. Updating the SubnetAddress in the parameters.json file
$a = Get-Content "$ASEWorkingDir\parameters.json" -Raw | ConvertFrom-Json
$a.parameters.subnetAddress.value = "$SubnetAddress"  
$a | ConvertTo-Json | Set-Content "$ASEWorkingDir\parameters.json"

#h. Updating the subnetRouteTableName in the parameters.json file
$a = Get-Content "$ASEWorkingDir\parameters.json" -Raw | ConvertFrom-Json
$a.parameters.subnetRouteTableName.value = "$ResourceGroupName-Route-Table"  
$a | ConvertTo-Json | Set-Content "$ASEWorkingDir\parameters.json"

#i. Updating the subnetNSGName in the parameters.json file
$a = Get-Content "$ASEWorkingDir\parameters.json" -Raw | ConvertFrom-Json
$a.parameters.subnetNSGName.value = "$ResourceGroupName-NSG"  
$a | ConvertTo-Json | Set-Content "$ASEWorkingDir\parameters.json"

#j. Updating the ASE name in the parameters.json file
$a = Get-Content "$ASEWorkingDir\parameters.json" -Raw | ConvertFrom-Json
$a.parameters.name.value = "$ResourceGroupName + ASE"  
$a | ConvertTo-Json | Set-Content "$ASEWorkingDir\parameters.json"

#k. Updating the subscription ID in the parameters.json file
$a = Get-Content "$ASEWorkingDir\parameters.json" -Raw | ConvertFrom-Json
$a.parameters.subscriptionId.value = "$SubID"  
$a | ConvertTo-Json | Set-Content "$ASEWorkingDir\parameters.json"

#11. Go to where parameter files are
cd $ASEWorkingDir


#12. Deploying Azure Service Environment.
Write-Host "Deploying Azure Service Environment." -ForegroundColor Yellow
#New-AzureRmResourceGroupDeployment -Name $ASEName -ResourceGroupName $ResourceGroupName -TemplateUri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-web-app-asev2-create/azuredeploy.json
New-AzureRmResourceGroupDeployment -Name $ASEName `-ResourceGroupName $ResourceGroupName `-TemplateFile $ASEWorkingDir\template.json `-TemplateParameterFile $ASEWorkingDir\parameters.json