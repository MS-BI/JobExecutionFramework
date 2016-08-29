SET IDENTITY_INSERT [etljob].[Application] ON

MERGE INTO [etljob].[Application] AS Target
USING (
	VALUES (
		0
		,N'ETL Framework'
		)
		
	) AS Source([ApplicationID], [Application])
	ON [Target].[ApplicationID] = [source].[ApplicationID]
WHEN MATCHED
	THEN
		UPDATE
		SET [Application] = Source.[Application]
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			[ApplicationID]
			,[Application]
			)
		VALUES (
			[ApplicationID]
			,[Application]
			);

SET IDENTITY_INSERT [etljob].[Application] OFF
