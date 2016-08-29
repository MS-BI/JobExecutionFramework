CREATE TABLE [etljob].[SSISStatus] (
    [SSISStatusID]        BIGINT         IDENTITY (1, 1) NOT NULL,
    [SSISStatus]          SMALLINT       NULL,
    [StatusDescription]   NVARCHAR (255) NULL,
    [IsFailed]            SMALLINT       NULL,
    [IsBlocking]          SMALLINT       NULL,
    [IsFrameworkInternal] SMALLINT       NULL,
    [IsDone]              SMALLINT       NULL,
    CONSTRAINT [PK_SSISStatus] PRIMARY KEY CLUSTERED ([SSISStatusID] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'http://msdn.microsoft.com/en-us/library/ff878089.aspx', @level0type = N'SCHEMA', @level0name = N'etljob', @level1type = N'TABLE', @level1name = N'SSISStatus', @level2type = N'COLUMN', @level2name = N'SSISStatusID';

