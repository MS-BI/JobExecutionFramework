-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-08-12
-- Description: Lists Depending JobSteps
-- =============================================
CREATE FUNCTION [etljob].[fn_GetDependingJobSteps] (@JobStepID INT)
RETURNS @OutTbl TABLE (
	JobStepID INT
	,P INT
	,LEVEL INT
	)
AS
BEGIN
	DECLARE @Level INT = 0

	INSERT INTO @OutTbl (
		JobStepID
		,P
		,LEVEL
		)
	VALUES (
		@jobStepID
		,@jobStepID
		,@Level
		)

	WHILE @@RowCount > 0
	BEGIN
		SET @Level = @Level + 1

		INSERT INTO @OutTbl (
			JobStepID
			,P
			,LEVEL
			)
		SELECT C.[JobStepID]
			,C.[Constrain_JobStepID]
			,@level
		FROM [etljob].[vw_JobStepConstrain] C
		INNER JOIN @OutTbl T ON C.Constrain_JobStepID = T.JobStepID
			AND T.LEVEL = @Level - 1
	END

	DELETE @OutTbl
	WHERE JobStepID = @JobStepID

	RETURN
END