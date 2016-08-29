

-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-02-24
-- Description: Gets Updates and New enties for Packages from SSISDB
-- =============================================
CREATE PROCEDURE [etljob].[prc_GetSSISDBPackages]
AS
SET NOCOUNT ON

MERGE INTO [etljob].[Package] AS target
USING (
	SELECT    SSISDBPackages.package_id AS SSISDBPackage_id, Projects.ProjectID, SSISDBPackages.name AS Packagename
FROM        ssis.projects AS SSISDBprojects INNER JOIN
                  etljob.Project AS Projects ON SSISDBprojects.project_id = Projects.SSISDBProject_ID INNER JOIN
                  ssis.packages AS SSISDBPackages ON SSISDBprojects.project_id = SSISDBPackages.project_id
	) AS source(SSISDBPackage_id, ProjectID,Packagename)
	ON target.PackageName = source.PackageName
		AND source.ProjectID = target.ProjectID
WHEN MATCHED
	THEN
		UPDATE
		SET [SSISDBPackage_ID] = source.SSISDBPackage_ID,
		DateDeleted = NULL
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			PackageName
			,[SSISDBPackage_ID]
			,ProjectID
			)
		VALUES (
			source.PackageName
			,source.[SSISDBPackage_ID]
			,source.ProjectID
			)
WHEN NOT MATCHED BY SOURCE
	AND target.DateDeleted IS NULL
	THEN
		UPDATE
		SET DateDeleted = GetDate();