################################################################################################################
# Information:
#
#	test-proda Production deployment
#
###############################################################################################################

$ErrorActionPreference = "Stop"

& "$PSScriptRoot\sitecore-deploy.ps1" `
	-WebEnvironment "Production A" `
	-WebEnvironmentShort "proda" `
	-SitecoreDeploymentType "scaled" `
	-ResourceGroupPrefix "test-" `
    -Subscription "ca1eacdc-c82e-48b0-81ae-43bf2280e9e3"
