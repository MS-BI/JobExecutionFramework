
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-06-25
-- Updates Infos in JobStepExecution
-- =============================================
CREATE PROCEDURE [etljob].[prc_UpdateJobStepExecution] @JobExecutionID AS INT
AS
SET NOCOUNT ON

DECLARE @OutTbl AS TABLE (
	JobStepExecutionID INT
	,SSIStatusID INT
	,EndTime DATETIME2
	);

INSERT INTO @OutTbl (
	JobStepExecutionID
	,SSIStatusID
	,EndTime
	)
SELECT [JobStepExecutionID]
	,ETLStatusID
	,EndTime
FROM (
	UPDATE Ex
	SET Ex.EndTime = ExSSIS.end_time
		,Ex.ETLStatusID = ExSSIS.STATUS
	OUTPUT inserted.[JobStepExecutionID]
		,inserted.[ETLStatusID]
		,inserted.[EndTime]
	FROM ssis.vw_executions ExSSIS
	INNER JOIN [etljob].vw_JobStepExecution Ex ON ExSSIS.execution_id = Ex.SSISExecutionID
	WHERE (Ex.EndTime IS NULL)
		AND Ex.JobExecutionID = @JobExecutionID
		AND COALESCE(Ex.ETLStatusSource, 0) = 0
	) AS X
-- Update depending JobSteps in case of not critical failures
UPDATE JstExDep
SET JstExDep.[ETLStatusID] = 3
	,JstExDep.[StartTime] = tmp.EndTime
	,JstExDep.[EndTime] = tmp.EndTime
FROM [etljob].[vw_JobStepExecution] JstEx
INNER JOIN @OutTbl tmp ON JstEx.JobStepExecutionID = tmp.JobStepExecutionID
CROSS APPLY [etljob].[fn_GetDependingJobSteps](JstEx.JobStepID) Dep
INNER JOIN [etljob].[vw_JobStepExecution] JstExDep ON JstExDep.JobStepID = Dep.JobStepID
	AND JstExDep.JobExecutionID = JstEx.JobExecutionID
	Where tmp.SSIStatusID in
	(select [SSISStatusID] From [etljob].[vw_SSISStatus] where [IsFailed] <>0)