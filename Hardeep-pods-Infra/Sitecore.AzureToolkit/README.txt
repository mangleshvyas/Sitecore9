Sitecore Azure Toolkit
======================

Current package contains tools and resources that simplify packaging of Sitecore
solutions and their deployment to Microsoft Azure.

Content
-------

The package consists of the following parts:

  * tools/ - Powershell commandlets and support libraries
   
    * Sitecore.Cloud.Cmdlets.psm1 - Primary entry point which contain
      commandlets for packaging and deployment of Sitecore solutions and converting
      Sitecore Installer packages for use with MSDeploy.

  * Resources/ - contains resources needed to package corresponding Sitecore products.
    Resources compatibility is following:

        | Resources   | Products versions                         |
        |-------------|-------------------------------------------|
        | 8.2.1/      | SXP 8.2 Update-1                          |
        | 8.2.2/      | SXP 8.2 Update-2                          |
        | 8.2.3/      | SXP 8.2 Update-3                          |    
        | 8.2.4/      | SXP 8.2 Update-4                          |
        | 8.2.5/      | SXP 8.2 Update-5 and Update-6             |
        | 9.0.0/      | SXP 9.0                                   |
        | 9.0.1/      | SXP 9.0 Update-1                          |
        | EXM 3.5.0/  | EXM 3.5                                   |
        | WFFM 8.2.3/ | WFFM for SXP 8.2 Update-3                 |
        | WFFM 8.2.4/ | WFFM for SXP 8.2 Update-4                 |
        | WFFM 8.2.5/ | WFFM for SXP 8.2 Update-5 and Update-6    |
        | WFFM 9.0.0/ | WFFM for SXP 9.0                          |

    Resources include (may vary depending on product):
    
      * Addons/ - Webdeploy packages (WDPs) of addons which might be necessary for
        successful deployment of Sitecore modules.

        * Sitecore.Cloud.Integration.Bootload.wdp.zip  - The Bootloader module is a tiny
          module that facilitates the installation of supported Sitecore modules.
          Is distributed as part of resources for SXP starting from 8.2 Update-3

      * CargoPayloads/ - Transformation packages providing integration 
        with Azure services, role-specific configuration and AppService
        tweaks.
      
      * MSDeployXmls/ - templates for WebDeploy package manifests for
        each of supported Sitecore roles.

      * Configs/ - configuration files mapping role-specific configuration
        to supported topologies.
    
   * Copyrights/ - license agreements of third party libraries referenced in commandlets
     distributed in current package.

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
