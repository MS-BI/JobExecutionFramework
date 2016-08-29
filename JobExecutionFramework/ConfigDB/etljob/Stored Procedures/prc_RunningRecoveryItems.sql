-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-06-25
-- Description: Counts packages Started by specified Job and all packages running in project mode
-- ToDo: Eliminate explicit reference to SSISDB, Status Check by Field in etljob.SSISStatus
-- =============================================
CREATE PROC [etljob].[prc_RunningRecoveryItems] @RecoveryID AS INT = 0
AS
SET NOCOUNT ON;
SELECT (
		SELECT COUNT(*) AS RunningLocal
		FROM [etljob].[vw_RecoveryItem] AS Q
		WHERE SSISExecutionID NOT IN (
				SELECT execution_id
				FROM [SSISDB].[catalog].[executions]
				WHERE execution_id IN (
						SELECT [SSISExecutionID]
						FROM [etljob].[JobStep]
						WHERE STATUS IN (        -- Refactore
								1 -- Created (Could be Zombies) 2 is running
								,3 -- Canceled
								,4-- Failed, 5 is pending
								,6 -- ended unexpectedly 
								,7-- succeeded, 8 is stopping
								,9 -- completed
								)
						)
				)
			AND not  [RecoveryStart] is Null
			AND NOT SSISExecutionID IS NULL
			AND ExecRecoveryId = @RecoveryId
		) AS RunningLocal
	,(
		SELECT COUNT(*) AS RunningLocal
		FROM [etljob].[vw_RecoveryItem] AS Q
		WHERE SSISExecutionID NOT IN (
				SELECT execution_id
				FROM [SSISDB].[catalog].[executions]
				WHERE execution_id IN (
						SELECT [SSISExecutionID]
						FROM [etljob].[JobStep]
						WHERE STATUS IN (        -- Refactore
								1 -- Created (Could be Zombies) 2 is running
								,3 -- Canceled
								,4-- Failed, 5 is pending
								,6 -- ended unexpectedly 
								,7-- succeeded, 8 is stopping
								,9 -- completed
								)
						)
				)
			AND not  [RecoveryStart] is Null
			AND NOT SSISExecutionID IS NULL
		) AS RunningGlobal
