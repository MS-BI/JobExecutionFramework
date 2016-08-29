CREATE TABLE [etljob].[JobStepClusterExclusion] (
    [JobStepClusterExclusionID] INT      IDENTITY (1, 1) NOT NULL,
    [JobStepClusterID]          INT      NOT NULL,
    [ExclusionJobStepClusterID] INT      NOT NULL,
    [IsDisabled]                SMALLINT CONSTRAINT [DF_JobStepCluster_IsDisabled] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__JobStepClusterExclusion] PRIMARY KEY CLUSTERED ([JobStepClusterExclusionID] ASC)
);


