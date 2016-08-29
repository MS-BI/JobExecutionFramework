# JobExceutionFramework
**The Job Excecution Framework for SSIS**

The main task of the Execution Framework is the management of ETL Processes implemented with SQL Server Integrations Services.
The central component is a single SSIS package, the “Master Package”, which executes all the other packages (“work packages”),
governed by configuration data stored in a configuration database.
Instances of the Master Package may run in parallel on the same server or on several servers, executions and problems are logged.

**Documentation**

You can find the documentation ("JEFS Documentation.docx") as part of the SSIS project (misc. files) or in the folder ETL_Framework

**SQL Server Version**

The current version is based on SQL Server 2012. Upgrading to a newer version should pose no problem.

**Installation**

There is a Solution "JobExecutionFramework" with two database projects ("ConfigDB" and "SSISDB") and one SSIS project ("SSIS")
- Deploy "ConfigDB" to a Database (there should be a SSIS Catalog at the server)
- Do NOT deploy SSISDB. It is only needed as reference for the ConfigDB project
- Adjust the connection strings in the SSIS Project and deploy
- For further steps check the docu

**History and Thanks**

The first version was developed by Christoph Seck for a company with several production plants that needed a central DWH for production data. Because of security constrains and the questions of load balancing it was necessary to distribute the ETL processes over different servers with the possibility of automatic or ad hoc reconfiguration.
The second version was developed with Cluster Reply and utilized the new possibilities which came for SSIS with SQL Server 2012. Special thanks here to Simone Zier and Vitali Altach.

The third and current version was a complete reimplementation done during Christophs time at Ceteris AG (www.ceteris.ag). The discussions in the open atmosphere at Ceteris greatly enhanced the original ideas. Without the feedback of guys like Thorsten Huss, Chris Jacob, Ben Kanter and Markus Schechner the Framework would be much buggier and still lack some important features. An optional interface for the Advanced Logging Components for SSIS from Ceteris is still included.
Further input came from our customers where the Framework was used and enhanced. Special thanks here to the DPD IT team.
The deal with the customers always was: You do not have to pay for the usage of the framework, but all enhancements done at your site go back to the product and can be used by all other users of the product.
Now Ceteris took this principle a step further by publishing the Framework to GitHub under the MIT license.
