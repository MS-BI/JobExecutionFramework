


CREATE VIEW [etljob].[vw_ParameterValue]
AS
SELECT pv.[ParameterValueID]
	,pv.[ParameterID]
	,pv.[ParameterValueObjectID]
	,pv.[ParameterValueLevelID]
	,pv.[SystemID]
	,CASE p.[DataType]
		WHEN 'nvarchar'
			THEN convert(SQL_VARIANT, convert(NVARCHAR(4000), pv.[ParameterValue]))
		ELSE pv.[ParameterValue]
		END AS [ParameterValue]
	,pv.[IsActive]
FROM [etljob].[ParameterValue] pv
INNER JOIN [etljob].[vw_Parameter] p ON p.ParameterID = pv.ParameterID