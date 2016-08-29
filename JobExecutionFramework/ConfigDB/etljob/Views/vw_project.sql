CREATE VIEW [etljob].[vw_Project]
	AS
	SELECT [ProjectID]
		  ,[SSISDBProject_ID]
		  ,[FolderID]
		  ,[ProjectName]
		  ,[DateInserted]
	FROM [etljob].[Project]