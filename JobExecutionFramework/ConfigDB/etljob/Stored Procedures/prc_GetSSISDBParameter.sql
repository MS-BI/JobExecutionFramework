
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-02-25
-- Description: Gets Updates and New entries for Parameters from SSISDB
-- =============================================
CREATE PROCEDURE [etljob].[prc_GetSSISDBParameter]
AS
SET NOCOUNT ON

MERGE INTO [etljob].[Parameter] AS target
USING (
	SELECT parameter_name AS ParameterName
		,data_type AS ParameterDataType
		,dt.[SQL_ServerType]
	FROM ssis.object_parameters p
	LEFT JOIN [etljob].[vw_DataTypeLookUp] dt ON p.data_type = dt.[SSISDB_Type]
	--LEFT JOIN etljob.vw_Parameter vp ON p.parameter_name = vp.ParameterName
	--AND p.data_type = vp.DataTypeSSISDB
	WHERE (
			LEFT(parameter_name, 3) <> 'CM.'
			OR RIGHT(parameter_name, 17) = '.ConnectionString'
			)
	GROUP BY parameter_name
		,data_type
		,dt.[SQL_ServerType]
	) AS source(ParameterName, ParameterDataType, SQL_ServerType)
	ON target.ParameterName = source.ParameterName
		AND target.[DataTypeSSISDB] = source.ParameterDataType
WHEN NOT MATCHED
	THEN
		INSERT (
			[ParameterName]
			,[DataTypeSSISDB]
			,[DataType]
			)
		VALUES (
			source.ParameterName
			,source.ParameterDataType
			,source.SQL_ServerType
			)
WHEN MATCHED
	THEN
		UPDATE
		SET [DataType] = source.SQL_ServerType
			,DateDeleted = NULL
WHEN NOT MATCHED BY SOURCE
	AND target.DateDeleted IS NULL
	THEN
		UPDATE
		SET DateDeleted = GetDate();