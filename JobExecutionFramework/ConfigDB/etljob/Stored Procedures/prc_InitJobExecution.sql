
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-06-25
-- Description: Copies Entries from JobStep to JobStepEexcution ("queue")
--				and creates Entry in JobExecution
-- Change 2015-03-23 (CS): Include restart parameter. When set, get last job with identical JobStepCluster
--		And reexecute steps which are not Done
-- Change 2015-09-01 (CS): Added Parameter Label, is logged into JobExecution
-- =============================================
CREATE PROCEDURE [etljob].[prc_InitJobExecution] @ServerExecutionID BIGINT
	,@JobID INT
	,@ApplicationID INT = NULL
	,@ClientID INT = NULL
	,@LayerID INT = NULL
	,@GroupID INT = NULL
	,@JobStepID INT = NULL
	,@MetaGroupID INT = NULL
	,@StepNo INT = 0
	,@SSISExecutionID BIGINT = 0
	,@AuditID INT = 0
	,@StepNoEqual INT = 0
	,@JobStepClusterID INT = 0
	,@Restart INT = 0
	,@Label NVARCHAR(250) = ''
AS
SET NOCOUNT ON
SET @ApplicationID = CASE @ApplicationID
		WHEN 0
			THEN NULL
		ELSE @ApplicationID
		END
SET @ClientID = CASE @ClientID
		WHEN 0
			THEN NULL
		ELSE @ClientID
		END
SET @LayerID = CASE @LayerID
		WHEN 0
			THEN NULL
		ELSE @LayerID
		END
SET @GroupID = CASE @GroupID
		WHEN 0
			THEN NULL
		ELSE @GroupID
		END
SET @MetaGroupID = CASE @MetaGroupID
		WHEN 0
			THEN NULL
		ELSE @MetaGroupID
		END
SET @JobStepID = CASE @JobStepID
		WHEN 0
			THEN NULL
		ELSE @JobStepID
		END
SET @SSISExecutionID = CASE @SSISExecutionID
		WHEN 0
			THEN @ServerExecutionID
		ELSE @SSISExecutionID
		END

DECLARE @ToBeRestarted INT -- JobExecutionID of Job to be restarted (to be copied) - if restart
DECLARE @OutputTemp AS TABLE (JobExecutionID INT)
DECLARE @ParmDefinition NVARCHAR(500)
	,@JobExecutionID INT
	,@WhereClause NVARCHAR(500)

-- To  Add: Only get Not running Jobs for Restart
SELECT @ToBeRestarted = Coalesce(CASE 
			WHEN @Restart = 0
				THEN 0
			ELSE (
					SELECT TOP 1 [JobExecutionID]
					FROM [etljob].[JobExecution]
					WHERE [StartTime] = (
							SELECT MAX([StartTime])
							FROM [etljob].[JobExecution]
							WHERE [JobStepClusterID] = @JobStepClusterID
								AND [StopMode] <> 1 -- Omit Skipped
							)
						AND [JobStepClusterID] = @JobStepClusterID
					ORDER BY [JobExecutionID] DESC
					)
			END, 0)

DECLARE @query NVARCHAR(4000)
	,@Insert NVARCHAR(4000)

