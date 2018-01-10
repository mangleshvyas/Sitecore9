#generate certificate
$thumbprint = (New-SelfSignedCertificate `
    -Subject "CN=$env:COMPUTERNAME @ Sitecore, Inc." `
    -Type SSLServerAuthentication `
    -FriendlyName "$env:USERNAME Certificate").Thumbprint
#export certificate with password
$certificateFilePath = "C:\Temp\$thumbprint.pfx"
Export-PfxCertificate `
    -cert cert:\LocalMachine\MY\$thumbprint `
    -FilePath "$certificateFilePath" `
    -Password (Read-Host -Prompt "Enter password that would protect the certificate" -AsSecureString)
#convert it to base64 string (blob)
$fileContentBytes = get-content $certificateFilePath -Encoding Byte
[System.Convert]::ToBase64String($fileContentBytes) | Out-File "C:\Temp\$thumbprint.txt"
Write-Host "Your secure certificate blob is located at C:\Temp\$thumbprint.txt" 