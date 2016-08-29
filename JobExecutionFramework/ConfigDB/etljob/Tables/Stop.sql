CREATE TABLE [etljob].[Stop]
(
	[StopId] INT NOT NULL   IDENTITY (1, 1) PRIMARY KEY, 
    [StopStart] DATETIME2 NULL, 
    [StopEnd] DATETIME2 NULL, 
    [RecoveryEnd] DATETIME2 NULL, 
    [StopDescription] NVARCHAR(255) NULL, 
    [IsEnabled] SMALLINT NULL DEFAULT 1
)
