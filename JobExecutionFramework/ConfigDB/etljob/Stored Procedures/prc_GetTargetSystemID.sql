
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-02-12
-- Description: Gets the ID of the Target system (Dev, QA, Prod etc. or All)
-- =============================================
CREATE PROCEDURE [etljob].[prc_GetTargetSystemID] @System NVARCHAR(255)
AS
SET NOCOUNT ON

DECLARE @SystemID INT,
	@msg NVARCHAR(255)

SELECT @SystemID = Coalesce(SystemID,0)
FROM [etljob].[vw_System]
WHERE [System] = @System

/*IF @SystemID IS NULL
BEGIN
	SET @msg = 'System ' + @System + ' not found in view etljob.vw_system'
	RAISERROR (
			@msg
			,16
			,1
			)
END
ELSE
	*/ Select @SystemID as TargetSystemID