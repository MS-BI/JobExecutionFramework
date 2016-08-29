CREATE TABLE [etljob].[JobStepConstrain] (
    [JobStepConstrainID]  INT IDENTITY (1, 1) NOT NULL,
    [JobStepID]           INT NULL,
    [Constrain_JobStepID] INT NULL,
    CONSTRAINT [PK_JobStepConstrain] PRIMARY KEY CLUSTERED ([JobStepConstrainID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_JobStepConstrain_JobStepID_Constrain_JobStepID]
    ON [etljob].[JobStepConstrain]([JobStepID] ASC, [Constrain_JobStepID] ASC);

