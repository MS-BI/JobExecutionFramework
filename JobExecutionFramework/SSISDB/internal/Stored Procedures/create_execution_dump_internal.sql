CREATE PROCEDURE [internal].[create_execution_dump_internal]
@execution_id BIGINT
AS EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.ServerApi].[CreateExecutionDumpInternal]

