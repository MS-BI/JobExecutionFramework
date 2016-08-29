-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-12-12
-- Description: Checks if there are Jobs which failed on which the current Job depends
-- or if the Job failed in the previous run. If Configuration says so (do not retry etc.)
-- all steps are canceled
-- =============================================

CREATE PROCEDURE [etljob].[prc_CheckJobDependencies] @JobExecutionID INT
AS
SET NOCOUNT ON

DECLARE @Blocked INT

SELECT @Blocked = COUNT(ClusterToCheck.JobStepClusterID)
FROM etljob.vw_JobExecution AS Job
INNER JOIN etljob.vw_JobStepCluster AS ClusterToCheck ON Job.JobStepClusterID = ClusterToCheck.JobStepClusterID
LEFT JOIN etljob.vw_JobStepClusterConstrain AS Constrains
INNER JOIN etljob.vw_JobStepCluster AS ClusterConstraining ON Constrains.ConstrainJobStepClusterID = ClusterConstraining.JobStepClusterID ON ClusterToCheck.JobStepClusterID = Constrains.JobStepClusterID
	AND Constrains.IsDisabled = 0
WHERE (NOT (ClusterConstraining.FailedJobExecutionID IS NULL)
	OR ((ClusterToCheck.Retry = 0)
	AND (NOT (ClusterToCheck.FailedJobExecutionID IS NULL))))
	AND Job.JobExecutionID = @JobExecutionID
If @Blocked > 0
Begin
	BEGIN TRY
		UPDATE Steps
		SET [ETLStatusID] = 3 -- Canceled
			,[Message] = 'Job Blocked'
		FROM [etljob].[vw_JobStepExecution] Steps
		WHERE [JobExecutionID] = @JobExecutionID

		UPDATE Job
		SET [IsBlocked] = @Blocked
		FROM [etljob].[vw_JobExecution] Job
		WHERE [JobExecutionID] = @JobExecutionID
	END TRY

	BEGIN CATCH
	END CATCH
End

RETURN @Blocked