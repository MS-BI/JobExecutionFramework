

-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-02-23
-- Description: Deletes entries for Projects not in SSISDB
-- =============================================
CREATE PROCEDURE [etljob].[prc_CleanUpProjects]
AS
SET NOCOUNT ON

MERGE INTO [etljob].[Project] AS target
USING (
	SELECT projects.project_id
		,folders.FolderID
		,projects.NAME AS Projectname
	FROM ssis.folders AS SSISFolders
	INNER JOIN ssis.projects AS projects ON SSISFolders.folder_id = projects.folder_id
	INNER JOIN etljob.vw_Folder AS folders ON SSISFolders.folder_id = folders.SSISDBFolder_ID
	) AS source(SSISDBProject_id, FolderID, ProjectName)
	ON target.Projectname = source.ProjectName
		AND source.FolderID = target.FolderID
WHEN NOT MATCHED BY SOURCE
	THEN DELETE;