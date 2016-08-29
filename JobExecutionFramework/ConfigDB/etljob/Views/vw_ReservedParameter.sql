CREATE VIEW [etljob].[vw_ReservedParameter]
AS
SELECT [ReservedParameterId]
      ,[ParameterName]
      ,[IsActive]
      ,[Description]
FROM [etljob].[ReservedParameter]
