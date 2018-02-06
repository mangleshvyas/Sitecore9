#define parameters
$prefix = "sc9demo"
$PSScriptRoot = "C:\resourcefiles"
$XConnectCollectionService = "$prefix.xconnect"
$sitecoreSiteName = "$prefix.sc"
$SolrUrl = "https://solr:8983/solr"
$SolrRoot = "C:\solr\Solr-6.6.2"
$SolrService = "Solr-6.6.2"
$SqlServer = "(local)"
$SqlAdminUser = "sa"
$SqlAdminPassword="scdev"

#install client certificate for xconnect
$certParams = @{
    Path = "$PSScriptRoot\xconnect-createcert.json"
    CertificateName = "$prefix.xconnect_client"
}
Install-SitecoreConfiguration @certParams -Verbose

#install solr cores for xdb
$solrParams = @{
    Path = "$PSScriptRoot\xconnect-solr.json"
    SolrUrl = $SolrUrl
    SolrRoot = $SolrRoot
    SolrService = $SolrService
    CorePrefix = $prefix
}
Install-SitecoreConfiguration @solrParams

#deploy xconnect instance
$xconnectParams = @{
    Path = "$PSScriptRoot\xconnect-xp0.json"
    Package = "$PSScriptRoot\Sitecore 9.0.0 rev. 171002 (OnPrem)_xp0xconnect.scwdp.zip"
    LicenseFile = "$PSScriptRoot\license.xml"
    Sitename = $XConnectCollectionService
    XConnectCert = $certParams.CertificateName
    SqlDbPrefix = $prefix
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SolrCorePrefix = $prefix
    SolrURL = $SolrUrl

}
Install-SitecoreConfiguration @xconnectParams

#install solr cores for sitecore
$solrParams = @{
    Path = "$PSScriptRoot\sitecore-solr.json"
    SolrUrl = $SolrUrl
    SolrRoot = $SolrRoot
    SolrService = $SolrService
    CorePrefix = $prefix
}
Install-SitecoreConfiguration @solrParams

#install sitecore instance
#$xconnectHostName = "$prefix.xconnect"
$sitecoreParams = @{
    Path = "$PSScriptRoot\sitecore-XP0.json"
    Package = "$PSScriptRoot\Sitecore 9.0.0 rev. 171002 (OnPrem)_single.scwdp.zip"
    LicenseFile = "$PSScriptRoot\license.xml"
    SqlDbPrefix = $prefix
    SqlServer = $SqlServer
    SqlAdminUser = $SqlAdminUser
    SqlAdminPassword = $SqlAdminPassword
    SolrCorePrefix = $prefix
    SolrUrl = $SolrUrl
    XConnectCert = $certParams.CertificateName
    Sitename = $sitecoreSiteName
    XConnectCollectionService = "https://$XConnectCollectionService"
}
Install-SitecoreConfiguration @sitecoreParams
