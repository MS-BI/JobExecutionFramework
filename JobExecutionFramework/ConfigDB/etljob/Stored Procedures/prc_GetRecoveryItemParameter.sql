-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-06-04
-- Description: Gets the 
-- =============================================

CREATE PROCEDURE [etljob].[prc_GetRecoveryItemParameter] @RecoveryItemID Int
AS
SELECT RecovItem.RecoveryItemId
	,RecovItem.ClientID
	,RecovItem.RecoveryType
	,Cluster.JobID
	,Cluster.ApplicationID
	,Cluster.GroupID
	,Cluster.LayerID
	,Cluster.MetaGroupID
	,Cluster.StepNo
	,Cluster.StepNoEqual
FROM etljob.vw_RecoveryItem AS RecovItem
INNER JOIN etljob.vw_JobStepCluster AS Cluster
	ON RecovItem.JobStepClusterID = Cluster.JobStepClusterID
WHERE RecovItem.RecoveryItemId = @RecoveryItemID
