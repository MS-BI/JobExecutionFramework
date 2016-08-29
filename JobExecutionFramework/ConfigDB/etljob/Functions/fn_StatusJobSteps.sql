
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-08-05
-- Description: Summary for the execution status of packaes of job, used in [etljob].[pc_UpdateJobExecution]
-- =============================================
CREATE FUNCTION [etljob].[fn_StatusJobSteps] (@JobExecutionID BIGINT)
RETURNS TABLE
AS
RETURN (
		SELECT 1 AS Total
			,CASE 
				WHEN NOT Executions.SSISExecutionID IS NULL
					THEN 1
				ELSE 0
				END AS Started
			,CASE 
				WHEN NOT EndTime IS NULL
					THEN 1
				ELSE 0
				END AS Finished
			,CASE 
				WHEN COALESCE(Execs.STATUS, Executions.ETLStatusID) IN (
						SELECT [SSISStatusID]
						FROM [etljob].[vw_SSISStatus]
						WHERE [IsFailed] <> 0
						)
					THEN 1
				ELSE 0
				END AS Abnormal
			,CASE 
				WHEN COALESCE(Execs.STATUS, Executions.ETLStatusID) IN (
						SELECT [SSISStatusID]
						FROM [etljob].[vw_SSISStatus]
						WHERE [IsFailed] <> 0
						)
					AND Executions.IsNotCritical = 0
					THEN 1
				ELSE 0
				END AS CriticalAbnormal
			,CASE 
				WHEN COALESCE(Execs.STATUS, Executions.ETLStatusID) = 4
					AND Executions.IsNotCritical = 0
					THEN 1
				ELSE 0
				END AS CriticalFailed
			,CASE 
				WHEN COALESCE(Execs.STATUS, Executions.ETLStatusID) = 4
					THEN 1
				ELSE 0
				END AS Failed
			,CASE 
				WHEN COALESCE(Execs.STATUS, Executions.ETLStatusID) = 3
					THEN 1
				ELSE 0
				END AS Canceled
			,[etljob].vw_Package.PackageName
		FROM [etljob].vw_Package
		INNER JOIN [etljob].vw_JobStep ON [etljob].vw_Package.PackageID = [etljob].vw_JobStep.PackageID
		RIGHT JOIN [etljob].vw_JobStepExecution AS Executions ON [etljob].vw_JobStep.JobStepID = Executions.JobStepID
		LEFT JOIN [ssis].[vw_Executions] AS Execs ON Executions.SSISExecutionID = Execs.execution_id
		WHERE (Executions.JobExecutionID = @JobExecutionID)
		)