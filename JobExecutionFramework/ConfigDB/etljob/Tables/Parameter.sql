CREATE TABLE [etljob].[Parameter] (
    [ParameterId]    INT             IDENTITY (1, 1) NOT NULL,
    [ParameterName]  NVARCHAR (255)  NULL,
    [DataType]       NVARCHAR (255)  CONSTRAINT [DF_Parameter_ParameterDataType] DEFAULT ('nvarchar(4000)') NULL,
    [DataTypeSSISDB] NVARCHAR (255)  NULL,
    [Description]    NVARCHAR (1024) NULL,
    [DateInserted]   DATETIME        CONSTRAINT [DF_Parameter_DateInserted] DEFAULT (getdate()) NULL,
    [DateDeleted]    DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([ParameterId] ASC)
);


