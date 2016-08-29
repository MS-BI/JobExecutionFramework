CREATE FUNCTION [internal].[convert_value]
(@origin_value SQL_VARIANT, @data_type NVARCHAR (128))
RETURNS SQL_VARIANT
AS
 EXTERNAL NAME [ISSERVER].[Microsoft.SqlServer.IntegrationServices.Server.ServerApi].[ConvertValue]

