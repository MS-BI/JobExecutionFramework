CREATE PROCEDURE [internal].[create_key_information]
@algorithm_name NVARCHAR (255), @key VARBINARY (8000) OUTPUT, @IV VARBINARY (8000) OUTPUT
AS EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.Security.CryptoGraphy].[CreateKeyInformation]

