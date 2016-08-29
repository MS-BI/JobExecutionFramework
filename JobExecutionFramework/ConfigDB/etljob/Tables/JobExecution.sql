CREATE TABLE [etljob].[JobExecution] (
    [JobExecutionID]      INT           IDENTITY (1, 1) NOT NULL,
    [JobID]               INT           NOT NULL,
    [ApplicationID]       INT           NULL,
    [GroupID]             INT           NULL,
    [ClientID]            INT           NOT NULL DEFAULT 0,
    [LayerID]             INT           NULL,
    [MetaGroupID]         INT           NULL,
    [JobStepClusterID]    INT           NULL,
    [StartTime]           DATETIME2 (7) NULL,
    [EndTime]             DATETIME2 (7) NULL,
    [Total]               INT           NULL,
    [Started]             INT           NULL,
    [Finished]            INT           NULL,
    [Failed]              INT           CONSTRAINT [DF_JobExecution_Failed] DEFAULT ((0)) NULL,
    [Abnormal]            INT           CONSTRAINT [DF_JobExecution_Failed1] DEFAULT ((0)) NULL,
    [CriticalAbnormal]    INT           CONSTRAINT [DF_JobExecution_CriticalFailed1] DEFAULT ((0)) NULL,
    [CriticalFailed]      INT           CONSTRAINT [DF_JobExecution_CriticallyFailed] DEFAULT ((0)) NULL,
    [SSISExecutionID]     BIGINT        NULL,
    [IsBlocked]           SMALLINT      CONSTRAINT [DF__tmp_ms_xx__Block__5D60DB10] DEFAULT ((0)) NULL,
    [MasterInternalError] SMALLINT      CONSTRAINT [DF_JobExecution_MasterInternalError] DEFAULT ((0)) NOT NULL,
    [RestartOf]           INT           CONSTRAINT [DF_JobExecution_RestartOf] DEFAULT ((0)) NULL,
    [StopRecoveryID] INT NULL DEFAULT 0, 
    [StoppedByStopID] INT NULL DEFAULT 0, 
    [StopMode] INT NULL DEFAULT 0, 
    [IsRecoveryDisabled] SMALLINT      CONSTRAINT [DF_IsRecoveryDisabled] DEFAULT ((0)) NULL,
    [ExcludingClusterID] INT NULL DEFAULT 0, 
    [AuditID]             INT           NULL,
    [Label] NVARCHAR(250) NULL DEFAULT '', 
    [JobExecutionEndStatusID] INT NULL DEFAULT 1, 
    CONSTRAINT [PK_JobExecution] PRIMARY KEY CLUSTERED ([JobExecutionID] ASC)
);









