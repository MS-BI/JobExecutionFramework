-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-02-12
-- Description: Lists Parameters And their Configured Values for Package from the JobStep belongig to specified JobStepExecutionID.
-- Allways Checks Is there is a Value for the proposed Sytem (Dev, QA etc.) otherwise gets Value for SystemID 0 (All Systems)
-- Change 2015.03.12 (CS): Now based on [etljob].vw_ParameterValuesForJobStep
-- Change 2015.09.02 (CS): Filter Parameters not in ReservedParameter
-- =============================================
CREATE FUNCTION [etljob].[fn_ParameterValuesForJobStep] (
	@JobStepExecutionID INT
	,@SystemID INT
	)
RETURNS @OutTbl TABLE (
	[object_type] [smallint]
	,[parameter_name] [sysname]
	,[data_type] [nvarchar](128)
	,[SQL_ServerType] [nvarchar](255)
	,[required] [bit]
	,[design_default_value] [sql_variant]
	,[Val] [sql_variant]
	,JobStepId INT
	)
AS
BEGIN
	DECLARE @JobStepID INT

	SELECT @JobStepID = JobStepID
	FROM [etljob].[vw_JobStepExecution]
	WHERE JobStepExecutionID = @JobStepExecutionID;

	WITH cte2BeFiltered -- Row_number() cannot be used in Filter -> hide with cte
	AS (
		SELECT p.[object_type]
			,p.[parameter_name]
			,p.[data_type]
			,p.[SQL_ServerType]
			,p.[required]
			,p.[design_default_value]
			,p.val
			,row_number() OVER (
				PARTITION BY p.JobStepID
				,ParameterID ORDER BY Coalesce(p.SystemID, 0) DESC
				) AS FilterMustBeOne
			,JobStepID
		FROM [etljob].vw_ParameterValuesForJobStep p
		WHERE p.[JobStepID] = @JobStepID
			AND p.[parameter_name] NOT IN (
				SELECT [ParameterName]
				FROM [etljob].[vw_ReservedParameter]
				)
			AND p.SystemID IN (
				0
				,@SystemID
				)
		)
	INSERT INTO @OutTbl (
		[object_type]
		,[parameter_name]
		,[data_type]
		,[SQL_ServerType]
		,[required]
		,[design_default_value]
		,Val
		,JobStepId
		)
	SELECT p.[object_type]
		,p.[parameter_name]
		,p.[data_type]
		,p.[SQL_ServerType]
		,p.[required]
		,p.[design_default_value]
		,p.val
		,JobStepID
	FROM cte2BeFiltered p
	WHERE p.FilterMustBeOne = 1

	RETURN
END
