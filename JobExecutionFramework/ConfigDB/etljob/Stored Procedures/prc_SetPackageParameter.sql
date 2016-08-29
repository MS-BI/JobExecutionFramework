
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-02-12
-- Description: Sets Parameter for Package execution
-- ToDo: Eliminate Hard reference to SSISDB (->synonym)
-- =============================================
CREATE PROCEDURE [etljob].[prc_SetPackageParameter] @JobStepExecutionID INT
	,@execution_id BIGINT
	,@parameter_name NVARCHAR(128)
	,@data_type NVARCHAR(128)
	,@SystemID INT
AS
SET NOCOUNT ON;

DECLARE @msg NVARCHAR(255)
	,@parameter_value SQL_VARIANT
	,@required BIT
	,@object_type SMALLINT

SELECT @parameter_value = [Val]
	,@required = p.[required]
	,@object_type = [object_type]
FROM [etljob].[fn_ParameterValuesForJobStep](@JobStepExecutionID, @SystemID) p
WHERE p.[parameter_name] = @parameter_name
	AND p.[data_type] = @data_type

IF @parameter_value IS NULL
	AND @required = 1
BEGIN
	BEGIN TRY
		SET @msg = 'Required Parameter ' + @parameter_name + ' empty'

		UPDATE [etljob].[vw_JobStepExecution]
		SET [ETLStatusID] = 4
			,[ETLStatusSource] = 1
			,[Message] = @msg
			,[EndTime] = GETDATE()
		WHERE [JobStepExecutionID] = @JobStepExecutionID

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
END

IF @parameter_value IS NULL
	RETURN (0)

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id
		,@object_type = @object_type
		,@parameter_name = @parameter_name
		,@parameter_value = @parameter_value;
END TRY

BEGIN CATCH
	SET @msg = ERROR_MESSAGE()

	BEGIN TRY
		UPDATE [etljob].[vw_JobStepExecution]
		SET [ETLStatusID] = 4
			,[ETLStatusSource] = 1
			,[Message] = @msg
			,[EndTime] = GETDATE()
		WHERE [JobStepExecutionID] = @JobStepExecutionID

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