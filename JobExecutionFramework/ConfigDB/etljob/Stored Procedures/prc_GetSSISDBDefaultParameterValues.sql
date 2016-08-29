

-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-02-27
-- Description: Gets  New Default entries for Parameter Values from SSISDB
-- =============================================
CREATE PROCEDURE [etljob].[prc_GetSSISDBDefaultParameterValues] @SystemID INT = 0
AS
SET NOCOUNT ON

MERGE INTO [etljob].[ParameterValue] AS target
USING (
	SELECT DISTINCT Coalesce(All_ParameterValueLevelID, 0) -- Loweset level with Standard Value for this JobStep
		,[design_default_value]
		,Coalesce([All_ObjectID], 0) -- ObjectID for this loweset level with Standard Value for this JobStep
		,[ParameterID]
		,[SSISDB_ParameterValueLevelID]
		,[SSISDB_ObjectID]
	FROM [etljob].[vw_ParameterValuesForJobStep]
	) AS source([ParameterValueLevelID], ParameterValue, ParameterValueObjectID, ParameterID,SSISDB_ParameterValueLevelID,SSISDB_ObjectID)
	ON target.ParameterID = source.ParameterID 
	AND target.ParameterValueObjectID = source.ParameterValueObjectID
	AND target.ParameterValueLevelID = source.ParameterValueLevelID
WHEN NOT MATCHED
	THEN
		INSERT (
			[ParameterValueObjectID]
			,[ParameterValueLevelID]
			,[SystemID]
			,[ParameterID]
			,[ParameterValue]
			,[IsActive]
			)
		VALUES (
			source.SSISDB_ObjectID -- If new than like in SSISDB
			,source.SSISDB_ParameterValueLevelID
			,@SystemID
			,source.ParameterID
			,source.[ParameterValue]
			,0
			)
			/*WHEN NOT MATCHED BY SOURCE
	THEN
		DELETE*/;