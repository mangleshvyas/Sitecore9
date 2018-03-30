################################################################################################################
# Information:
#
#	Integration deployment
#
#
#
#
#
#
#
#
#
#
#
###############################################################################################################

$ErrorActionPreference = "Stop"

& "$PSScriptRoot\sitecore-deploy.ps1" `
	-WebEnvironment "QA" `
	-WebEnvironmentShort "qat" `
	-ResourceGroupPrefix "" `
    -Subscription "ca1eacdc-c82e-48b0-81ae-43bf2280e9e3"
