






-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-03-12
-- Description: Lists Parameters And their Configured Values for Package from the JobStep.
--		Includes the associated ApplicationID, FolderID, ProjectID etc.
--		Delivers one Rowe per system, so filtering maybe necessary
-- =============================================
CREATE VIEW [etljob].[vw_ParameterValuesForJobStep]
AS
SELECT p.[object_type]
	,p.[parameter_name]
	,p.[data_type]
	,p.[SQL_ServerType]
	,p.[required]
	,p.[design_default_value]
	,Coalesce(JST.ParameterValue, PKG.ParameterValue, PRJ.ParameterValue, FLD.ParameterValue, APP.ParameterValue) AS Val
	,JST.ParameterValue AS ParameterValue_JST
	,PKG.ParameterValue AS ParameterValue_PKG
	,PRJ.ParameterValue AS ParameterValue_PRJ
	,FLD.ParameterValue AS ParameterValue_FLD
	,APP.ParameterValue AS ParameterValue_APP
	,p.[JobStepID]
	,Coalesce(JST.SystemID, PKG.SystemID, PRJ.SystemID, FLD.SystemID, APP.SystemID,0) AS SystemID
	,JST.SystemID AS SystemID_JST
	,PKG.SystemID AS SystemID_PKG
	,PRJ.SystemID AS SystemID_PRJ
	,FLD.SystemID AS SystemID_FLD
	,APP.SystemID AS SystemID_APP
	,p.ParameterID
	,p.ApplicationID
	,p.FolderID
	,p.ProjectID
	,p.PackageID
	,Coalesce(JST.[Order], PKG.[Order], PRJ.[Order], FLD.[Order], APP.[Order]) AS LevelOrderNo
	,Coalesce(JST.[ParameterValueLevelID], PKG.[ParameterValueLevelID], PRJ.[ParameterValueLevelID], FLD.[ParameterValueLevelID], APP.[ParameterValueLevelID]) AS ParameterValueLevelID
	,Coalesce(JST_ALL.[ParameterValueLevelID], PKG_ALL.[ParameterValueLevelID], PRJ_ALL.[ParameterValueLevelID], FLD_ALL.[ParameterValueLevelID], APP_ALL.[ParameterValueLevelID]) AS All_ParameterValueLevelID
	,Coalesce(JST.JobStepID,PKG.PackageID,PRJ.ProjectID,FLD.FolderID,APP.ApplicationID) as ObjectID
	,Coalesce(JST_ALL.JobStepID,PKG_ALL.PackageID,PRJ_ALL.ProjectID,FLD_ALL.FolderID,APP_ALL.ApplicationID) as All_ObjectID
	,p.SSISDB_ParameterValueLevelID
	,p.[SSISDB_ObjectID]
FROM [etljob].[vw_ParameterForJobStep] p
LEFT JOIN [etljob].[vw_ParameterValueJobStep] JST ON p.ParameterID = JST.ParameterID
	AND JST.Isactive = 1
	AND p.JobStepID = JST.JobStepID
LEFT JOIN [etljob].[vw_ParameterValuePackage] PKG ON p.ParameterID = PKG.ParameterID
	AND PKG.Isactive = 1
	AND p.PackageID = PKG.PackageID
LEFT JOIN [etljob].[vw_ParameterValueProject] PRJ ON p.ParameterID = PRJ.ParameterID
	AND PRJ.Isactive = 1
	AND p.ProjectID = PRJ.ProjectID
LEFT JOIN [etljob].[vw_ParameterValueFolder] FLD ON p.ParameterID = FLD.ParameterID
	AND FLD.Isactive = 1
	AND p.FolderID = FLD.FolderID
LEFT JOIN [etljob].[vw_ParameterValueApplication] APP ON p.ParameterID = APP.ParameterID
	AND APP.Isactive = 1
	AND p.ApplicationID = APP.ApplicationID
LEFT JOIN [etljob].[vw_ParameterValueJobStep] JST_ALL ON p.ParameterID = JST_ALL.ParameterID
	AND p.JobStepID = JST_ALL.JobStepID
LEFT JOIN [etljob].[vw_ParameterValuePackage] PKG_ALL ON p.ParameterID = PKG_ALL.ParameterID
	AND p.PackageID = PKG_ALL.PackageID
LEFT JOIN [etljob].[vw_ParameterValueProject] PRJ_ALL ON p.ParameterID = PRJ_ALL.ParameterID
	AND p.ProjectID = PRJ_ALL.ProjectID
LEFT JOIN [etljob].[vw_ParameterValueFolder] FLD_ALL ON p.ParameterID = FLD_ALL.ParameterID
	AND p.FolderID = FLD_ALL.FolderID
LEFT JOIN [etljob].[vw_ParameterValueApplication] APP_ALL ON p.ParameterID = APP_ALL.ParameterID
	AND p.ApplicationID = APP_ALL.ApplicationID