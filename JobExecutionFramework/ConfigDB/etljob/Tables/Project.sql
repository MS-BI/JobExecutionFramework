CREATE TABLE [etljob].[Project] (
    [ProjectID]        INT            IDENTITY (1, 1) NOT NULL,
    [SSISDBProject_ID] BIGINT         NULL,
    [FolderID]         INT            NULL,
    [ProjectName]      NVARCHAR (255) NULL,
    [DateInserted]     DATETIME       CONSTRAINT [DF_Project_DateInserted] DEFAULT (getdate()) NULL,
    [DateDeleted]      DATETIME       NULL,
    CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED ([ProjectID] ASC),
    CONSTRAINT [FK_Project_Folder] FOREIGN KEY ([FolderID]) REFERENCES [etljob].[Folder] ([FolderID])
);








GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Project_FolderID_ProjectName]
    ON [etljob].[Project]([FolderID] ASC, [ProjectName] ASC);

