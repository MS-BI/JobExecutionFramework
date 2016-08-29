CREATE VIEW [etljob].[vw_Folder]
AS
SELECT [FolderID]
      ,[SSISDBFolder_ID]
      ,[Foldername]
      ,[DateInserted]
  FROM [etljob].[Folder]