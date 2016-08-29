


CREATE VIEW [etljob].[vw_JobStepCluster]
AS
SELECT [JobStepClusterID]
      ,[JobStepCluster]
      ,[JobID]
      ,[ApplicationID]
      ,[GroupID]
      ,[LayerID]
      ,[MetaGroupID]
	  ,[StepNo]
      ,[StepNoEqual]		
	  ,[Retry]
      ,[FailedJobExecutionID]
      ,[LastRun]
	  ,[ExpectedRunTime]
  FROM [etljob].[JobStepCluster]
