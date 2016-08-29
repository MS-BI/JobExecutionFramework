CREATE TABLE [etljob].[JobStepClusterConstrain] (
    [JobStepClusterConstrainID] INT      IDENTITY (1, 1) NOT NULL,
    [JobStepClusterID]          INT      NOT NULL,
    [ConstrainJobStepClusterID] INT      NOT NULL,
    [IsDisabled]                SMALLINT CONSTRAINT [DF__JobStepCl__IsDis__03BB8E22] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__JobStepC__F125E3E428229BBB] PRIMARY KEY CLUSTERED ([JobStepClusterConstrainID] ASC)
);


