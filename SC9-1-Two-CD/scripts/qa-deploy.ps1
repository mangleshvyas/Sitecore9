################################################################################################################
# Information:
#
#	qa deployment
#
###############################################################################################################

$ErrorActionPreference = "Stop"

& "$PSScriptRoot\sitecore-deploy.ps1" `
	-WebEnvironment "QA" `
	-WebEnvironmentShort "qa" `
	-ResourceGroupPrefix "" `
	-LockResourceGroup `
	-EnableCPUAlerts `
	-EnableMemoryAlerts `
	-EnableAdditionalAppAvailabilityAlerts `
	-EnableAppAvailabilityAlerts `
    -Subscription "ca1eacdc-c82e-48b0-81ae-43bf2280e9e3"