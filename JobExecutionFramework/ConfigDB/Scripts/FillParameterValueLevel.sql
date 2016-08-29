SET IDENTITY_INSERT [etljob].[ParameterValueLevel] ON

MERGE INTO [etljob].[ParameterValueLevel] AS Target
USING (
	VALUES (
		1
		,N'JobStep'
		,1
		,NULL
		)
		,(
		2
		,N'Package'
		,2
		,30
		)
		,(
		3
		,N'Project'
		,3
		,20
		)
		,(
		4
		,N'Folder'
		,4
		,NULL
		)
		,(
		5
		,N'Application'
		,5
		,NULL
		)
	) AS Source([ParameterValueLevelID], [ParameterValueLevelName], [Order], [SSIS_Object_type])
	ON [Target].[ParameterValueLevelID] = [Source].[ParameterValueLevelID]
WHEN MATCHED
	THEN
		UPDATE
		SET [ParameterValueLevelName] = Source.[ParameterValueLevelName]
			,[Order] = Source.[Order]
			,[SSIS_Object_type] = Source.[SSIS_Object_type]
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			[ParameterValueLevelID]
			,[ParameterValueLevelName]
			,[Order]
			,[SSIS_Object_type]
			)
		VALUES (
			[ParameterValueLevelID]
			,[ParameterValueLevelName]
			,[Order]
			,[SSIS_Object_type]
			);

SET IDENTITY_INSERT [etljob].[ParameterValueLevel] OFF
