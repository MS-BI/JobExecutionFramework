CREATE VIEW [etljob].[vw_Parameter]
AS
SELECT ParameterID
	,ParameterName
	,DataType
	,DataTypeSSISDB
	,Description
FROM etljob.Parameter