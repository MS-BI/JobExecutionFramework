CREATE TABLE [etljob].[Recovery]
(
	[RecoveryId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [StartTime] DATETIME2 NULL DEFAULT getdate(), 
    [EndTime] DATETIME2 NULL
)
