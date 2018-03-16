
Write-Host "Provide CM app environment name" -ForegroundColor Yellow
$cmappname = Read-Host 

Write-Host "Provide CD app environment name" -ForegroundColor Yellow
$cdappname = Read-Host 

Write-Host "Provide prc app environment name" -ForegroundColor Yellow
$prcappname = Read-Host 

Write-Host "Provide Report app environment name" -ForegroundColor Yellow
$repappname = Read-Host 

Write-Host "Provide Xconnect Basic app environment name" -ForegroundColor Yellow
$xcbasicappname = Read-Host 

Write-Host "Provide XC Reporting app environment name" -ForegroundColor Yellow
$xcrepappname = Read-Host 

Write-Host "Provide EXM app environment name" -ForegroundColor Yellow
$exmappname = Read-Host 

Write-Host "Provide App Service environment name" -ForegroundColor Yellow
$appenvname = Read-Host 

Write-Host "Provide App Service environment Location" -ForegroundColor Yellow
$applocationname = Read-Host 


$a = Get-Content "$WorkingDir\AppServicePlanParameters.json" -Raw | ConvertFrom-Json
$a.parameters.CMappServicePlanName.value = "$cmappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\AppServicePlanParameters.json"


$a = Get-Content "$WorkingDir\AppServicePlanParameters.json" -Raw | ConvertFrom-Json
$a.parameters.CDappServicePlanName.value = "$cdappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\AppServicePlanParameters.json"

$a = Get-Content "$WorkingDir\AppServicePlanParameters.json" -Raw | ConvertFrom-Json
$a.parameters.PrcappServicePlanName.value = "$prcappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\AppServicePlanParameters.json"


$a = Get-Content "$WorkingDir\AppServicePlanParameters.json" -Raw | ConvertFrom-Json
$a.parameters.RepappServicePlanName.value = "$repappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\AppServicePlanParameters.json"


$a = Get-Content "$WorkingDir\AppServicePlanParameters.json" -Raw | ConvertFrom-Json
$a.parameters.XCBappServicePlanName.value = "$xcbasicappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\AppServicePlanParameters.json"


$a = Get-Content "$WorkingDir\AppServicePlanParameters.json" -Raw | ConvertFrom-Json
$a.parameters.XCRepappServicePlanName.value = "$xcrepappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\AppServicePlanParameters.json"


$a = Get-Content "$WorkingDir\AppServicePlanParameters.json" -Raw | ConvertFrom-Json
$a.parameters.ExmappServicePlanName.value = "$exmappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\AppServicePlanParameters.json"


$a = Get-Content "$WorkingDir\AppServicePlanParameters.json" -Raw | ConvertFrom-Json
$a.parameters.appServiceEnvironmentName.value = "$appenvname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\AppServicePlanParameters.json"


$a = Get-Content "$WorkingDir\AppServicePlanParameters.json" -Raw | ConvertFrom-Json
$a.parameters.aseLocation.value = "$applocationname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\AppServicePlanParameters.json"

New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile "$WorkingDir\AppServicePlanTemplate.json" -TemplateParameterFile "$WorkingDir\AppServicePlanParameters.json" -Verbose

$status = Get-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName

if ($status.ProvisioningState -eq 'Succeeded') {Write-Host "deployment done Successfully" -ForegroundColor Green}
else {Write-Host "Deployment Failed"}


#Adding Application Plan Name to App Parameter JSON file

Write-Host "Adding Application environment to Parameters file" -ForegroundColor Yellow


$a = Get-Content "$WorkingDir\app-parameters.json" -Raw | ConvertFrom-Json
$a.parameters.cmHostingPlanName.value = "$cmappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\app-parameters.json"

$a = Get-Content "$WorkingDir\app-parameters.json" -Raw | ConvertFrom-Json
$a.parameters.cdHostingPlanName.value = "$cdappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\app-parameters.json"

$a = Get-Content "$WorkingDir\app-parameters.json" -Raw | ConvertFrom-Json
$a.parameters.prcHostingPlanName.value = "$prcappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\app-parameters.json"

$a = Get-Content "$WorkingDir\app-parameters.json" -Raw | ConvertFrom-Json
$a.parameters.repHostingPlanName.value = "$repappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\app-parameters.json"

$a = Get-Content "$WorkingDir\app-parameters.json" -Raw | ConvertFrom-Json
$a.parameters.xcBasicHostingPlanName.value = "$xcbasicappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\app-parameters.json"

$a = Get-Content "$WorkingDir\app-parameters.json" -Raw | ConvertFrom-Json
$a.parameters.xcResourceIntensiveHostingPlanName.value = "$xcrepappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\app-parameters.json"

$a = Get-Content "$WorkingDir\app-parameters.json" -Raw | ConvertFrom-Json
$a.parameters.exmDdsHostingPlanName.value = "$exmappname"  
$a | ConvertTo-Json | Set-Content "$WorkingDir\app-parameters.json"



