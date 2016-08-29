CREATE TABLE [etljob].[JobStepCluster] (
    [JobStepClusterID] INT            IDENTITY (1, 1) NOT NULL,
    [JobStepCluster]   NVARCHAR (255) CONSTRAINT [DF_JobStepCluster_JobStepCluster] DEFAULT ('') NOT NULL,
    [JobID]            INT            CONSTRAINT [DF_JobStepCluster_JobID] DEFAULT ((0)) NOT NULL,
    [ApplicationID]    INT            CONSTRAINT [DF_JobStepCluster_ApplicationID] DEFAULT ((0)) NOT NULL,
    [GroupID]          INT            CONSTRAINT [DF_JobStepCluster_GroupID] DEFAULT ((0)) NOT NULL,
    [LayerID]          INT            CONSTRAINT [DF_JobStepCluster_LayerID] DEFAULT ((0)) NOT NULL,
    [MetaGroupID]      INT            CONSTRAINT [DF_JobStepCluster_MetaGroupID] DEFAULT ((0)) NOT NULL,
    [StepNo]		   INT NOT NULL DEFAULT 0, 
    [StepNoEqual] INT NOT NULL DEFAULT 0,		
    [Retry] SMALLINT NOT NULL DEFAULT 0, 
    [FailedJobExecutionID] BIGINT NULL, 
    [LastRun] DATETIME NULL DEFAULT getdate(), 
    [ExpectedRunTime] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_JobStepCluster] PRIMARY KEY CLUSTERED ([JobStepClusterID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_JobStepClusterUnique]
    ON [etljob].[JobStepCluster]([ApplicationID] ASC, [GroupID] ASC, [JobID] ASC, [LayerID] ASC, [MetaGroupID] ASC, StepNo ASC, StepNoEqual ASC);

