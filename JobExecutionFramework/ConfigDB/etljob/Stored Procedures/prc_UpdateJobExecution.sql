
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-07-10
-- Updates Infos in JobExecution
-- Changes:
--		2016-01-21, CS: Added Parameter @IsFinal, if not 1 no end time is set
-- =============================================
CREATE PROCEDURE [etljob].[prc_UpdateJobExecution] @JobExecutionID AS INT
	,@IsFinal AS SMALLINT = 1
AS
SET NOCOUNT ON

UPDATE Ex
SET Ex.EndTime = CASE @IsFinal
		WHEN 1
			THEN IsNull(Ex.EndTime, GetDate())
		ELSE NULL
		END
	,Ex.Failed = STATUS.Failed
	,Ex.CriticalFailed = STATUS.CriticalFailed
	,Ex.Total = STATUS.Total
	,Ex.Started = STATUS.Started
	,Ex.Finished = STATUS.Finished
	,Ex.CriticalAbnormal = STATUS.CriticalAbnormal
	,Ex.Abnormal = STATUS.Abnormal
FROM [etljob].vw_JobExecution Ex
CROSS JOIN (
	SELECT Sum(Failed) AS Failed
		,Sum(Total) AS Total
		,Sum(Started) AS Started
		,Sum(Finished) AS Finished
		,Sum(CriticalFailed) AS CriticalFailed
		,Sum(CriticalAbnormal) AS CriticalAbnormal
		,Sum(Abnormal) AS Abnormal
	FROM [etljob].[fn_StatusJobSteps](@JobExecutionID)
	) AS STATUS
WHERE Ex.JobExecutionID = @JobExecutionID