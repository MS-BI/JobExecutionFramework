CREATE VIEW [etljob].vw_JobStepException
AS
SELECT [JobStepExceptionID]
	,[JobStepID]
	,[ClientID]
	,[IsAllowed]
	,[Remark]
FROM [etljob].[JobStepException]
