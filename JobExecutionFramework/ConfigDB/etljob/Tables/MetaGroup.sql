CREATE TABLE [etljob].[MetaGroup] (
    [MetaGroupID]   INT            IDENTITY (1, 1) NOT NULL,
    [MetaGroup] NVARCHAR (255) NULL,
    CONSTRAINT [PK_MetaGroup] PRIMARY KEY CLUSTERED ([MetaGroupID] ASC) 
);

