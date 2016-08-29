-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-02-24
-- Description: Copy New Packages to Standard Job in JobStep
-- Configuration via vw_Folder2Job
-- Steps referencing packages deleted in SSISDB are set to inactive
-- =============================================
CREATE PROCEDURE [etljob].[prc_SetStandardJobStep] 
AS
SET NOCOUNT ON

INSERT INTO [etljob].[JobStep] (
	[JobStep]
	,[JobID]
	,[ApplicationID]
	,[GroupID]
	,[PackageID]
	,[LayerID]
	,[MetaGroupID]
	,[StepNo]
	,[IsEnabled]
	)
SELECT [JobStep]
	,[JobID]
	,[ApplicationID]
	,[GroupID]
	,[PackageID]
	,[LayerID]
	,[MetaGroupID]
	,[StepNo]
	,[IsEnabled]
FROM [etljob].vw_MissingJobStep

UPDATE js
SET js.IsEnabled = 0
FROM [etljob].[vw_JobStep] js
LEFT OUTER JOIN [etljob].[vw_Package] pck ON js.PackageID = pck.PackageID
WHERE pck.PackageID IS NULL