
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-02-23
-- Description: Gets Updates and New entries for Folders from SSISDB
-- =============================================
CREATE PROCEDURE [etljob].[prc_GetSSISDBFolders]
AS
SET NOCOUNT ON

MERGE INTO [etljob].[Folder] AS target
USING (
	SELECT folder_id
		,NAME
	FROM [ssis].[folders]
	) AS source(SSISDBFolder_id, FolderName)
	ON target.Foldername = source.FolderName
WHEN NOT MATCHED
	THEN
		INSERT (
			Foldername
			,[SSISDBFolder_ID]
			)
		VALUES (
			source.FolderName
			,source.SSISDBFolder_id
			)
WHEN MATCHED
	THEN
		UPDATE
		SET [SSISDBFolder_ID] = source.SSISDBFolder_id,
		DateDeleted = NULL
WHEN NOT MATCHED BY SOURCE
	AND target.DateDeleted IS NULL
	THEN
		UPDATE
		SET DateDeleted = GetDate();