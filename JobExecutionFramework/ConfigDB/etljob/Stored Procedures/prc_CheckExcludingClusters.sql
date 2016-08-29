
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-05-18
-- Description: Checks if there are JobStepClusters running, excluding the current Candidate
-- =============================================
CREATE PROCEDURE [etljob].[prc_CheckExcludingClusters] @JobClusterID INT
AS
SET NOCOUNT ON

SELECT COUNT(etljob.vw_JobExecution.JobStepClusterID) AS NumberOfExcluding
	,Max(etljob.vw_JobExecution.JobStepClusterID) MaxExcludingJobStepClusterID
FROM etljob.vw_JobExecution
INNER JOIN etljob.vw_JobStepClusterExclusion
	ON etljob.vw_JobExecution.JobStepClusterID = etljob.vw_JobStepClusterExclusion.JobStepClusterID
WHERE etljob.vw_JobExecution.EndTime IS NULL
	AND etljob.vw_JobStepClusterExclusion.ExclusionJobStepClusterID = @JobClusterID