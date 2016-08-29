CREATE VIEW [etljob].[vw_Exclusion]
AS
SELECT [ExclusionID]
	,[Exclusion]
	,JobStepClusterID_Candidate
	,JobStepClusterID_Running
FROM [etljob].[Exclusion]
