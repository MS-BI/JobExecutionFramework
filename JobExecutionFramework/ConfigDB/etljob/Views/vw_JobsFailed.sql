

CREATE VIEW [etljob].[vw_JobsFailed]
AS
WITH StepsFailed
AS (
	SELECT TOP (100) PERCENT CASE 
			WHEN IsNotCritical = 0
				THEN 'Critical: ' + JobStep
			ELSE 'Not Critical: ' + JobStep
			END AS JobStep
		,JobExecutionID
		,ClientID
	FROM [etljob].vw_LoadError
	ORDER BY IsNotCritical
		,StartTime
		,EndTime
	)
SELECT t.JobExecutionID
	,ClientID
	,'Failed :' + STUFF((
			SELECT CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + s.JobStep
			FROM StepsFailed s
			WHERE s.JobExecutionID = t.JobExecutionID
			FOR XML PATH('')
				,TYPE
			).value('.', 'VARCHAR(MAX)'), 1, 1, '') AS Errors
FROM StepsFailed AS t
GROUP BY t.JobExecutionID
	,ClientID