CREATE TABLE [etljob].[Layer] (
    [LayerID]       INT            IDENTITY (1, 1) NOT NULL,
    [Layer]         NVARCHAR (255) NULL,
    [PackagePrefix] NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([LayerID] ASC)
);


