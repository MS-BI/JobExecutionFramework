CREATE PROCEDURE [internal].[stop_operation_internal]
@operation_id BIGINT, @process_id INT, @operation_guid UNIQUEIDENTIFIER
AS EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.ServerApi].[StopOperationInternal]

