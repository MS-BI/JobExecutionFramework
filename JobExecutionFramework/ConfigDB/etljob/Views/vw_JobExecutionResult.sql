
CREATE VIEW [etljob].[vw_JobExecutionResult]
AS
WITH JobExecutionResult
AS (
	SELECT TOP (100) PERCENT [JobExecutionID]
      ,[JobID]
      ,[ApplicationID]
      ,[GroupID]
      ,[ClientID]
      ,[LayerID]
      ,[JobStepClusterID]
      ,[MetaGroupID]
      ,[StartTime]
      ,[EndTime]
      ,[Total]
      ,[Started]
      ,[Finished]
      ,[Failed]
      ,[Abnormal]
      ,[CriticalAbnormal]
      ,[CriticalFailed]
      ,[SSISExecutionID]
      ,[IsBlocked]
      ,[MasterInternalError]
      ,[RestartOf]
      ,[StopRecoveryID]
      ,[StoppedByStopID]
      ,[StopMode]
      ,[IsRecoveryDisabled]
      ,[AuditID]
      ,[ExcludingClusterID]
      ,[Label]
      ,[JobExecutionEndStatusID]
  FROM [etljob].[vw_JobExecution]
	ORDER BY StartTime
		,EndTime
	)
SELECT t.JobExecutionID
	,ClientID
	,STUFF((
			SELECT CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'Label/Cluster: ' + s.Label
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'Start: ' + Coalesce(Convert(nvarchar(16),s.[StartTime]),'')
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'End: ' + Coalesce(Convert(nvarchar(16),s.[EndTime]),'')
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'Total: ' + Coalesce(Convert(nvarchar(6),s.[Total]),'')
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'Started: ' + Coalesce(Convert(nvarchar(6),s.[Started]),'')
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'Finished: ' + Coalesce(Convert(nvarchar(6),s.[Finished]),'')
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'Failed ' + Coalesce(Convert(nvarchar(6),s.[Failed]),'')
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'Abnormal: ' + Coalesce(Convert(nvarchar(6),s.[Abnormal]),'')
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'CriticalAbnormal: ' + Coalesce(Convert(nvarchar(6),s.[CriticalAbnormal]),'')
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'CriticalFailed: ' + Coalesce(Convert(nvarchar(6),s.[CriticalFailed]),'')
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'JobExecutionEndStatusID: ' + Coalesce(Convert(nvarchar(2),s.[JobExecutionEndStatusID]),'')
			FROM JobExecutionResult s
			WHERE s.JobExecutionID = t.JobExecutionID
			FOR XML PATH('')
				,TYPE
			).value('.', 'VARCHAR(MAX)'), 1, 1, '') AS Result
FROM JobExecutionResult AS t
GROUP BY t.JobExecutionID
	,ClientID