################################################################################################################
# Information:
#
#	proda deployment
#
###############################################################################################################

$ErrorActionPreference = "Stop"

& "$PSScriptRoot\sitecore-deploy.ps1" `
	-WebEnvironment "Production A" `
	-WebEnvironmentShort "proda" `
	-SitecoreDeploymentType "scaled" `
	-ResourceGroupPrefix "" `
	-LockResourceGroup `
	-EnableCPUAlerts `
	-EnableMemoryAlerts `
	-EnableAdditionalAppAvailabilityAlerts `
	-EnableAppAvailabilityAlerts `
    -Subscription "5d474f0f-892e-4843-a5c9-803a09ca8628"