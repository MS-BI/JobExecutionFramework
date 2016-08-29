
-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2014-07-30
-- Description: Gets Failed Packages for Job with executionID @JobExecutionID
-- =============================================
CREATE PROC [etljob].[prc_FailedPackages] @JobExecutionID AS INT

AS
SET NOCOUNT ON;
Select  Max(Coalesce(Errors,'')) as Errors from [etljob].[vw_JobsFailed]  Where  JobExecutionID = @JobExecutionID
