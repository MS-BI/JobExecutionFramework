-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-06-25
-- Description: Initializes Package from  JobStep from Queue JobStepEexcution for execution
-- ToDo: Eliminate Hard reference to SSISDB (->synonym)
--       Parameter Loop
-- =============================================
CREATE PROCEDURE [etljob].[prc_SetRecoverItemParameter] @ExecutionID AS BIGINT
	,@RecoveryType AS INT
	,@JobID AS INT
	,@ApplicationID AS INT
	,@GroupID AS INT
	,@LayerID AS INT
	,@MetaGroupID AS INT
	,@StepNo AS INT
	,@StepNoEqual AS INT
	,@ClientID AS INT
	,@RecoveryItemID AS INT
	,@StopRecoveryID AS INT
AS
SET NOCOUNT ON;

DECLARE @msg NVARCHAR(255);

/* Set RecoveryType  */
BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @ExecutionID
		,@object_type = 30
		,@parameter_name = N'RecoveryType'
		,@parameter_value = @RecoveryType;
END TRY

BEGIN CATCH
	SET @msg = 'Cannot set RecoveryType: ' + ERROR_MESSAGE()

	GOTO Error
END CATCH

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @ExecutionID
		,@object_type = 30
		,@parameter_name = N'JobID'
		,@parameter_value = @JobID;
END TRY

BEGIN CATCH
	SET @msg = 'Cannot set JobID: ' + ERROR_MESSAGE()

	GOTO Error
END CATCH

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @ExecutionID
		,@object_type = 30
		,@parameter_name = N'ApplicationID'
		,@parameter_value = @ApplicationID;
END TRY

BEGIN CATCH
	SET @msg = 'Cannot set ApplicationID: ' + ERROR_MESSAGE()

	GOTO Error
END CATCH

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @ExecutionID
		,@object_type = 30
		,@parameter_name = N'GroupID'
		,@parameter_value = @GroupID;
END TRY

BEGIN CATCH
	SET @msg = 'Cannot set GroupID: ' + ERROR_MESSAGE()

	GOTO Error
END CATCH

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @ExecutionID
		,@object_type = 30
		,@parameter_name = N'LayerID'
		,@parameter_value = @LayerID;
END TRY

BEGIN CATCH
	SET @msg = 'Cannot set LayerID: ' + ERROR_MESSAGE()

	GOTO Error
END CATCH

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @ExecutionID
		,@object_type = 30
		,@parameter_name = N'MetaGroupID'
		,@parameter_value = @MetaGroupID;
END TRY

BEGIN CATCH
	SET @msg = 'Cannot set MetaGroupID: ' + ERROR_MESSAGE()

	GOTO Error
END CATCH

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @ExecutionID
		,@object_type = 30
		,@parameter_name = N'StepNo'
		,@parameter_value = @StepNo;
END TRY

BEGIN CATCH
	SET @msg = 'Cannot set StepNo: ' + ERROR_MESSAGE()

	GOTO Error
END CATCH

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @ExecutionID
		,@object_type = 30
		,@parameter_name = N'StepNoEqual'
		,@parameter_value = @StepNoEqual;
END TRY

BEGIN CATCH
	SET @msg = 'Cannot set StepNoEqual: ' + ERROR_MESSAGE()

	GOTO Error
END CATCH

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @ExecutionID
		,@object_type = 30
		,@parameter_name = N'ClientID'
		,@parameter_value = @ClientID;
END TRY

BEGIN CATCH
	SET @msg = 'Cannot set ClientID: ' + ERROR_MESSAGE()

	GOTO Error
END CATCH

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @ExecutionID
		,@object_type = 30
		,@parameter_name = N'StopRecoveryID'
		,@parameter_value = @ClientID;
END TRY

BEGIN CATCH
	SET @msg = 'Cannot set StopRecoveryID: ' + ERROR_MESSAGE()

	GOTO Error
END CATCH

SELECT @executionid AS execution_id;

RETURN (0)

Error:

BEGIN TRY
	UPDATE [etljob].[vw_RecoveryItem]
	SET [ETLStatusID] = 4
		,[ETLStatusSource] = 1
		,[Message] = @msg
		,[RecoveryEnd] = GETDATE()
	WHERE [RecoveryItemID] = @RecoveryItemID

	EXEC [SSISDB].[catalog].stop_operation @operation_id = @ExecutionID
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
