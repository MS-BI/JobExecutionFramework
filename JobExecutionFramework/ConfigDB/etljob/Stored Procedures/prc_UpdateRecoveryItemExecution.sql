
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-06-04
-- Updates Infos in JobStepExecution
-- =============================================
CREATE PROCEDURE [etljob].[prc_UpdateRecoveryItemExecution] @RecoveryID AS INT
AS
SET NOCOUNT ON

DECLARE @OutTbl AS TABLE (
	RecoveryItemID INT
	,ETLStatusID INT
	,EndTime DATETIME2
	);

INSERT INTO @OutTbl (
	RecoveryItemID
	,ETLStatusID
	,EndTime
	)
SELECT [RecoveryItemID]
	,ETLStatusID
	,[RecoveryEnd]
FROM (
	UPDATE Ex
	SET Ex.[RecoveryEnd] = ExSSIS.end_time
		,Ex.ETLStatusID = ExSSIS.STATUS
	OUTPUT inserted.[RecoveryItemId]
		,inserted.[ETLStatusID]
		,inserted.[RecoveryEnd]
	FROM ssis.vw_executions ExSSIS
	INNER JOIN [etljob].vw_RecoveryItem Ex ON ExSSIS.execution_id = Ex.SSISExecutionID
	WHERE (Ex.[RecoveryEnd] IS NULL)
		AND Ex.JobExecutionID = @RecoveryID
		AND COALESCE(Ex.ETLStatusSource, 0) = 0
	) AS X