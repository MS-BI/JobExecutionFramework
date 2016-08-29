
CREATE VIEW [etljob].[vw_LoadError]
AS
SELECT TOP (100) PERCENT [etljob].JobStep.JobStep
	,[etljob].JobStepExecution.StartTime
	,[etljob].JobStepExecution.EndTime
	,[etljob].JobStepExecution.ETLStatusID
	,[etljob].JobStepExecution.JobExecutionID
	,[etljob].JobStepExecution.GroupID
	,[etljob].JobStepExecution.MetaGroupID
	,[etljob].JobStepExecution.StepNo
	,[etljob].JobStepExecution.SSISExecutionID
	,[etljob].JobStepExecution.ClientID
	,[etljob].JobStepExecution.[Message]
	,[etljob].JobStepExecution.[IsNotCritical]
FROM [etljob].JobStepExecution
INNER JOIN [etljob].JobStep ON [etljob].JobStepExecution.JobStepID = [etljob].JobStep.JobStepID
WHERE (
		[etljob].JobStepExecution.ETLStatusID NOT IN (
			SELECT [SSISStatusID]
			FROM [etljob].[vw_SSISStatus]
			WHERE [IsDone] = 1
			
			UNION
			
			SELECT 0
			)
		)
