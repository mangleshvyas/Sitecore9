#
# copyAllStorageContainers.ps1
# Copies all storage containers from one storage account to another
#

param(
	[parameter (Mandatory=$true)]
	[string] $SourceResourceGroupName,

	[parameter (Mandatory=$false)]
	[string] $SourceStorageKey,

	[parameter (Mandatory=$true)]
	[string] $SourceStorageAccount,

	[parameter (Mandatory=$true)]
	[string] $DestResourceGroupName,
	
	[parameter (Mandatory=$true)]
	[string] $DestStorageAccount
)

$ErrorActionPreference = "Stop"

Write-Output "Copying all storage containers from $SourceResourceGroupName/$SourceStorageAccount to $DestResourceGroupName/$DestStorageAccount..."

#Obtain Storage Keys
if(!([string]::IsNullOrEmpty($SourceStorageKey))) {
	Write-Output "Using provided source storage key..."
} else {
	$SourceStorageKey = (Get-AzureRmStorageAccountKey -ResourceGroupName "$SourceResourceGroupName" -AccountName "$SourceStorageAccount").Value[0]
}
$DestStorageKey = (Get-AzureRmStorageAccountKey -ResourceGroupName "$DestResourceGroupName" -AccountName "$DestStorageAccount").Value[0]

#Server side storage copy
$SourceStorageContext = New-AzureStorageContext -StorageAccountName $SourceStorageAccount -StorageAccountKey $SourceStorageKey
$DestStorageContext = New-AzureStorageContext -StorageAccountName $DestStorageAccount -StorageAccountKey $DestStorageKey

$Containers = Get-AzureStorageContainer -Context $SourceStorageContext

foreach($Container in $Containers)
{
    $ContainerName = $Container.Name
    if (!((Get-AzureStorageContainer -Context $DestStorageContext) | Where-Object { $_.Name -eq $ContainerName }))
    {   
        Write-Output "Copying container: $ContainerName"
        New-AzureStorageContainer -Name $ContainerName -Permission $Container.Permission.PublicAccess -Context $DestStorageContext -ErrorAction Stop

		$Blobs = Get-AzureStorageBlob -Context $SourceStorageContext -Container $ContainerName
		$BlobCpyAry = @() #Create array of objects

		#Do the copy of everything
		foreach ($Blob in $Blobs)
		{
		   $BlobName = $Blob.Name
		   Write-Output "Copying $BlobName from $ContainerName"
		   $BlobCopy = Start-CopyAzureStorageBlob -Context $SourceStorageContext -SrcContainer $ContainerName -SrcBlob $BlobName -DestContext $DestStorageContext -DestContainer $ContainerName -DestBlob $BlobName
		   $BlobCpyAry += $BlobCopy
		}

		#Check Status
		foreach ($BlobCopy in $BlobCpyAry)
		{
		   #Could ignore all rest and just run $BlobCopy | Get-AzureStorageBlobCopyState but I prefer output with % copied
		   $CopyState = $BlobCopy | Get-AzureStorageBlobCopyState
		   $Message = $CopyState.Source.AbsolutePath + " " + $CopyState.Status + " {0:N2}%" -f (($CopyState.BytesCopied/$CopyState.TotalBytes)*100) 
		   Write-Output $Message
		}
	} else {
		Write-Output "Skipping existing container: $ContainerName"
	}
}
