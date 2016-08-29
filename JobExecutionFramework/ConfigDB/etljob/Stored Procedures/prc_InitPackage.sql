-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-06-25
-- Description: Initializes Package from  JobStep from Queue JobStepEexcution for execution
-- ToDo: Eliminate Hard reference to SSISDB (->synonym)
-- =============================================
CREATE PROCEDURE [etljob].[prc_InitPackage] @JobStepExecutionID AS INT
	,@LoggingLevel AS INT = 1
	,@ClientID AS INT = - 1
	,@IsInitialLoad AS BIT = 1
	,@int_ParentAuditID AS INT = 0
	,@guid_ParentSourceGUID AS UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
AS
SET NOCOUNT ON;

DECLARE @Package NVARCHAR(256)
	,@Project NVARCHAR(256)
	,@Folder NVARCHAR(256)
	,@execution_id BIGINT
	,@msg NVARCHAR(255)
	,@str_ParentAuditID NVARCHAR(MAX);

IF @JobStepExecutionID > 0
	SELECT @Package = Pg.PackageName
		,@Project = Pj.ProjectName
		,@Folder = Fd.Foldername
	FROM [etljob].[vw_JobStepExecution] Ex
	INNER JOIN [etljob].vw_Package Pg
		ON Ex.PackageID = Pg.PackageID
	INNER JOIN [etljob].vw_Project Pj
		ON Pg.[ProjectID] = Pj.projectID
	INNER JOIN [etljob].vw_Folder Fd
		ON Pj.folderID = Fd.folderID
	WHERE Ex.[JobStepExecutionID] = @JobStepExecutionID;

IF @@ROWCOUNT < 1
	RETURN (- 1)

BEGIN TRY
	EXEC [SSISDB].[catalog].[create_execution] @package_name = @Package
		,@execution_id = @execution_id OUTPUT
		,@folder_name = @Folder
		,@project_name = @Project
		,@use32bitruntime = False
		,@reference_id = NULL;
END TRY

BEGIN CATCH
	SELECT 0 AS execution_id

	UPDATE [etljob].[vw_JobStepExecution]
	SET [ETLStatusID] = 4
		,[ETLStatusSource] = 1
		,[Message] = ERROR_MESSAGE()
		,[EndTime] = GETDATE()
	WHERE [JobStepExecutionID] = @JobStepExecutionID

	RETURN (- 1)
END CATCH

/* Set ClientID  */
BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id
		,@object_type = 30
		,@parameter_name = N'Int_ClientID'
		,@parameter_value = @ClientID;
END TRY

BEGIN CATCH
	-- ClientID is missing in Package
END CATCH

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id
		,@object_type = 30
		,@parameter_name = N'Bool_IsInitialLoad'
		,@parameter_value = @IsInitialLoad;
END TRY

BEGIN CATCH
	-- @IsInitialLoad is missing in Package
END CATCH

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id
		,@object_type = 30
		,@parameter_name = N'int_ParentAuditID'
		,@parameter_value = @int_ParentAuditID;
END TRY


BEGIN CATCH
	-- @int_ParentAuditID is missing in Package Parameters
END CATCH

-- Try if ParentAuditID is Variable in Child, ToDo: Check if Propertie exists, "Try" is not enough ...
/*BEGIN TRY
	SET @str_ParentAuditID = convert(NVARCHAR(max), @int_ParentAuditID)

	EXEC [SSISDB].[catalog].[set_execution_property_override_value] @execution_id = @execution_id
		,@property_path = '\Package.Variables[Logging::int_ParentAuditID].Properties[Value]'
		,@property_value = @int_ParentAuditID
		,@sensitive = 0
END TRY

BEGIN CATCH
	-- @int_ParentAuditID is missing in Package Variables
END CATCH*/

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id
		,@object_type = 30
		,@parameter_name = N'guid_ParentSourceGUID'
		,@parameter_value = @guid_ParentSourceGUID;
END TRY

BEGIN CATCH
	-- @guid_ParentSourceGUID is missing in Package
END CATCH

BEGIN TRY
	EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id
		,@object_type = 50
		,@parameter_name = N'LOGGING_LEVEL'
		,@parameter_value = @LoggingLevel;
END TRY

BEGIN CATCH
	-- Do Nothing
END CATCH

BEGIN TRY
	SELECT @execution_id AS execution_id;
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
