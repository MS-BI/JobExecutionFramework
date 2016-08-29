SET IDENTITY_INSERT [etljob].[Job] ON

MERGE INTO [etljob].[Job] AS Target
USING (
	VALUES (
		0
		,N'ETL Framework Intern'
		)
		
	) AS Source([JobID], [Job])
	ON [Target].[JobID] = [source].[JobID]
WHEN MATCHED
	THEN
		UPDATE
		SET [Job] = Source.[Job]
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			[JobID]
			,[Job]
			)
		VALUES (
			[JobID]
			,[Job]
			);

SET IDENTITY_INSERT [etljob].[Job] OFF
