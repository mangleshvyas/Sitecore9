################################################################################################################
# Information:
#
#	prodb deployment
#
###############################################################################################################

$ErrorActionPreference = "Stop"

& "$PSScriptRoot\sitecore-deploy.ps1" `
	-WebEnvironment "Production B" `
	-WebEnvironmentShort "prodb" `
	-SitecoreDeploymentType "scaled" `
	-ResourceGroupPrefix "" `
	-LockResourceGroup `
	-EnableCPUAlerts `
	-EnableMemoryAlerts `
	-EnableAppAvailabilityAlerts `
    -Subscription "ca1eacdc-c82e-48b0-81ae-43bf2280e9e3"