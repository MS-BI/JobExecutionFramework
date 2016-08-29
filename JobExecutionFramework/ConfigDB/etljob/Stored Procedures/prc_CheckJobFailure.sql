
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-07-30
-- Description: Raises Error if Jobs Failed, Used to Fail SSIS Master Package in this case
-- Change 2014-12-12
-- Update JobStepCluster with Job Error Status, used for temporal disabling further runs
-- =============================================
CREATE PROCEDURE [etljob].[prc_CheckJobFailure] @JobExecutionID INT
AS
SET NOCOUNT ON

DECLARE @CntCritical INT
	,@CntAbnormal INT
	,@JobStepClusterID INT

SELECT @CntCritical = SUM(CriticalAbnormal)
		,@CntAbnormal = SUM(Abnormal)
FROM [etljob].[fn_StatusJobSteps](@JobExecutionID)

SELECT @JobStepClusterID = JobStepClusterID
FROM [etljob].vw_JobExecution Job
WHERE Job.JobExecutionID = @JobExecutionID

IF @CntCritical > 0
BEGIN
	UPDATE Cluster
	SET FailedJobExecutionID = Coalesce(@JobExecutionID, - 1)
	FROM [etljob].JobStepCluster Cluster
	WHERE JobStepClusterID = @JobStepClusterID

	RAISERROR (
			'Failed Packages'
			,16
			,1
			)
	select @CntCritical as Critical,@CntAbnormal as Abnormal
END
ELSE
BEGIN
	UPDATE Cluster
	SET FailedJobExecutionID = NULL
	FROM [etljob].JobStepCluster Cluster
	WHERE JobStepClusterID = @JobStepClusterID
	select @CntCritical as Critical,@CntAbnormal as Abnormal
END