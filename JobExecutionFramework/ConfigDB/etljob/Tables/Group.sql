CREATE TABLE [etljob].[Group] (
    [GroupID]   INT            IDENTITY (1, 1) NOT NULL,
    [Group] NVARCHAR (255) NULL,
    CONSTRAINT [PK_Group] PRIMARY KEY CLUSTERED ([GroupID] ASC)
);

