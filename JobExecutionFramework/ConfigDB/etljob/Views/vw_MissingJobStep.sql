







-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck, "CS")
-- Create date: 2014-07-16
-- Description: Detect missing Standard Job Steps
-- Changed 2015-02-24; CS: Added Use View vw_Folder2Job for further configuration options
-- Changed 2015-03-05; CS: Added ProjectID in Folder2Job -> Per F2J.JobID:
--						   If ProjectID is Empty in F2J and for Folder no Other line (with not Null ProjectID) Just link by Folder ID
--						   If ProjectID is Not Null, ignore possible line with ProjectID Null
--						   Handled by FilterMustBeOne
-- Changed 2015-03-09; CS: Added IsFrozen and PackageMask in Folder2Job and MaxNoOfJobs in [etljob].[Package]
--							If IsFrozen = 1 then only Packages not in JobStep at all will be shown
--							If MaxNoOfJobs <> 0 and at least MaxNoOfJobs Jobs contain Package the package will not be shown
--							If PackageMask is not NULL, it filters Packages
-- Changed 2015-09-01; CS: Bug with IsFrozenHandling (dubble "NOT" removed)
-- Hint: in the F2J table Folder + Project + Job are unique -> different configurations are possible (for different jobs)
-- =============================================
CREATE VIEW [etljob].[vw_MissingJobStep]
AS
WITH cte2BeFiltered -- Row_number() cannot be used in Filter -> hide with cte
AS (
	SELECT Pck.PackageID
		,Pck.PackageName AS JobStep
		,F2J.JobID
		,F2J.ApplicationID
		,F2J.GroupID
		,coalesce(F2J.LayerID, Layer.LayerID) AS LayerID -- F2J beats package prefix
		,F2J.MetaGroupID
		,F2J.IsSettingEnabled AS IsEnabled
		,F2J.[FolderID]
		,F2J.[ProjectID]
		,(
			SELECT coalesce(max(StepNo), 0)
			FROM [etljob].vw_JobStep
			WHERE [etljob].vw_JobStep.JobID = 1
			) + Row_Number() OVER (
			ORDER BY Pck.PackageID
			) AS StepNo
		,row_number() OVER (
			PARTITION BY F2J.JobID
			,pck.PackageID ORDER BY Coalesce(f2j.ProjectID, 0) DESC
			) AS FilterMustBeOne
	FROM etljob.vw_Package AS Pck
	INNER JOIN etljob.vw_project AS prj ON Pck.ProjectID = prj.ProjectID
	INNER JOIN etljob.vw_Folder2Job AS F2J ON CASE
			WHEN  F2J.PersistedFolderID IS NULL
				THEN prj.ProjectID
			ELSE prj.FolderID
			END = CASE
			WHEN F2J.PersistedFolderID IS NULL
				THEN F2J.ProjectID
			ELSE F2J.FolderID
			END
	LEFT JOIN etljob.vw_JobStep AS JobStp ON F2J.JobID = JobStp.JobID
		AND Pck.PackageID = JobStp.PackageID
	LEFT JOIN etljob.vw_Layer AS Layer ON Pck.PackageName LIKE Layer.PackagePrefix + '%'
	WHERE (
			JobStp.JobStepID IS NULL
			AND F2J.IsActive <>0
			AND (F2J.PackageMask IS NULL OR Pck.PackageName like F2J.PackageMask)
			AND NOT (
				F2J.IsFrozen <> 0
				AND Pck.PackageID IN (
					SELECT PackageID
					FROM etljob.vw_JobStep AS JobStp_1
					)
				)
			)
		AND (
			Pck.[MaxNoOfJobs] = 0
			OR NOT Coalesce((
					SELECT COUNT(JobStp_2.PackageID)
					FROM etljob.vw_JobStep AS JobStp_2
					WHERE JobStp_2.PackageID = Pck.PackageID
					), 0) >= Pck.[MaxNoOfJobs]
			)
	)
SELECT [PackageID]
	,[JobStep]
	,[JobID]
	,[ApplicationID]
	,[GroupID]
	,[LayerID]
	,[MetaGroupID]
	,[IsEnabled]
	,[FolderID]
	,[ProjectID]
	,[StepNo]
FROM cte2BeFiltered
WHERE FilterMustBeOne = 1
