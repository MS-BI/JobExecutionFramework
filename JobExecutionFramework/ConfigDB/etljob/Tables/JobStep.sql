CREATE TABLE [etljob].[JobStep] (
    [JobStepID]                  INT            IDENTITY (1, 1) NOT NULL,
    [JobStep]                    NVARCHAR (255) NULL,
    [JobID]                      INT            CONSTRAINT [DF_JobStep_JobID] DEFAULT ((1)) NOT NULL,
    [ApplicationID]              INT            NULL,
    [GroupID]                    INT            NULL,
    [PackageID]                  INT            NULL,
    [ClientID]                   INT            NULL,
    [LayerID]                    INT            NULL,
    [MetaGroupID]                INT            NULL,
    [StepNo]                     INT            NULL,
    [IsEnabled]                  SMALLINT       CONSTRAINT [DF_JobStep_Constrainte_Enable] DEFAULT ((0)) NOT NULL,
    [IsNotCritical]              SMALLINT       CONSTRAINT [DF_JobStep_IsNotCritical] DEFAULT ((0)) NOT NULL,
    [IsWithGrabConnectionString] SMALLINT       CONSTRAINT [DF_JobStep_IsWithGrabConnectionString] DEFAULT ((0)) NULL,
    [DateInserted]               DATETIME       CONSTRAINT [DF_JobStep_DateInserted] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_JobStep] PRIMARY KEY CLUSTERED ([JobStepID] ASC)
);














GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Should for this Jobstep the connection String used as a Parameter (unnexessary if Connection string is build in Package)', @level0type = N'SCHEMA', @level0name = N'etljob', @level1type = N'TABLE', @level1name = N'JobStep', @level2type = N'COLUMN', @level2name = N'IsWithGrabConnectionString';

