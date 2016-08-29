-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-02-25
-- Description: Lists Parameters belonging to JobStepID together with Design Defaults (from SSISDB)
--		Includes reference to connected package, project, folder and if possible application
--		Ignores Connection Managers "CM." When step has IsWithGrabConnectionString set, the connection string is included
-- Changed 2015-03-06; CS: Added ProjectID in Folder2Job -> Per F2J.JobID:
--						   If ProjectID is Empty in F2J and for Folder no Other line (with not Null ProjectID) Just link by Folder ID
--						   If ProjectID is Not Null, ignore possible other line with ProjectID Null
--						   Handled by FilterMustBeOne
--	Important: IsActive in F2J is ignored
-- =============================================
CREATE VIEW [etljob].[vw_ParameterForJobStep]
AS
WITH cte2BeFiltered -- Row_number() cannot be used in Filter -> hide with cte
AS (
	SELECT jst.JobStepID
		,pck.PackageID
		,prj.ProjectID
		,prj.FolderID
		,COALESCE(jst.ApplicationID, F2J.ApplicationID, 0) AS ApplicationID --Application in Table JobStep wins
		,pck.PackageName
		,p.parameter_name
		,prj.ProjectName
		,p.parameter_id
		,p.project_id
		,p.object_type
		,p.object_name
		,p.data_type
		,d.[SQL_ServerType]
		,p.required
		,p.sensitive
		,p.description
		,p.design_default_value
		,p.default_value
		,p.value_type
		,p.value_set
		,p.referenced_variable_name
		,p.validation_status
		,p.last_validation_time
		,vwp.ParameterID
		,jst.IsEnabled
		,lvl.ParameterValueLevelID AS SSISDB_ParameterValueLevelID
		,CASE lvl.ParameterValueLevelName
			WHEN N'Package'
				THEN pck.PackageID
			WHEN N'Project'
				THEN prj.ProjectID
			ELSE 0
			END AS SSISDB_ObjectID
		,row_number() OVER (
			PARTITION BY jst.JobStepID
			,vwp.ParameterID ORDER BY Coalesce(f2j.ProjectID, 0) DESC
			) AS FilterMustBeOne
	FROM etljob.vw_JobStep AS jst
	INNER JOIN etljob.vw_Package AS pck
		ON jst.PackageID = pck.PackageID
	INNER JOIN etljob.vw_project AS prj
		ON pck.ProjectID = prj.ProjectID
	INNER JOIN ssis.object_parameters p
		ON p.project_id = prj.SSISDBProject_ID
			AND (
				(p.object_name = pck.PackageName)
				AND (
					NOT (p.parameter_name LIKE N'CM.%')
					OR (
						p.parameter_name LIKE N'%.ConnectionString'
						AND jst.IsWithGrabConnectionString <> 0
						)
					)
				AND (p.object_type = 30)
				OR (
					NOT (p.parameter_name LIKE N'CM.%')
					OR (
						p.parameter_name LIKE N'%.ConnectionString'
						AND jst.IsWithGrabConnectionString <> 0
						)
					)
				AND (p.object_type = 20)
				)
	LEFT JOIN etljob.vw_Folder2Job AS F2J
		ON CASE 
				WHEN F2J.PersistedFolderID IS NULL
					THEN prj.ProjectID
				ELSE prj.FolderID
				END = CASE 
				WHEN F2J.PersistedFolderID IS NULL
					THEN F2J.ProjectID
				ELSE F2J.FolderID
				END
			AND jst.JobID = F2J.JobID
	LEFT JOIN [etljob].[vw_DataTypeLookUp] d
		ON p.data_type = d.[SSISDB_Type]
	LEFT JOIN [etljob].[vw_Parameter] vwp
		ON vwp.ParameterName = p.parameter_name
			AND vwp.DataTypeSSISDB = p.data_type
	LEFT JOIN [etljob].[vw_ParameterValueLevel] lvl
		ON lvl.SSIS_Object_type = p.object_type
			AND vwp.DataTypeSSISDB = p.data_type
	)
SELECT [JobStepID]
	,[PackageID]
	,[ProjectID]
	,[FolderID]
	,[ApplicationID]
	,[PackageName]
	,[parameter_name]
	,[ProjectName]
	,[parameter_id]
	,[project_id]
	,[object_type]
	,[object_name]
	,[data_type]
	,[SQL_ServerType]
	,[required]
	,[sensitive]
	,[description]
	,[design_default_value]
	,[default_value]
	,[value_type]
	,[value_set]
	,[referenced_variable_name]
	,[validation_status]
	,[last_validation_time]
	,[ParameterID]
	,[IsEnabled]
	,[SSISDB_ParameterValueLevelID]
	,[SSISDB_ObjectID]
FROM cte2BeFiltered
WHERE [FilterMustBeOne] = 1
