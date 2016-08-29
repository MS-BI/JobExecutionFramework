CREATE PROCEDURE [internal].[start_execution_internal]
@project_id BIGINT, @execution_id BIGINT, @version_id BIGINT, @use32BitRuntime SMALLINT
AS EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.ServerApi].[StartExecutionInternal]

