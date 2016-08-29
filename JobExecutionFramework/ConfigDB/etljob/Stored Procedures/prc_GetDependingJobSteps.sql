-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-08-12
-- Description: Lists Depending JobSteps
-- =============================================
CREATE PROCEDURE [etljob].[prc_GetDependingJobSteps] @JobStepID AS INT

AS
SET NOCOUNT ON;
DECLARE @OutTbl AS TABLE (
	JobStepID INT
	,P INT
	,LEVEL INT
	);
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

SELECT JobStepID, P, Level
FROM @OutTbl
WHERE JobStepID <> @JobStepID