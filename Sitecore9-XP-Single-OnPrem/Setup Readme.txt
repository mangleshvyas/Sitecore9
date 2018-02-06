## Setup local Sitecore 9 instance

# Initial Setup Step
1. Copy contents of "I:\Sitecore Installers\Sitecore 9 local setup\resourcefiles" to "C:\resourcefiles"
2. Copy your Sitecore license file into "C:\resourcefiles"

# Install the Sitecore Installation Framework using MyGet
The Sitecore Gallery is a public MyGet feed that is used to download and install PowerShell modules created by Sitecore. The Sitecore Installation Framework is available through the Sitecore Gallery.

To set up the Sitecore Installation Framework:
1. In Windows, launch PowerShell as an administrator.
2. To register the repository, in a PowerShell command line, run the following cmdlet:
	Register-PSRepository -Name SitecoreGallery -SourceLocation https://sitecore.myget.org/F/sc-powershell/api/v2
3. Install the PowerShell module by running the following cmdlet:
	Install-Module SitecoreInstallFramework
4. When prompted to install, press Y, and then press ENTER. 

# Install Solr
1. In Windows, launch PowerShell as an administrator.
2. Change working directory to C:\resourcefiles
3. Run the following cmdlet
	.\install-solr -solrVersion "6.6.2" -installFolder "c:\solr" -solrPort "8983" -solrHost "solr" -solrSSL true -nssmVersion "2.24" -JREVersion "9.0.1"
	NOTE: You can also update the script to set your paramater values if you don't want to pass them in
4. Add your solrHost value to your HOST file

# Install Sitecore 9 w/ xConnect
1. Open install.ps1
2. update the "define parameters" (lines 2-11)
3. In Windows, launch PowerShell as an administrator.
4. Change working directory to C:\resourcefiles
5. Run the following cmdlet
	.\install


# My Findings.

1. replace PSscriptRoot  with scriptRoot
2. Introduce start Solr  Delay in xconnect-solr.json
3. Introduce start Solr Delay in sitecore-solr.json
4. Install Microsoft Web Deploy V3 
