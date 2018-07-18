$subscription = "842018ba-1d53-4c48-b057-a17801295110"
$resourceGroup = "dxv-qa-rg"
$appName = "dxv-qa-rg-ai"

# rule configuration
$ruleName = ("slowpageloadtime","slowserverresponsetime","longdependencyduration","slowpageloadtime","degradationinserverresponsetime","degradationindependencyduration")
#$ruleName = "slowserverresponsetime" # should be one of: slowserverresponsetime, longdependencyduration, slowpageloadtime, degradationinserverresponsetime, degradationindependencyduration
$enabled = $true
$sendEmailsToSubscriptionOwners = $false
$customEmails = @("devops@horizontalintegration.com");

# authentication parameters
$tenantName = "1a60addb-fe41-420d-a2d6-ce2a3b159089"

# create the autoherization token (manual approach)
# taken from: https://blogs.technet.microsoft.com/paulomarques/2016/03/21/working-with-azure-active-directory-graph-api-from-powershell/
# for full automation, the token will need to be retrieved by a non-manual approach
function GetAuthToken {
    param
    (
        [Parameter(Mandatory = $true)]
        $TenantName
    )
 
    $adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll" 
    $adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll" 
    [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null 
    [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
 
    $clientId = "1950a258-227b-4e31-a9cf-717495945fc2"  
    $redirectUri = "urn:ietf:wg:oauth:2.0:oob" 
    $resourceAppIdURI = "https://management.azure.com/" 
    $authority = "https://login.windows.net/$TenantName" 
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority 
    $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Auto")
 
    return $authResult
}

$token = GetAuthToken -TenantName $tenantName
$authHeader = @{
    'Authorization' = $token.CreateAuthorizationHeader()
}

foreach($rule in $ruleName){
    $uri = "https://management.azure.com/subscriptions/$($subscription)/resourcegroups/$($resourceGroup)/providers/microsoft.insights/components/$($appName)/ProactiveDetectionConfigs?ConfigurationId=$($rule)&api-version=2015-05-01"
    $body = @{
    "name"                           = $rule;
    "enabled"                        = $enabled;
    "sendEmailsToSubscriptionOwners" = $sendEmailsToSubscriptionOwners;
    "customEmails"                   = $customEmails;
    
} 
    $bodyJson = $body | ConvertTo-Json
    Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Put -Body $bodyJson -ContentType "application/json"
}
