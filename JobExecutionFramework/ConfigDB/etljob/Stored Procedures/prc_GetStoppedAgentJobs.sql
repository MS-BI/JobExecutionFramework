CREATE PROC [etljob].[prc_GetStoppedAgentJobs] @JobCat SYSNAME
AS
DECLARE @startdate DATETIME
	,@endtime DATETIME
DECLARE @OutputTemp AS TABLE (StopId INT)

SET @endtime = getdate()

UPDATE etljob.stop
SET RecoveryEnd = @endtime
OUTPUT inserted.[StopID]
INTO @OutputTemp
WHERE etljob.stop.RecoveryEnd IS NULL

SELECT @startdate = min([StopStart])
FROM [etljob].[vw_Stop] s
INNER JOIN @OutputTemp o
	ON s.StopID = o.StopId

EXEC etljob.[prc_GetMissedJobID] @startdate
	,@endtime
	,@JobCat