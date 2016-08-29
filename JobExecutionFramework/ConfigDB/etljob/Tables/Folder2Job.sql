CREATE TABLE [etljob].[Folder2Job] (
    [Folder2JobID]     INT            IDENTITY (1, 1) NOT NULL,
    [FolderID]         INT            NULL,
    [ProjectID]        INT            NULL,
    [PackageMask]      NVARCHAR (255) NULL,
    [JobID]            INT            NOT NULL,
    [LayerID]          INT            NULL,
    [ApplicationID]    INT            NULL,
    [GroupID]          INT            NULL,
    [MetaGroupID]      INT            NULL,
    [IsSettingEnabled] SMALLINT       CONSTRAINT [DF_Folder2Job_IsSettingEnabled] DEFAULT ((0)) NULL,
    [IsFrozen]         SMALLINT       CONSTRAINT [DF_Folder2Job_IsFrozen] DEFAULT ((0)) NULL,
    [IsActive]         SMALLINT       CONSTRAINT [DF_Folder2Job_IsActive] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_Folder2JobLayer] PRIMARY KEY CLUSTERED ([Folder2JobID] ASC),
    CONSTRAINT [CK_Folder2Job_FolderOrProject] CHECK (NOT ([FolderID] IS NULL AND [ProjectID] IS NULL) AND ([FolderID] IS NULL OR [ProjectID] IS NULL)),
    CONSTRAINT [FK_Folder2Job_Application] FOREIGN KEY ([ApplicationID]) REFERENCES [etljob].[Application] ([ApplicationID]),
    CONSTRAINT [FK_Folder2Job_Folder] FOREIGN KEY ([FolderID]) REFERENCES [etljob].[Folder] ([FolderID]),
    CONSTRAINT [FK_Folder2Job_Folder2Job] FOREIGN KEY ([Folder2JobID]) REFERENCES [etljob].[Folder2Job] ([Folder2JobID]),
    CONSTRAINT [FK_Folder2Job_Group] FOREIGN KEY ([GroupID]) REFERENCES [etljob].[Group] ([GroupID]),
    CONSTRAINT [FK_Folder2Job_Job] FOREIGN KEY ([JobID]) REFERENCES [etljob].[Job] ([JobID]),
    CONSTRAINT [FK_Folder2Job_Layer] FOREIGN KEY ([LayerID]) REFERENCES [etljob].[Layer] ([LayerID]),
    CONSTRAINT [FK_Folder2Job_MetaGroup] FOREIGN KEY ([MetaGroupID]) REFERENCES [etljob].[MetaGroup] ([MetaGroupID]),
    CONSTRAINT [FK_Folder2Job_Project] FOREIGN KEY ([ProjectID]) REFERENCES [etljob].[Project] ([ProjectID])
);












GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Folder2Job]
    ON [etljob].[Folder2Job]([FolderID] ASC, [JobID] ASC, [ProjectID] ASC);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Either Specify Folder or Project', @level0type = N'SCHEMA', @level0name = N'etljob', @level1type = N'TABLE', @level1name = N'Folder2Job', @level2type = N'CONSTRAINT', @level2name = N'CK_Folder2Job_FolderOrProject';

