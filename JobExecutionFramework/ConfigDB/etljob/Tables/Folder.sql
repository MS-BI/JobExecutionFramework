CREATE TABLE [etljob].[Folder] (
    [FolderID]        INT            IDENTITY (1, 1) NOT NULL,
    [SSISDBFolder_ID] BIGINT         NULL,
    [Foldername]      NVARCHAR (255) NULL,
    [DateInserted]    DATETIME       CONSTRAINT [DF_Folder_DateInserted] DEFAULT (getdate()) NULL,
    [DateDeleted]     DATETIME       NULL,
    CONSTRAINT [PK_Folder] PRIMARY KEY CLUSTERED ([FolderID] ASC)
);



