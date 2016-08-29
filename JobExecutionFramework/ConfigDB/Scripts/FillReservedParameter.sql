SET IDENTITY_INSERT [etljob].[ReservedParameter] ON

MERGE INTO [etljob].[ReservedParameter] AS Target
USING (
	VALUES (
		1
		,N'int_ClientID'
		)
		,(
		2
		,N'bool_IsInitialLoad'
		)
		,(
		3
		,N'int_ParentAuditID'
		)
		,(
		4
		,N'guid_ParentSourceGUID'
		)
	) AS Source([ReservedParameterID], [ParameterName])
	ON [Target].[ReservedParameterID] = [source].[ReservedParameterID]
WHEN MATCHED
	THEN
		UPDATE
		SET [ParameterName] = Source.[ParameterName]
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			[ReservedParameterID]
			,[ParameterName]
			)
		VALUES (
			[ReservedParameterID]
			,[ParameterName]
			);

SET IDENTITY_INSERT [etljob].[ReservedParameter] OFF
