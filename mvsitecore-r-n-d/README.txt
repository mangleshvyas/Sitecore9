Sitecore Azure Toolkit
======================

This package contains tools and resources that simplify the tasks of 
packaging and deploying Sitecore solutions to Microsoft Azure.

Content
-------

The package contains the following parts:

  * tools/ - Powershell commandlets and support libraries
   
    * Sitecore.Cloud.Cmdlets.psm1 - Primary entry point containing
      commandlets for packaging and deploying Sitecore and converting
      Sitecore Installer packages for use with MSDeploy.

  * Resources/

    * 8.2.1/ - Resources necessary for packaging 8.2 Update-1 solutions.
    
      * CargoPayloads/ - Transformation packages providing integration 
        with Azure services, role-specific configuration and AppService
        tweaks.
      
      * MSDeployXmls/ - templates for WebDeploy package manifests for
        each of supported Sitecore roles.

      * Configs/ - configuration files mapping role-specific configuration
        to supported environments.
    
Getting Started
---------------

Get more information about running Sitecore on Azure AppService and how to 
get started with Sitecore Azure Toolkit by visiting https://doc.sitecore.net/cloud

License
-------

Sitecore Azure Toolkit Powershell commandlets and resources are distributed
under Sitecore license. See SitecoreLicense.html for more details.

Individual third-party components are distributed under individual licenses,
see Copyrights folder for details.
