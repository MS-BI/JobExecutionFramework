
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-06-02
-- Description: Searches for next RecoveryItem and sets its ExecRecoveryId
-- Items are ordered by priority and originally scheduled time
-- 
-- =============================================
CREATE PROCEDURE [etljob].[prc_GetNextRecoveryItem] @RecoveryID AS INT
AS
SET NOCOUNT ON;

/* Next in Queue */
DECLARE @OutTbl AS TABLE (RecoveryItemId INT);

INSERT INTO @OutTbl (RecoveryItemId)
SELECT [RecoveryItemId]
FROM (
	UPDATE [etljob].[RecoveryItem]
	SET [RecoveryStart] = GetDate()
		,ExecRecoveryId = @RecoveryId
	OUTPUT inserted.[RecoveryItemId]
	WHERE [RecoveryItemId] = (
			SELECT TOP 1 [RecoveryItemId]
			FROM [etljob].[vw_RecoveryItem]
			WHERE RecoveryStart IS NULL
				AND RecoveryPriority >= 0
			ORDER BY [RecoveryPriority]
				,Scheduled
			)
	) AS X

IF @@RowCount = 0
BEGIN
	SELECT CAST(- 1 AS INT) AS [RecoveryItemId]
		,0 AS StopRecoveryID
END
ELSE
BEGIN
	SELECT o.[RecoveryItemId]
		,coalesce(r.[StopID], 0) AS StopRecoveryID
	FROM @OutTbl o
	LEFT OUTER JOIN [etljob].[vw_RecoveryItem] r
		ON o.RecoveryItemId = r.ExecRecoveryId
END;
