
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-06-25
-- Description: Searches for  next Package in Queue for Job with executionID @JobExecutionID
-- If found there still will be checked if there were some critical Aborts
-- If none is found it is checked if blockings are the reason
-- =============================================
CREATE PROCEDURE [etljob].[prc_GetNextPackage] @JobExecutionID AS INT
	--,@SSISExecutionID AS BIGINT
AS
SET NOCOUNT ON;

/* Next in Queue */
DECLARE @OutTbl AS TABLE (JobStepExecutionID INT);

INSERT INTO @OutTbl (JobStepExecutionID)
SELECT [JobStepExecutionID]
FROM (
	UPDATE [etljob].[JobStepExecution]
	SET [StartTime] = GetDate()
	OUTPUT inserted.[JobStepExecutionID]
	WHERE [JobStepExecutionID] = (
			SELECT TOP 1 [JobStepExecutionID]
			FROM [etljob].[vw_JobStepExecution]
			WHERE StartTime IS NULL
				AND Coalesce(ETLStatusID,0) NOT IN (
					SELECT [SSISStatusID]
					FROM [etljob].[vw_SSISStatus]
					WHERE [IsFailed] <> 0
					)
				AND JobExecutionID = @JobExecutionID
				AND [JobStepExecutionID] NOT IN (
					SELECT JobStepExecutionID
					FROM [etljob].fn_BlockedJobSteps(@JobExecutionID)
					)
			ORDER BY [StepNo]
			)
	) AS X

IF @@RowCount = 0
BEGIN
	SELECT CAST(- 1 AS INT) AS [JobStepExecutionID]
		,(
			SELECT Count([JobStepExecutionID])
			FROM [etljob].[vw_JobStepExecution]
			WHERE StartTime IS NULL
				AND JobExecutionID = @JobExecutionID
				AND [JobStepExecutionID] IN (
					SELECT JobStepExecutionID
					FROM [etljob].fn_BlockedJobSteps(@JobExecutionID)
					)
			) AS Blockings
		,(
			SELECT SUM(CriticalAbnormal)
			FROM [etljob].[fn_StatusJobSteps](@JobExecutionID)
			) AS CriticalFailed
END
ELSE
BEGIN
	SELECT Q.[JobStepExecutionID]
		,0 AS Blockings -- Blockings not relevant, there is work anyway
		,(
			SELECT SUM(CriticalAbnormal)
			FROM [etljob].[fn_StatusJobSteps](@JobExecutionID)
			) AS CriticalFailed
	FROM [etljob].[vw_JobStepExecution] AS Q
	INNER JOIN (
		SELECT [JobStepExecutionID]
		FROM @OutTbl
		) AS E ON Q.[JobStepExecutionID] = E.JobStepExecutionID
END;
