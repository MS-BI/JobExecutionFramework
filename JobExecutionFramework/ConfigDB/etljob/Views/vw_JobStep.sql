



CREATE VIEW [etljob].[vw_JobStep]
AS
SELECT [JobStepID]
	,[JobStep]
	,[JobID]
	,[ApplicationID]
	,[GroupID]
	,[PackageID]
	,[ClientID]
	,[LayerID]
	,[MetaGroupID]
	,[StepNo]
	,[IsEnabled]
	,[IsNotCritical]
	,[IsWithGrabConnectionString]
	,[DateInserted]
FROM [etljob].[JobStep]
