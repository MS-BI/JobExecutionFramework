-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-06-25
-- Description: Returns Packackes in Queue for Job with executionID @JobExecutionID 
-- that have Constraining Package that are not successfully finished.
--
-- Constrains where the Constraining JobStep is not part of the current Job are not evaluated
--
-- Change 09.12.2014:
-- Check for Exclusion by JobStepCluster
-- =============================================
CREATE FUNCTION [etljob].[fn_BlockedJobSteps] (@JobExecutionID BIGINT)
	/* Has Constrain that is not finished*/
RETURNS TABLE
AS
RETURN (
		SELECT Candidates.JobStepExecutionID
		FROM [etljob].vw_JobStepExecution AS Candidates
		INNER JOIN [etljob].vw_JobStep AS JobStepCandidate ON Candidates.JobStepID = JobStepCandidate.JobStepID
		INNER JOIN [etljob].vw_JobStepConstrain AS Constrain ON JobStepCandidate.JobStepID = Constrain.JobStepID
		INNER JOIN [etljob].vw_JobStep AS JobStepConstrains ON Constrain.Constrain_JobStepID = JobStepConstrains.JobStepID
		INNER JOIN [etljob].vw_JobStepExecution AS ConstrainingExecuitions ON JobStepConstrains.JobStepID = ConstrainingExecuitions.JobStepID
			AND Candidates.JobExecutionID = ConstrainingExecuitions.JobExecutionID
		LEFT OUTER JOIN SSIS.vw_executions AS Execs ON ConstrainingExecuitions.SSISExecutionID = Execs.execution_id  -- Refacture!
			AND (
				Execs.STATUS = 7 -- Succeeded   -- Refacture!
				OR Execs.STATUS = 9 -- Completed
				)
		WHERE (Candidates.JobExecutionID = @JobExecutionID)
			AND (Candidates.StartTime IS NULL)
			AND (Execs.execution_id IS NULL)
		Union
		SELECT Candidates.JobStepExecutionID
		FROM [etljob].vw_JobStepExecution AS Candidates
		INNER JOIN [etljob].vw_JobExecution as CandidatesJob on Candidates.JobID = CandidatesJob.JobID
		INNER JOIN [etljob].vw_Exclusion AS Exclusion on Exclusion.JobStepClusterID_Candidate = CandidatesJob.JobStepClusterID
		INNER JOIN [etljob].vw_JobExecution as RunningJob on Exclusion.JobStepClusterID_Running = RunningJob.JobStepClusterID
			AND NOT RunningJob.StartTime IS NULL
			AND RunningJob.EndTime IS NULL
		WHERE (Candidates.JobExecutionID = @JobExecutionID)
			AND (Candidates.StartTime IS NULL)
		)