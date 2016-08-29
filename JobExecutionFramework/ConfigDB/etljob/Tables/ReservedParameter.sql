CREATE TABLE [etljob].[ReservedParameter]
(
	[ReservedParameterId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [ParameterName] NVARCHAR(255) NOT NULL, 
    [IsActive] TINYINT NOT NULL DEFAULT 1, 
    [Description] NVARCHAR(255) NULL
)

GO

CREATE UNIQUE INDEX [IX_ReservedParameter_ParameterName] ON [etljob].[ReservedParameter] ([ParameterName])