SET @query = CASE @Restart
		WHEN 0
			THEN 'Select
			   [JobStepID]
			  ,[JobID]
			  ,[ApplicationID]
			  ,[GroupID]
			  ,[PackageID]
			  ,[ClientID]
			  ,[LayerID]
			  ,[MetaGroupID]
			  ,[StepNo]
			  ,[IsNotCritical]
			  ,@JobExecutionID as JobExecutionID
			  ,@JobStepClusterID as JobStepClusterID
			  ,0
			  ,NULL
			  ,NULL
		FROM [etljob].[vw_JobStep]
		WHERE [IsEnabled] <> 0 '
		ELSE 'SELECT [JobStepID]
			,[JobID]
			,[ApplicationID]
			,[GroupID]
			,[PackageID]
			,[ClientID]
			,[LayerID]
			,[MetaGroupID]
			,[StepNo]
			,[IsNotCritical]
			,@JobExecutionID AS JobExecutionID
			,@JobStepClusterID AS JobStepClusterID
			,CASE 
				WHEN Coalesce(St.IsDone, 0) <> 0
					THEN (
							SELECT MIN(SSISStatusID)
							FROM [etljob].[vw_SSISStatus] St1
							WHERE St1.IsDone <> 0
							)
				ELSE 0
				END AS ETLStatusID
			,CASE 
				WHEN Coalesce(St.IsDone, 0) <> 0
					THEN StartTime
				ELSE NULL
				END AS StartTime
			,CASE 
				WHEN Coalesce(St.IsDone, 0) <> 0
					THEN EndTime
				ELSE NULL
				END AS EndTime
		FROM [etljob].[vw_JobStepExecution] Ex
		LEFT JOIN [etljob].[vw_SSISStatus] St ON Ex.ETLStatusID = St.SSISStatusID
		WHERE [JobExecutionID] = ' + CONVERT(NVARCHAR(16), @ToBeRestarted)
		END
SET @Insert = '
		INSERT INTO [etljob].[JobStepExecution] (
		JobStepID
		,JobID
		,ApplicationID
		,GroupID
		,PackageID
		,ClientID
		,LayerID
		,MetaGroupID
		,StepNo
		,IsNotCritical
		,JobExecutionID
		,JobStepClusterID
		,ETLStatusID
		,[StartTime]
		,[EndTime])
		'

INSERT INTO [etljob].[JobExecution] (
	[JobID]
	,[ApplicationID]
	,[GroupID]
	,[ClientID]
	,[LayerID]
	,[MetaGroupID]
	,[StartTime]
	,[SSISExecutionID]
	,[AuditID]
	,[JobStepClusterID]
	,[RestartOf]
	,[Label]
	)
OUTPUT inserted.[JobExecutionID]
INTO @OutputTemp
SELECT @JobID
	,@ApplicationID
	,@GroupID
	,COALESCE(@ClientID,0)
	,@LayerID
	,@MetaGroupID
	,getdate()
	,@SSISExecutionID
	,@AuditID
	,@JobStepClusterID
	,@ToBeRestarted
	,@Label

SET @JobExecutionID = (
		SELECT TOP (1) JobExecutionID
		FROM @OutputTemp
		)
SET @WhereClause = CASE 
		WHEN @Restart <> 0
			THEN ''
		ELSE coalesce(' And JobID = ' + Cast(@JobID AS NVARCHAR(20)), '') + Coalesce(' And ApplicationID = ' + Cast(@ApplicationID AS NVARCHAR(20)), '')
			/*+ Coalesce(' And ClientID = ' + Cast(@ClientID AS NVARCHAR(20)), '') */
			+ Coalesce(' And LayerID = ' + Cast(@LayerID AS NVARCHAR(20)), '') + Coalesce(' And GroupID = ' + Cast(@GroupID AS NVARCHAR(20)), '') + Coalesce(' And JobStepID = ' + Cast(@JobStepID AS NVARCHAR(20)), '') + Coalesce(' And MetaGroupID = ' + Cast(@MetaGroupID AS NVARCHAR(20)), '') + CASE 
				WHEN @StepNoEqual = 0
					THEN Coalesce(' And StepNo >= ' + Cast(@StepNo AS NVARCHAR(20)), '')
				ELSE Coalesce(' And StepNo = ' + Cast(@StepNo AS NVARCHAR(20)), '')
				END
		END
SET @Query = @Insert + @Query + @WhereClause
SET @ParmDefinition = N'@JobExecutionID BIGINT,@JobStepClusterID Int'

--select @query
EXECUTE SP_executesql @query
	,@ParmDefinition
	,@JobExecutionID = @JobExecutionID
	,@JobStepClusterID = @JobStepClusterID

SELECT @JobExecutionID
