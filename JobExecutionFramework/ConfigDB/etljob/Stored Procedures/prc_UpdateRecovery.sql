
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-06-10
-- Updates EndTime in Recovery
-- =============================================
Create PROCEDURE [etljob].[prc_UpdateRecovery] @RecoveryID AS INT
AS
SET NOCOUNT ON

UPDATE Re
SET Re.EndTime = IsNull(Re.EndTime, GetDate())
FROM [etljob].vw_Recovery Re