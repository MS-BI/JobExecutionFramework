-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-06-02
-- Description: Counts packages Started by specified Job and all packages running in project mode
-- ToDo: Eliminate explicit reference to SSISDB, Status Check by Field in etljob.SSISStatus
-- =============================================
CREATE PROCEDURE [etljob].[prc_InitRecovery]
AS
Set Nocount On;

DECLARE @OutputTemp AS TABLE (RecoveryId INT)
DECLARE @RecoveryId INT

INSERT INTO etljob.Recovery (StartTime)
OUTPUT inserted.[RecoveryID]
INTO @OutputTemp
VALUES (getdate())

SELECT TOP (1) RecoveryId
FROM @OutputTemp

RETURN 0
