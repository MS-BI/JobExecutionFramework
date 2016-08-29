SET IDENTITY_INSERT [etljob].[System] ON

MERGE INTO [etljob].[System] AS Target
USING (
	VALUES (
		0
		,N'All'
		)
		,(
		1
		,N'Development'
		)
		,(
		2
		,N'QA'
		)
		,(
		3
		,N'Production'
		)
	) AS Source([SystemID], [System])
	ON [Target].[SystemID] = [source].[SystemID]
WHEN MATCHED
	THEN
		UPDATE
		SET [System] = Source.[System]
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			[SystemID]
			,[System]
			)
		VALUES (
			[SystemID]
			,[System]
			);

SET IDENTITY_INSERT [etljob].[System] OFF
