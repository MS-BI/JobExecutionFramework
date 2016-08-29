MERGE INTO [etljob].[JobExecutionEndStatus] AS Target
USING (
	VALUES (
		0
		,N'Unknown'
		)
		,(
		1
		,N'Running'
		)
		,(
		2
		,N'Succeeded'
		)
		,(
		3
		,N'WithWarnings'
		)
		,(
		4
		,N'Failed'
		)
		,(
		5
		,N'Blocked'
		)
		,(
		6
		,N'Stopped'
		)
		,(
		7
		,N'Started'
		)
		,(
		8
		,N'Waiting'
		)
	) AS Source([JobExecutionEndStatusID], [JobExecutionEndStatus])
	ON [Target].[JobExecutionEndStatusID] = [source].[JobExecutionEndStatusID]
WHEN MATCHED
	THEN
		UPDATE
		SET [JobExecutionEndStatus] = Source.[JobExecutionEndStatus]
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			[JobExecutionEndStatusID]
			,[JobExecutionEndStatus]
			)
		VALUES (
			[JobExecutionEndStatusID]
			,[JobExecutionEndStatus]
			);

