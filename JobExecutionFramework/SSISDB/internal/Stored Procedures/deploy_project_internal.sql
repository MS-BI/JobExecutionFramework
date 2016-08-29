CREATE PROCEDURE [internal].[deploy_project_internal]
@deploy_id BIGINT, @version_id BIGINT, @project_id BIGINT, @project_name NVARCHAR (128)
AS EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.ServerApi].[DeployProjectInternal]

