
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-02-12
-- Description: Starts initialized Package
-- ToDo: Eliminate Hard reference to SSISDB (->synonym)
-- Change 2015-06-04 (CS): Added handling of @RecoveryItemID for Start of Recoveries
-- =============================================
CREATE PROCEDURE [etljob].[prc_StartPackage] @JobStepExecutionID AS INT
	,@execution_id BIGINT
	,@RecoveryItemID AS INT = 0
AS
SET NOCOUNT ON;

DECLARE @msg NVARCHAR(255)

BEGIN TRY
	EXEC [SSISDB].[catalog].[start_execution] @execution_id;
	If @JobStepExecutionID > 0
		UPDATE [etljob].[vw_JobStepExecution]
		SET [SSISExecutionID] = @execution_id
		WHERE [JobStepExecutionID] = @JobStepExecutionID
	If @RecoveryItemID > 0
		UPDATE [etljob].[vw_RecoveryItem]
		SET [SSISExecutionID] = @execution_id
		WHERE [RecoveryItemID] = @RecoveryItemID
END TRY

BEGIN CATCH
	SET @msg = ERROR_MESSAGE()

	BEGIN TRY
	If @JobStepExecutionID > 0
		UPDATE [etljob].[vw_JobStepExecution]
		SET [ETLStatusID] = 4
			,[ETLStatusSource] = 1
			,[Message] = @msg
			,[EndTime] = GETDATE()
		WHERE [JobStepExecutionID] = @JobStepExecutionID

	If @RecoveryItemID > 0
		UPDATE [etljob].[vw_RecoveryItem]
		SET [ETLStatusID] = 4
			,[ETLStatusSource] = 1
			,[Message] = @msg
			,[RecoveryEnd] = GETDATE()
		WHERE [RecoveryItemID] = @RecoveryItemID

		EXEC [SSISDB].[catalog].stop_operation @operation_id = @execution_id
	END TRY

	BEGIN CATCH
		-- do nothing
	END CATCH

	RAISERROR (
			@msg
			,16
			,1
			)

	RETURN (- 1)
END CATCH

RETURN (0)