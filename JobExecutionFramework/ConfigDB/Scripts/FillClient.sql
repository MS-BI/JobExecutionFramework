SET IDENTITY_INSERT [etljob].[Client] ON

MERGE INTO [etljob].[Client] AS Target
USING (
	VALUES (
		0
		,N'All'
		)
		
	) AS Source([ClientID], [Client])
	ON [Target].[ClientID] = [source].[ClientID]
WHEN MATCHED
	THEN
		UPDATE
		SET [Client] = Source.[Client]
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			[ClientID]
			,[Client]
			)
		VALUES (
			[ClientID]
			,[Client]
			);

SET IDENTITY_INSERT [etljob].[Client] OFF
