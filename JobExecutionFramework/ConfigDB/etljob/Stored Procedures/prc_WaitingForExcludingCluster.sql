CREATE PROCEDURE [etljob].[prc_WaitingForExcludingCluster] @JobExecutionID INT
	,@ExcludingClusterID INT
	,@WaitForSeconds INT = 5
AS
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-05-18
-- Description: Logs for whom we are waiting and waits
-- Logging currently not persisted
-- =============================================
SET NOCOUNT ON;

DECLARE @Time TIME
	,@sql NVARCHAR(100)

BEGIN TRY
	UPDATE [etljob].[vw_JobExecution]
	SET ExcludingClusterID = @ExcludingClusterID
	WHERE JobExecutionID = @JobExecutionID
END TRY

BEGIN CATCH
	Throw;
END CATCH

SET @WaitForSeconds = CASE 
		WHEN @WaitForSeconds < 0
			THEN 0
		ELSE @WaitForSeconds
		END
SET @Time = '00:00:00'

SELECT @sql = 'waitfor delay ''' + convert(NVARCHAR(8), dateadd(second, @WaitForSeconds, @Time)) + ''''

EXEC dbo.sp_executesql @sql

RETURN 0
