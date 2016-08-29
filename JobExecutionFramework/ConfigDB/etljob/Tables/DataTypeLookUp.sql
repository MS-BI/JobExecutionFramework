CREATE TABLE [etljob].[DataTypeLookUp] (
    [DataTypeLookUpID] INT            IDENTITY (1, 1) NOT NULL,
    [SSISDB_Type]      NVARCHAR (255) NULL,
    [SQL_ServerType]   NVARCHAR (255) NULL,
    CONSTRAINT [PK_DataTypeLookUp] PRIMARY KEY CLUSTERED ([DataTypeLookUpID] ASC)
);

