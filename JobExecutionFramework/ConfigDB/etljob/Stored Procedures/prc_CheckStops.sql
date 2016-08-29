
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-05-19
-- Description:  Checks if there is an active Stop or an active Recovery
-- If there is a stop, the Job is stopped
-- If there is no stop but a recovery and @StopRecoveryID = 0 (=>the current Job is not executed as Part of a recovery),
--		the Job is Stopped
--
-- StopMode: 1: Entire Job is skipped, SP is called at MasterPackage Start
--			 2: Job was started, and Stop detected later
-- =============================================
CREATE PROCEDURE [etljob].[prc_CheckStops] @JobExecutionID INT
	,@StopRecoveryID INT
	,@StopMode INT = 1
AS
SET NOCOUNT ON

DECLARE @CurrentStopID INT
	,@CurrentRecoveryID INT

-- System in Stop State: There Exists one active Stop with Current time between its Start and Stop
-- System in Recovery State: Not in Stop State And there exists an active Stop with coalesce(end,start)
--		(and thus start) prior to current time
--		and RecoveryEnd not set
-- @StopMode: 1: Skip Whole Job (At Start of masterPackage), 2: Stop Job, Skip remaining Steps (checked before GetNextPackage)
SELECT TOP (1) @CurrentStopID = Coalesce([StopID], 0)
FROM [etljob].[vw_Stop] AS Stops
INNER JOIN [etljob].[vw_JobExecution] AS JobExec
	ON JobExec.[JobExecutionID] = @JobExecutionID
LEFT OUTER JOIN [etljob].[vw_JobStepCluster] AS Cluster
	ON Cluster.JobStepClusterID = JobExec.JobStepClusterID
WHERE dateadd(minute, Coalesce(Cluster.[ExpectedRunTime], 0), /*JobExec.[StartTime]*/ Getdate()) >= Stops.[StopStart]
	AND JobExec.[StartTime] < Coalesce(Stops.[RecoveryEnd], Stops.[StopEnd], DateAdd(yy, 10, Getdate()))
	AND Stops.[IsEnabled] <> 0
ORDER BY Coalesce(Stops.[StopEnd], DateAdd(yy, 10, Getdate())) DESC

SELECT TOP (1) @CurrentRecoveryID = Coalesce([StopID], 0)
FROM [etljob].[vw_Stop] AS Stops
INNER JOIN [etljob].[vw_JobExecution] AS JobExec
	ON JobExec.[JobExecutionID] = @JobExecutionID
LEFT OUTER JOIN [etljob].[vw_JobStepCluster] AS Cluster
	ON Cluster.JobStepClusterID = JobExec.JobStepClusterID
WHERE  /*JobExec.[StartTime]*/ Getdate() >= Coalesce(Stops.[StopEnd], DateAdd(yy, 10, Getdate()))
	AND (
		 /*JobExec.[StartTime]*/ Getdate() < Stops.[RecoveryEnd]
		OR Stops.[RecoveryEnd] IS NULL
		)
	AND Stops.[IsEnabled] <> 0
ORDER BY Coalesce(Stops.[StopEnd], DateAdd(yy, 10, Getdate())) DESC

SELECT @CurrentStopID = Coalesce(@CurrentStopID, 0)

SELECT @CurrentRecoveryID = Coalesce(@CurrentRecoveryID, 0)

IF @CurrentStopID <> 0
BEGIN
	UPDATE [etljob].[vw_JobStepExecution]
	SET [ETLStatusID] = 10
	WHERE [JobExecutionID] = @JobExecutionID
		AND [StartTime] IS NULL

	UPDATE [etljob].[vw_JobExecution]
	SET [StoppedByStopID] = @CurrentStopID
		,[StopMode] = @StopMode
	WHERE [JobExecutionID] = @JobExecutionID
	AND [StopMode] = 0

	SELECT @CurrentStopID AS StopID
		,0 AS RecoveryID
		,1 AS Stopped

	RETURN - 1
END
ELSE IF @CurrentRecoveryID <> 0
	AND @StopRecoveryID = 0 -- Not called in recovera Mode?
BEGIN
	UPDATE [etljob].[vw_JobStepExecution]
	SET [ETLStatusID] = 10
	WHERE [JobExecutionID] = @JobExecutionID
		AND [StartTime] IS NULL

	UPDATE [etljob].[vw_JobExecution]
	SET [StoppedByStopID] = @CurrentRecoveryID -- @CurrentStopID
		,[StopMode] = @StopMode
	WHERE [JobExecutionID] = @JobExecutionID
	AND [StopMode] = 0

	SELECT 0 AS StopID
		,@CurrentRecoveryID AS RecoveryID
		,1 AS Stopped

	RETURN - 1
END

SELECT 0 AS StopID
	,@CurrentRecoveryID AS RecoveryID
	,0 AS Stopped

RETURN 0