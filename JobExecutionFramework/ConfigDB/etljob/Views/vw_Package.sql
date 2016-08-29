




CREATE VIEW [etljob].[vw_Package]
AS
SELECT [PackageID]
	,[ProjectID]
	,[PackageName]
	,[MaxNoOfJobs]
FROM [etljob].[Package]
WHERE DateDeleted is NULL
