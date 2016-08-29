CREATE TABLE [etljob].[ParameterValueLevel] (
    [ParameterValueLevelID]   INT            IDENTITY (1, 1) NOT NULL,
    [ParameterValueLevelName] NVARCHAR (255) NULL,
    [Order]                  INT            NULL,
    [SSIS_Object_type]       SMALLINT       NULL,
    CONSTRAINT [PK_ParameterValueLevel] PRIMARY KEY CLUSTERED ([ParameterValueLevelID] ASC)
);



