param(
	[parameter (Mandatory=$false)]
	[string] $Subscription = "ca1eacdc-c82e-48b0-81ae-43bf2280e9e3",

	[parameter (Mandatory=$false)]
	[string] $ClientName = "pods",

	[parameter (Mandatory=$false)]
	[string] $DeploymentStorageAccount = "$($ClientName)sitecoreartifacts",

	[parameter (Mandatory=$false)]
	[string] $DeploymentStorageAccountContainer = "sitecore9",

	[parameter (Mandatory=$false)]
	[string] $TemplatePath = "templates/*"

)

$ErrorActionPreference = "Stop"
$ProjectRoot = ".\.."
if(!([string]::IsNullOrEmpty($PSScriptRoot))) {
	$ProjectRoot = "$PSScriptRoot\.."
}

function Main {
	Write-Host "Subscription: $Subscription"
	Write-Host "StorageAccount: $DeploymentStorageAccount"
	Write-Host "StorageAccountContainer: $DeploymentStorageAccountContainer"
	Write-Host "StorageTemplatePath: $TemplatePath"
	Write-Host "------------------"

	try {
		$testLogin = Get-AzureRmResourceGroup
		Write-Host "Already logged in."
	}
	catch {
		Write-Host "No active Azure RM login found Logging in..."
		Login-AzureRmAccount -Subscription $Subscription
	}

	Write-Host "Setting subscription to $Subscription"
	Select-AzureRmSubscription -Subscription $Subscription | out-null

	Write-Host "Removing ARM templates from storage account."
	RemoveTemplatesFromStorage -StorageAccount $DeploymentStorageAccount -StorageAccountContainer $DeploymentStorageAccountContainer -StorageTemplatePath $TemplatePath
}

#https://github.com/robhabraken/Sitecore-Azure-Scripts/blob/master/Scripts/00%20Functions/functions-module.psm1
function GenerateSasForStorageURI {
    param (
		[parameter (Mandatory=$true)]
        $StorageAccountName,

		[parameter (Mandatory=$true)]
        $ContainerName,

		[parameter (Mandatory=$false)]
		$Permission = "r",

		[parameter (Mandatory=$false)]
		[int] $Duration = 4 #hours
    )

    process {
        #Processes input string and, if it storage URI - tries to generate a short living (10 hours) SAS for it

        $storageAccount = Get-AzureRmStorageAccount | Where-Object {$_.StorageAccountName -eq $storageAccountName}
        if ($null -eq $storageAccount) {
            Write-Warning "Could not get a valid storage context."
            return ""
        }

        $now = [System.DateTime]::Now
        #construct SAS token for a container
        $SAStokenQuery = New-AzureStorageContainerSASToken -Name $containerName -Context $storageAccount.Context -Permission $Permission -StartTime $now.AddHours(-1) -ExpiryTime $now.AddHours($Duration)

        return $SAStokenQuery
    }
}

function RemoveTemplatesFromStorage {
    param (
        $StorageAccount,
        $StorageAccountContainer,
		$StorageTemplatePath
    )

    process {
 		Write-Host "Creating short-lived, write-access SAS token and context for uploading templates."
		$WriteSasToken = GenerateSasForStorageURI -StorageAccountName $StorageAccount -ContainerName $StorageAccountContainer -Permission "rwdl" -Duration 1
		$WriteContext = New-AzureStorageContext -StorageAccountName $StorageAccount -SasToken $WriteSasToken
		
		Write-Host "Remove existing templates."
		Get-AzureStorageBlob -Context $WriteContext -Container $StorageAccountContainer -Blob "$StorageTemplatePath" | Remove-AzureStorageBlob -Verbose
    }
}

Main