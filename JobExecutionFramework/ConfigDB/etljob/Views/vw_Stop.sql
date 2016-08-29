CREATE VIEW [etljob].[vw_Stop]
AS
SELECT [StopID]
      ,[StopStart]
      ,[StopEnd]
      ,[RecoveryEnd]
      ,[StopDescription]
      ,[IsEnabled]
  FROM [etljob].[Stop]