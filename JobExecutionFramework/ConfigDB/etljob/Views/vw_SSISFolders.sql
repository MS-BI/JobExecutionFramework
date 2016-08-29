CREATE VIEW [etljob].vw_SSISFolders
AS
SELECT [folder_id]
	,[name]
	,[description]
	,[created_by_sid]
	,[created_by_name]
	,[created_time]
FROM ssis.Folders