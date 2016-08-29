



CREATE View [etljob].[vw_ParameterValueJobStep]
AS
SELECT pv.[ParameterValueID]
      ,pv.[ParameterValueObjectID] as [JobStepID]
      ,pv.[SystemID]
      ,pv.[ParameterValue]
      ,pv.[IsActive]
	  ,pv.ParameterID
	  ,pv.ParameterValueLevelID
	  ,pvl.[Order]
FROM [etljob].[vw_ParameterValue] pv JOIN [etljob].[vw_ParameterValueLevel] pvl on pv.ParameterValueLevelID = pvl.ParameterValueLevelID
WHERE pvl.ParameterValueLevelName = 'JobStep'