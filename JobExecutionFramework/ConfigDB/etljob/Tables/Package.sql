CREATE TABLE [etljob].[Package] (
    [PackageID]        INT              IDENTITY (1, 1) NOT NULL,
    [ProjectID]        INT              NULL,
    [PackageName]      NVARCHAR (255)   NULL,
    [package_guid]     UNIQUEIDENTIFIER NULL,
    [SSISDBProject_id] BIGINT           NULL,
    [SSISDBPackage_id] BIGINT           NULL,
    [Description]      NVARCHAR (255)   NULL,
    [ProjectName]      NVARCHAR (255)   NULL,
    [FolderName]       NVARCHAR (255)   NULL,
    [MaxNoOfJobs]      INT              CONSTRAINT [DF_Package_MaxNoOfJobs] DEFAULT ((0)) NOT NULL,
    [DateInserted]     DATETIME         CONSTRAINT [DF_Package_DateInserted] DEFAULT (getdate()) NULL,
    [DateDeleted]      DATETIME         NULL,
    CONSTRAINT [PK_etljob.Package] PRIMARY KEY CLUSTERED ([PackageID] ASC),
    CONSTRAINT [FK_Package_Project] FOREIGN KEY ([ProjectID]) REFERENCES [etljob].[Project] ([ProjectID])
);
















GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Package_ProjectID_PackageName]
    ON [etljob].[Package]([ProjectID] ASC, [PackageName] ASC);

