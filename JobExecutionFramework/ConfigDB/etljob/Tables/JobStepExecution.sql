CREATE TABLE [etljob].[JobStepExecution] (
    [JobStepExecutionID] INT             IDENTITY (1, 1) NOT NULL,
    [JobStepID]          INT             NOT NULL,
    [JobExecutionID]     INT             NULL,
    [JobID]              INT             NULL,
    [ApplicationID]      INT             NULL,
    [GroupID]            INT             NULL,
    [PackageID]          INT             NULL,
    [ClientID]           INT             NULL,
    [LayerID]            INT             NULL,
    [MetaGroupID]        INT             NULL,
    [ETLStatusID]        INT             CONSTRAINT [DF_JobStepExecution_ETLStatusID] DEFAULT ((0)) NULL,
    [JobStepClusterID]   INT             NULL,
    [StepNo]             INT             NULL,
    [StartTime]          DATETIME2 (7)   NULL,
    [EndTime]            DATETIME2 (7)   NULL,
    [SSISExecutionID]    BIGINT          NULL,
    [ETLStatusSource]    INT             CONSTRAINT [DF_JobStepExecution_ETLStatusSource] DEFAULT ((0)) NULL,
    [Message]            NVARCHAR (4000) NULL,
    [IsNotCritical]      SMALLINT        CONSTRAINT [DF_JobStepExecution_IsNotCritical] DEFAULT ((0)) NOT NULL,
    [AuditID]            INT             CONSTRAINT [DF_JobStepExecution_AuditID] DEFAULT ((0)) NULL,
    CONSTRAINT [PK__JobStepE__A75A6A53F32B0139] PRIMARY KEY CLUSTERED ([JobStepExecutionID] ASC)
);











GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0: SSISDB; 1: Framework', @level0type = N'SCHEMA', @level0name = N'etljob', @level1type = N'TABLE', @level1name = N'JobStepExecution', @level2type = N'COLUMN', @level2name = N'ETLStatusSource';

