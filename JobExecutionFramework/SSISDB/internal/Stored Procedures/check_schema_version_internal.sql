CREATE PROCEDURE [internal].[check_schema_version_internal]
@operationId BIGINT, @use32bitruntime SMALLINT, @serverBuild NVARCHAR (1024) OUTPUT, @schemaVersion INT OUTPUT, @schemaBuild NVARCHAR (1024) OUTPUT, @assemblyBuild NVARCHAR (1024) OUTPUT, @componentVersion NVARCHAR (1024) OUTPUT, @compatibilityStatus SMALLINT OUTPUT
AS EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.ServerApi].[CheckSchemaVersionInternal]

