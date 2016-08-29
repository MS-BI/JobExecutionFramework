-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-06-25
-- Description: Counts packages Started by specified Job and all packages running in project mode
-- Changes:
--			 CS: 2015-09-01: Do Not Count own Master Package with Global Running
-- ToDo: Eliminate explicit reference to SSISDB, Status Check by Field in etljob.SSISStatus
-- =============================================
CREATE PROC [etljob].[prc_RunningPackages] @JobExecutionID AS INT = 0
AS
SET NOCOUNT ON;

DECLARE @MasterSSISExecutionID AS BIGINT

SELECT @MasterSSISExecutionID = [SSISExecutionID]
FROM [etljob].[JobStepExecution]
WHERE [JobExecutionID] = @JobExecutionID

SELECT (
		SELECT COUNT(*) AS RunningLocal
		FROM [etljob].[vw_JobStepExecution] AS Q
		WHERE SSISExecutionID NOT IN (
				SELECT execution_id
				FROM [SSISDB].[catalog].[executions]
				WHERE execution_id IN (
						SELECT [SSISExecutionID]
						FROM [etljob].[JobStep]
						WHERE STATUS IN (
								-- Refactore
								3
								,4
								,6
								,7
								,9
								)
						)
				)
			AND NOT [StartTime] IS NULL
			AND NOT SSISExecutionID IS NULL
			AND JobExecutionID = @JobExecutionID
		) AS RunningLocal
	,(
		SELECT count(*)
		FROM [SSISDB].[catalog].[executions]
		WHERE STATUS NOT IN (
				1 -- Created (Could be Zombies) 2 is running
				,3 -- Canceled
				,4 -- Failed, 5 is pending
				,6 -- ended unexpectedly 
				,7 -- succeeded, 8 is stopping
				,9 -- completed
				)
			AND [execution_id] <> @MasterSSISExecutionID
		) AS RunningGlobal
