CREATE PROCEDURE [etljob].[prc_GetReportParaJobExecutionEndStatus]
AS
BEGIN

SELECT [JobExecutionEndStatusID]
      ,[JobExecutionEndStatus]
  FROM [etljob].[vw_JobExecutionEndStatus]
END