CREATE PROCEDURE [etljob].[prc_GetReportExecutionOverview]
(
	@StartDate as datetime,
	@EndDate as datetime,
	@paraJobExecutionEndStatus AS varchar(max),
	@paraJobStepExecutionStatus AS varchar(max),
	@paraJobFilter as varchar(max)
)
AS

--DECLARE @StartDate as datetime = '20150814';
--DECLARE @EndDate as datetime = '20151029 23:59.999';
--DECLARE @paraJobExecutionEndStatus as varchar(max) = '1,2,3,4,5,6,7,8';
--DECLARE @paraJobStepExecutionStatus as varchar(max) = '0,1,2,3,4,5,6,7,8,9,10,11';
--DECLARE @paraJobFilter as varchar(max) = '';


WITH 
JobExecutions AS(
SELECT 
	JobExecutionID
FROM [etljob].vw_JobExecution
WHERE 
	StartTime BETWEEN @StartDate AND @Enddate
	AND
	JobExecutionEndStatusID IN (Select Val FROM [etljob].[fn_StringToTable](@paraJobExecutionEndStatus,',',1))
	AND 
	Label LIKE '%' + @paraJobFilter + '%'
),
JobStepExecutions AS
(
SELECT
	jse.JobExecutionID AS JobExecutionID
	,jse.JobStepExecutionID AS JobStepExecutionID
	,js.JobStep AS Name
	,jse.StartTime AS StartTime
	,jse.EndTime AS EndTime
	,CASE 
		WHEN jse.StartTime IS NULL OR jse.EndTime IS NULL THEN NULL 
		ELSE DATEDIFF(MILLISECOND, jse.StartTime, jse.EndTime)
	END
	AS DurationMilliSeconds
	,1 AS Total
	,CASE 
		WHEN jse.StartTime IS NOT NULL AND jse.EndTime IS NOT NULL THEN 1
		ELSE 0
	END AS Finished -- Finished if started and finished
	,CASE 
		WHEN jse.StartTime IS NOT NULL AND jse.EndTime IS NULL THEN 1
		ELSE 0
	END
	AS Running -- Runs if started, but not finished
	,CASE 
		WHEN jse.ETLStatusID IN (0,5) THEN 1
		ELSE 0
	END
	AS Pending -- Pending if status is pending or queued
	,CASE 
		WHEN jsest.IsFailed = 1 THEN 1
		ELSE 0
	END
	AS Failed -- Failed if failed flag is set on status in status table
	,NULL AS Blocked -- doesn't make sense?
	,jse.ETLStatusID AS [StatusID]
	,jsest.StatusDescription AS [Status]
	,jse.IsNotCritical AS IsNotCritical
	,js.StepNo AS StepNo
FROM [etljob].vw_JobExecution je
INNER JOIN JobExecutions filterJobs
	ON je.JobExecutionID = filterJobs.JobExecutionID
LEFT JOIN etljob.vw_JobStepExecution jse
	ON je.JobExecutionID = jse.JobExecutionID
LEFT JOIN etljob.vw_SSISStatus jsest
	ON jse.ETLStatusID = jsest.SSISStatusID
LEFT JOIN etljob.vw_JobStep js
	ON js.JobStepID = jse.JobStepID
WHERE
	jse.ETLStatusID IN (Select Val FROM [etljob].[fn_StringToTable](@paraJobStepExecutionStatus,',',1))
)

-- SELECT * FROM Executions
-- SELECT * FROM JobStepExecutions

SELECT * FROM(
-- Get Job execution properties
SELECT
	Max(je.JobExecutionID) AS JobExecutionID
	,NULL AS JobStepExecutionID
	,Max(je.Label) AS Name
	,Max(je.StartTime) AS StartTime
	,Max(je.EndTime) AS EndTime
	,CASE 
		WHEN Max(je.StartTime) IS NULL OR Max(je.EndTime) IS NULL THEN NULL 
		ELSE DATEDIFF(MILLISECOND, Max(je.StartTime), Max(je.EndTime))
	END
	AS DurationMilliSeconds
	,Count(jse.JobStepExecutionID) AS Total
	,Sum(
		CASE 
			WHEN jse.StartTime IS NOT NULL AND jse.EndTime IS NOT NULL THEN 1
			ELSE 0
		END)
	AS Finished -- Finished if started and finished
	,Sum(
		CASE 
			WHEN jse.StartTime IS NOT NULL AND jse.EndTime IS NULL THEN 1
			ELSE 0
		END)
	AS Running -- Runs if started, but not finished
	,Sum(
		CASE 
			WHEN jse.StatusID IN (0,5) THEN 1
			ELSE 0
		END)
	AS Pending -- Pending if status is pending or queued
	,Sum(
		CASE 
			WHEN jsest.IsFailed = 1 THEN 1
			ELSE 0
		END)
	AS Failed -- Failed if failed flag is set on status in status table
	,NULL AS Blocked
	,CASE
		WHEN Max(je.JobExecutionEndStatusID) IS NULL THEN 2
		ELSE Max(je.JobExecutionEndStatusID)
	END AS [StatusID]
	,CASE
		WHEN Max(je.JobExecutionEndStatusID) IS NULL THEN 'Pending'
		ELSE Max(st.JobExecutionEndStatus)
	END
	AS [Status]
	,NULL AS IsNotCritical -- does not exist on job level, placeholder
	,NULL AS StepNo -- does not exist on job level, placeholder
FROM [etljob].vw_JobExecution je
INNER JOIN JobExecutions filterJobs
	ON je.JobExecutionID = filterJobs.JobExecutionID
LEFT JOIN JobStepExecutions jse
	ON je.JobExecutionID = jse.JobExecutionID
LEFT JOIN etljob.vw_JobExecutionEndStatus st
	ON je.JobExecutionEndStatusID = st.JobExecutionEndStatusID
LEFT JOIN etljob.vw_SSISStatus jsest
	ON jse.StatusID = jsest.SSISStatusID
GROUP BY je.JobExecutionID

UNION ALL

-- Get Job step execution properties
SELECT * FROM JobStepExecutions
) t
ORDER BY JobExecutionID, JobStepExecutionID