CREATE TABLE [etljob].[JobStepException] (
    [JobStepExceptionID] INT            IDENTITY (1, 1) NOT NULL,
    [JobStepID]          INT            NOT NULL,
    [ClientID]           INT            NOT NULL,
    [IsAllowed]          SMALLINT       DEFAULT ((0)) NOT NULL,
    [Remark]             NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([JobStepExceptionID] ASC),
    CONSTRAINT [CK_JobStepException_Column] CHECK ([IsAllowed]=(1) OR [IsAllowed]=(0))
);


