SET IDENTITY_INSERT [etljob].[DataTypeLookUp] ON

MERGE INTO [etljob].[DataTypeLookUp] AS Target
USING (
	VALUES (
		1
		,N'Boolean'
		,N'bit'
		)
		,(
		2
		,N'Int32'
		,N'int'
		)
		,(
		3
		,N'Int64'
		,N'bigint'
		)
		,(
		4
		,N'String'
		,N'nvarchar'
		)
		,(
		5
		,N'Int16'
		,N'smallint'
		)
		,(
		6
		,N'DateTime'
		,N'datetime'
		)
	) AS Source([DataTypeLookUpID], [SSISDB_Type], [SQL_ServerType])
	ON [Target].[SSISDB_Type] = [source].[SSISDB_Type]
WHEN MATCHED
	THEN
		UPDATE
		SET SQL_ServerType = Source.SQL_ServerType
WHEN NOT MATCHED BY TARGET
	THEN
		INSERT (
			[DataTypeLookUpID]
			,[SSISDB_Type]
			,[SQL_ServerType]
			)
		VALUES (
			[DataTypeLookUpID]
			,[SSISDB_Type]
			,[SQL_ServerType]
			);

SET IDENTITY_INSERT [etljob].[DataTypeLookUp] OFF
