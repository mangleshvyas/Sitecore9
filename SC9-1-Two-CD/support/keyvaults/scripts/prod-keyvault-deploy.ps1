$resourceGroupName = "mv-keystore"
$vaultEnvironment = "prod"
$subscriptionId = "5d474f0f-892e-4843-a5c9-803a09ca8628"

$keyvaultProjectRoot = "$($PSScriptRoot)\.."

Write-Host "Executing keyvault deployment for $vaultEnvironment in $resourceGroupName"

& "$($PSScriptRoot)\keyvault-deploy.ps1" `
    -subscriptionId $subscriptionId `
    -resourceGroupName $resourceGroupName `
    -resourceGroupLocation "eastus" `
    -deploymentName "$resourceGroupName-keyvault-$vaultEnvironment-deploy" `
    -templateFilePath "$keyvaultProjectRoot\templates\keyvault.template.json" `
    -parametersFilePath "$keyvaultProjectRoot\parameters\$vaultEnvironment.keyvault.parameters.json"