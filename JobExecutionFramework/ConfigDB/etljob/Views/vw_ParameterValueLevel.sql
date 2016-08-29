


CREATE VIEW [etljob].[vw_ParameterValueLevel]
as
SELECT [ParameterValueLevelID]
      ,[ParameterValueLevelName]
	  ,[SSIS_Object_type]
	  ,[Order]
FROM [etljob].[ParameterValueLevel]