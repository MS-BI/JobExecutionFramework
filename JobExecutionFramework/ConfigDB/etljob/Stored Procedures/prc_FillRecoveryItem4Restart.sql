-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-05-27
-- Description: Populates table RecoveryItem with Entries
--			for Jobs which were interrupted
-- =============================================
CREATE PROCEDURE [etljob].[prc_FillRecoveryItem4Restart] 
@RecoveryID INT
AS
SET NOCOUNT ON;
INSERT INTO [etljob].[RecoveryItem] (
	[JobExecutionID]
	,[RecoveryType]
	,[RecoveryPriority]
	,[ClientID]
	,[StopID]
    ,[JobStepClusterID]
	,[Scheduled]
	,[InitRecoveryId]
	)
SELECT DISTINCT JobEx.JobExecutionID
	,JobEx.StopMode AS RecoveryType
	,JobEx.StopMode AS RecoveryPriority
	,Coalesce(JobEx.ClientID,0)
	,JobEx.StoppedByStopID
	,JobEx.JobStepClusterID
	,JobEx.StartTime
	,@RecoveryID
FROM etljob.vw_Stop AS Stop
INNER JOIN etljob.vw_JobExecution AS JobEx
	ON Stop.StopID = JobEx.StoppedByStopID
LEFT OUTER JOIN etljob.vw_RecoveryItem AS Recov
	ON JobEx.JobStepClusterID = Recov.JobStepClusterID
		AND JobEx.ClientID = Recov.ClientID
		AND Recov.RecoveryEnd IS NULL
WHERE (Stop.RecoveryEnd IS NULL)
	AND (Stop.IsEnabled <> 0)
	AND (JobEx.StopMode = 2)
	AND (Recov.RecoveryItemId IS NULL)

