CREATE TABLE [etljob].[Client] (
    [ClientID] INT            IDENTITY (1, 1) NOT NULL,
    [Client]   NVARCHAR (255) NULL,
    CONSTRAINT [PK__Client__E67E1A047DBC5BF8] PRIMARY KEY CLUSTERED ([ClientID] ASC)
);


