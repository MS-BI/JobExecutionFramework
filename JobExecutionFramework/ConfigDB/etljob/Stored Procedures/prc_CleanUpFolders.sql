
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-02-23
-- Description: Deletes entries for Folders not in SSISDB
-- =============================================
CREATE PROCEDURE [etljob].[prc_CleanUpFolders]
AS
SET NOCOUNT ON

MERGE INTO [etljob].[Folder] AS target
USING (
	SELECT folder_id
		,NAME
	FROM [ssis].[folders]
	) AS source(SSISDBFolder_id, FolderName)
	ON target.Foldername = source.FolderName
WHEN NOT MATCHED BY SOURCE
	THEN DELETE;