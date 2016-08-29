


CREATE VIEW [etljob].[vw_LoadErrorDetail]
AS
SELECT TOP (100) PERCENT [etljob].vw_LoadError.JobStep
	,[etljob].vw_LoadError.ClientID
	,[etljob].vw_LoadError.StartTime
	,[etljob].vw_LoadError.EndTime
	,[etljob].vw_LoadMessages.ErrorMessages
	,[etljob].vw_LoadVariables.Variables
	,[etljob].vw_LoadError.JobExecutionID
	,[etljob].vw_LoadError.[Message]
FROM [etljob].vw_LoadError
LEFT OUTER JOIN [etljob].vw_LoadMessages ON [etljob].vw_LoadError.SSISExecutionID = [etljob].vw_LoadMessages.ID
LEFT OUTER JOIN [etljob].vw_LoadVariables ON [etljob].vw_LoadError.SSISExecutionID = [etljob].vw_LoadVariables.ID
ORDER BY [etljob].vw_LoadError.StartTime DESC
