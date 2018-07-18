# This is a script used to deploy artifacts from a directory to storage. It is currently called manually to upload new or additional packages.

# Example:
# UploadArtifactsFromDirectory.ps1 -UploadDirectory C:\MySingleTestPackageDir -SitecoreDeploymentType singletest

param(
    [parameter(Mandatory=$true)]
    [string] $UploadDirectory,

    [parameter(Mandatory=$false)]
    [string] $Subscription = "ca1eacdc-c82e-48b0-81ae-43bf2280e9e3",

    [parameter(Mandatory=$false)]
    [string] $ClientName = "pods",

    [parameter(Mandatory=$false)]
    [ValidateSet("East US","West US","Central US")] 
    [string] $Location = "East US",

    [parameter(Mandatory=$false)]
    [ValidateSet("single","hybrid","scaled")] 
    [string] $SitecoreDeploymentType = "single",

    [parameter(Mandatory=$false)]
    [string] $DeploymentResourceGroupName = "$ClientName-deploy-rg",

    [parameter(Mandatory=$false)]
    [string] $DeploymentStorageAccount = "$($ClientName)sitecoreartifacts",

    [parameter(Mandatory=$false)]
    [string] $DeploymentStorageAccountContainer = "sitecore9"
)

function Main {
    Write-Host "Creating short-lived, write-access SAS token and context for uploading templates."
    $WriteSasToken = GenerateSasForStorageURI -StorageAccountName "$($DeploymentStorageAccount)" -ContainerName "$($DeploymentStorageAccountContainer)" -Permission "rwdl" -Duration 2
    $WriteContext = New-AzureStorageContext -StorageAccountName $DeploymentStorageAccount -SasToken $WriteSasToken
    UploadPackagesToStorage -StorageContext $WriteContext -Container $DeploymentStorageAccountContainer -SitecoreDeploymentType $SitecoreDeploymentType -Directory $UploadDirectory
}

function UploadPackagesToStorage {
    param (
        $StorageContext,
        $Container,
        $SitecoreDeploymentType,
        $Directory
    )

    process {
        Write-Host "Uploading packagles to storage account."
        $DirectoryItem = Get-Item -Path $Directory
        Get-ChildItem "$Directory" -Filter "*.zip" -File -Recurse | ForEach-Object {
            $relativeDir = ("$($_.FullName)" | Out-String).Replace("$($DirectoryItem.FullName)","").Replace("\","/")  #may contain \ that will need to be switched to /
            $BlobPath = ("packages/$SitecoreDeploymentType$relativeDir").Trim() #For some reason, there is a new-line in the string, so trim that off.
            Write-Host "'$BlobPath'"
            Set-AzureStorageBlobContent -File $_.FullName -Container $Container -Context $StorageContext -Blob $BlobPath -Force
        }
    }
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

Main