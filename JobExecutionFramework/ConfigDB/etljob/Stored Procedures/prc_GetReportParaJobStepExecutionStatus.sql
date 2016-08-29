CREATE PROCEDURE [etljob].[prc_GetReportParaJobStepExecutionStatus]
AS
BEGIN

SELECT [SSISStatusID]
      ,[StatusDescription]
  FROM [etljob].[vw_SSISStatus]
END
