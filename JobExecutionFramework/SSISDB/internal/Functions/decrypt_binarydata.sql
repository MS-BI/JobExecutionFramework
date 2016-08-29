CREATE FUNCTION [internal].[decrypt_binarydata]
(@algorithmName NVARCHAR (255), @key VARBINARY (8000), @IV VARBINARY (8000), @binary_value VARBINARY (MAX))
RETURNS VARBINARY (MAX)
AS
 EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.Security.CryptoGraphy].[DecryptBinaryData]

