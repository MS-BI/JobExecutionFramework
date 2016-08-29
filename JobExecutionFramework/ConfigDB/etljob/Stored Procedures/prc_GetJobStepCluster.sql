-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-07-30
-- Description: Gets name of JobStepCluster for mail in Master Package
-- Modified 2014-12-12
-- Adding missing Cluster to table
-- =============================================
CREATE PROCEDURE [etljob].[prc_GetJobStepCluster] @JobID INT = 0
	,@ApplicationID INT = 0
	,@LayerID INT = 0
	,@GroupID INT = 0
	,@MetaGroupID INT = 0
	,@StepNo INT = 0
	,@StepNoEqual INT = 0
AS
SET NOCOUNT ON

MERGE INTO [etljob].[JobStepCluster] AS target
USING (
	SELECT @JobID
		,@ApplicationID
		,@LayerID
		,@GroupID
		,@MetaGroupID
		,@StepNo
		,@StepNoEqual
	) AS source(JobID, ApplicationID, LayerID, GroupID, MetaGroupID, StepNo, StepNoEqual)
	ON target.JobID = source.JobID
		AND target.ApplicationID = source.ApplicationID
		AND target.LayerID = source.LayerID
		AND target.GroupID = source.GroupID
		AND target.MetaGroupID = source.MetaGroupID
		AND target.StepNo = source.StepNo
		AND target.StepNoEqual = source.StepNoEqual
WHEN NOT MATCHED
	THEN
		INSERT (
			JobID
			,ApplicationID
			,LayerID
			,GroupID
			,MetaGroupID
			,StepNo
			,StepNoEqual
			,JobStepCluster
			)
		VALUES (
			source.JobID
			,source.ApplicationID
			,source.LayerID
			,source.GroupID
			,source.MetaGroupID
			,source.StepNo
			,source.StepNoEqual
			,Cast(source.JobID AS NVARCHAR(10)) + '_' + Cast(source.ApplicationID AS NVARCHAR(10)) + '_' + Cast(source.LayerID AS NVARCHAR(10)) + '_' + Cast(source.GroupID AS NVARCHAR(10)) + '_' + Cast(source.MetaGroupID AS NVARCHAR(10)) + '_' + Cast(source.StepNo AS NVARCHAR(10)) + '_' + Cast(source.StepNoEqual AS NVARCHAR(10))
			)
WHEN MATCHED
	THEN
		UPDATE
		SET LastRun = getdate()
OUTPUT inserted.[JobStepClusterID], inserted.JobStepCluster;