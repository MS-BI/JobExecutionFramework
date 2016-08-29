CREATE PROCEDURE [etljob].[prc_GetStopID] @TimeStamp DATETIME2(7) = Null

-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-06-01
-- Description: Gets the (Max) ID of active Stop, 0 if no Stop is active at @TimeStamp
-- =============================================
AS
DECLARE @StopID INT

SET @TimeStamp = Coalesce(@TimeStamp, getdate())

SELECT Coalesce(max(StopID), -1) AS StopID
FROM etljob.vw_Stop
WHERE @TimeStamp BETWEEN StopStart
		AND StopEnd
	AND [IsEnabled] <> 0

RETURN 0