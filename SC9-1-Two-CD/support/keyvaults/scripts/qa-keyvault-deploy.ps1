$resourceGroupName = "dxv-keystore"
$vaultEnvironment = "qa"
$subscriptionId = "842018ba-1d53-4c48-b057-a17801295110"

$keyvaultProjectRoot = "$($PSScriptRoot)\.."

Write-Host "Executing keyvault deployment for $vaultEnvironment in $resourceGroupName"

& "$($PSScriptRoot)\keyvault-deploy.ps1" `
    -subscriptionId $subscriptionId `
    -resourceGroupName $resourceGroupName `
    -resourceGroupLocation "eastus" `
    -deploymentName "$resourceGroupName-keyvault-$vaultEnvironment-deploy" `
    -templateFilePath "$keyvaultProjectRoot\templates\keyvault.template.json" `
    -parametersFilePath "$keyvaultProjectRoot\parameters\$vaultEnvironment.keyvault.parameters.json"