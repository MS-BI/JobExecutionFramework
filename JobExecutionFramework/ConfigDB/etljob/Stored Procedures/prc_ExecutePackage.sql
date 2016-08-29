-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-06-25
-- Description: Eexcutes JobStep from Queue JobStepEexcution
-- =============================================
CREATE PROC [etljob].[prc_ExecutePackage] @JobStepExecutionID AS INT
	,@LoggingLevel AS INT = 1
	,@ClientID as Int = -1
	,@IsInitialLoad as bit =1
AS
SET NOCOUNT ON;

DECLARE @Package NVARCHAR(256)
	,@Project NVARCHAR(256)
	,@Folder NVARCHAR(256)
	,@execution_id BIGINT;

SELECT @Package = Pg.PackageName
	,@Project = Pj.ProjectName
	,@Folder = Fd.Foldername
FROM [etljob].[vw_JobStepExecution] Ex
INNER JOIN [etljob].vw_Package Pg ON Ex.PackageID = Pg.PackageID
INNER JOIN [etljob].vw_Project Pj ON Pg.[ProjectID] = Pj.projectID
INNER JOIN [etljob].vw_Folder Fd ON Pj.folderID = Fd.FolderID
WHERE Ex.[JobStepExecutionID] = @JobStepExecutionID;

IF @@ROWCOUNT < 1
	RETURN (- 1)

BEGIN TRY
	EXEC [$(SSISDB)].[catalog].[create_execution] @package_name = @Package
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
Begin Try
EXEC [$(SSISDB)].[catalog].[set_execution_parameter_value] @execution_id
	,@object_type = 20
	,@parameter_name = N'Int_ClientID'
	,@parameter_value = @ClientID;
End Try
Begin Catch
	-- ClientID is missing in Package
End Catch
Begin Try
EXEC [$(SSISDB)].[catalog].[set_execution_parameter_value] @execution_id
	,@object_type = 20
	,@parameter_name = N'Bool_IsInitialLoad'
	,@parameter_value = @IsInitialLoad;
End Try
Begin Catch
	-- @IsInitialLoad is missing in Package
End Catch
EXEC [$(SSISDB)].[catalog].[set_execution_parameter_value] @execution_id
	,@object_type = 50
	,@parameter_name = N'LOGGING_LEVEL'
	,@parameter_value = @LoggingLevel;

BEGIN TRY
	EXEC [$(SSISDB)].[catalog].[start_execution] @execution_id;

	UPDATE [etljob].[vw_JobStepExecution]
	SET [SSISExecutionID] = @execution_id
	WHERE [JobStepExecutionID] = @JobStepExecutionID
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

SELECT @execution_id AS execution_id;
