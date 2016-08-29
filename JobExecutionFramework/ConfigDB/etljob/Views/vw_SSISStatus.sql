
CREATE View [etljob].[vw_SSISStatus]
AS
SELECT [SSISStatusID]
      ,[SSISStatus]
      ,[StatusDescription]
      ,[IsFailed]
      ,[IsBlocking]
	  ,IsFrameworkInternal
	  ,IsDone
FROM [etljob].[SSISStatus]