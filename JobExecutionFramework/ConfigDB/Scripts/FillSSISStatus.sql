SET IDENTITY_INSERT [etljob].[SSISStatus] ON

MERGE INTO [etljob].[SSISStatus] AS Target
USING (
	VALUES (
		- 1
		,1
		,N'Halted'
		,0
		,1
		,1
		,0
		)
		,(
		0
		,0
		,N'Queued'
		,0
		,0
		,1
		,0
		)
		,(
		1
		,1
		,N'Created'
		,0
		,1
		,0
		,0
		)
		,(
		2
		,2
		,N'Running'
		,0
		,1
		,0
		,0
		)
		,(
		3
		,3
		,N'Canceled'
		,1
		,0
		,0
		,0
		)
		,(
		4
		,4
		,N'Failed'
		,1
		,0
		,0
		,0
		)
		,(
		5
		,5
		,N'Pending'
		,0
		,1
		,0
		,0
		)
		,(
		6
		,6
		,N'Ended Unexpectedly'
		,1
		,0
		,0
		,0
		)
		,(
		7
		,7
		,N'Succeeded'
		,0
		,0
		,0
		,1
		)
		,(
		8
		,8
		,N'Stopping'
		,0
		,1
		,0
		,0
		)
		,(
		9
		,9
		,N'Completed'
		,0
		,0
		,0
		,1
		)
		,(
		10
		,0
		,N'Stopped'
		,1
		,0
		,1
		,0
		)
		,(
		11
		,0
		,N'JobIgnored'
		,0
		,0
		,1
		,0
		)
	) AS Source([SSISStatusID], [SSISStatus], [StatusDescription], [IsFailed], [IsBlocking], [IsFrameworkInternal], [IsDone])
	ON [Target].[SSISStatusID] = [source].[SSISStatusID]
WHEN MATCHED
	THEN
		UPDATE
		SET SSISStatus = Source.SSISStatus
			,StatusDescription = Source.StatusDescription
			,IsFailed = Source.IsFailed
			,IsBlocking = Source.IsBlocking
			,IsFrameworkInternal = Source.IsFrameworkInternal
			,IsDone = Source.IsDone
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			[SSISStatusID]
			,[SSISStatus]
			,[StatusDescription]
			,[IsFailed]
			,[IsBlocking]
			,[IsFrameworkInternal]
			,[IsDone]
			)
		VALUES (
			[SSISStatusID]
			,[SSISStatus]
			,[StatusDescription]
			,[IsFailed]
			,[IsBlocking]
			,[IsFrameworkInternal]
			,[IsDone]
			);

SET IDENTITY_INSERT [etljob].[SSISStatus] OFF
