################################################################################################################
# Information:
#
#	int deployment
#
###############################################################################################################

$ErrorActionPreference = "Stop"

& "$PSScriptRoot\sitecore-deploy.ps1" `
	-WebEnvironment "Integration" `
	-WebEnvironmentShort "int" `
	-ResourceGroupPrefix "" `
	-LockResourceGroup `
	-EnableCPUAlerts `
	-EnableMemoryAlerts `
	-EnableAdditionalAppAvailabilityAlerts `
	-EnableAppAvailabilityAlerts `
    -Subscription "ca1eacdc-c82e-48b0-81ae-43bf2280e9e3"