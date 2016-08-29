CREATE VIEW [etljob].[vw_LoadErrorDetailResult]
AS
WITH LoadErrorDetailResult
AS (
	SELECT TOP (100) PERCENT [JobStep]
      ,[ClientID]
      ,[StartTime]
      ,[EndTime]
      ,[ErrorMessages]
      ,[Variables]
      ,[JobExecutionID]
      ,[Message]
  FROM [etljob].[vw_LoadErrorDetail]
	ORDER BY StartTime
		,EndTime
	)
SELECT t.JobExecutionID
	,ClientID
	,STUFF((
			SELECT CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'JobStep: ' + s.[JobStep]
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'Start: ' + Coalesce(Convert(nvarchar(16),s.[StartTime]),'')
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'End: ' + Coalesce(Convert(nvarchar(16),s.[EndTime]),'')
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'ErrorMessages: ' + Coalesce(Convert(nvarchar(1000),s.[ErrorMessages]),'')
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'Variables: ' + Coalesce(Convert(nvarchar(1000),s.[Variables]),'')
			+ CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + 'Message: ' + Coalesce(Convert(nvarchar(1000),s.[Message]),'')
			FROM LoadErrorDetailResult s
			WHERE s.JobExecutionID = t.JobExecutionID
			FOR XML PATH('')
				,TYPE
			).value('.', 'VARCHAR(MAX)'), 1, 1, '') AS Result
FROM LoadErrorDetailResult AS t
GROUP BY t.JobExecutionID
	,ClientID