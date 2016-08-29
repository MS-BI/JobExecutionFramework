-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-06-04
-- Description: Initializes MasterPackage for RecoveryItem
-- ToDo: Eliminate Hard reference to SSISDB (->synonym)
-- =============================================
CREATE PROCEDURE [etljob].[prc_InitRecoveryItemRun] @LoggingLevel AS INT = 1
	,@MasterPackJobStepId AS INT
	,@RecoveryItemID AS INT
AS
SET NOCOUNT ON;

DECLARE @Package NVARCHAR(256)
	,@Project NVARCHAR(256)
	,@Folder NVARCHAR(256)
	,@execution_id BIGINT
	,@msg NVARCHAR(255);

SELECT @Package = Pg.PackageName
	,@Project = Pj.ProjectName
	,@Folder = Fd.Foldername
FROM etljob.vw_Package AS Pg
INNER JOIN etljob.vw_project AS Pj
	ON Pg.ProjectID = Pj.ProjectID
INNER JOIN etljob.vw_Folder AS Fd
	ON Pj.FolderID = Fd.FolderID
INNER JOIN etljob.vw_JobStep AS JobStep
	ON Pg.PackageID = JobStep.PackageID
WHERE (JobStep.JobStepID = @MasterPackJobStepId);

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

	UPDATE [etljob].[vw_RecoveryItem]
	SET [ETLStatusID] = 4
		,[ETLStatusSource] = 1
		,[Message] = @msg
		,[RecoveryEnd] = GETDATE()
	WHERE [RecoveryItemID] = @RecoveryItemID

	RETURN (- 1)
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
	UPDATE [etljob].[vw_RecoveryItem]
	SET SSISExecutionID = @execution_id
	WHERE [RecoveryItemID] = @RecoveryItemID
END TRY

BEGIN CATCH
	SET @msg = ERROR_MESSAGE()

	BEGIN TRY
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

SELECT @execution_id AS execution_id;
