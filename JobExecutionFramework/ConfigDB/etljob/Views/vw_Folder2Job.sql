






CREATE VIEW [etljob].[vw_Folder2Job]
AS
SELECT f2j.[Folder2JobID]
	,Coalesce(p.FolderID, f2j.[FolderID]) AS FolderID
	,f2j.[ProjectID]
	,f2j.[PackageMask]
	,f2j.[JobID]
	,f2j.[LayerID]
	,f2j.[ApplicationID]
	,f2j.[GroupID]
	,f2j.[MetaGroupID]
	,f2j.IsSettingEnabled
	,f2j.[FolderID] as PersistedFolderID
	,f2j.[IsFrozen]
	,f2j.[IsActive]
FROM [etljob].[Folder2Job] f2j
LEFT JOIN [etljob].[vw_project] p ON f2j.ProjectID = p.ProjectID