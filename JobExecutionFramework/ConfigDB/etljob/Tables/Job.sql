CREATE TABLE [etljob].[Job] (
    [JobID]   INT            IDENTITY (1, 1) NOT NULL,
    [Job] NVARCHAR (255) NULL,
    CONSTRAINT [PK_Job] PRIMARY KEY CLUSTERED ([JobID] ASC)
);

