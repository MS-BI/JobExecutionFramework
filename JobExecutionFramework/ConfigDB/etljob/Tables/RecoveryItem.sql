﻿CREATE TABLE [etljob].[RecoveryItem] (
    [RecoveryItemId]           INT             IDENTITY (1, 1) NOT NULL,
    [JobStepClusterID]         INT             NOT NULL,
    [ClientID]                 INT             DEFAULT ((0)) NOT NULL,
    [JobExecutionID]           INT             NULL,
    [StopID]                   INT             NULL,
    [Scheduled]                DATETIME2 (7)   DEFAULT (getdate()) NOT NULL,
    [RecoveryType]             INT             NOT NULL,
    [RecoveryPriority]         INT             DEFAULT ((1)) NOT NULL,
    [RecoveryStart]            DATETIME2 (7)   NULL,
    [RecoveryEnd]              DATETIME2 (7)   NULL,
    [SSISExecutionID]          BIGINT          NULL,
    [RecoveringJobExecutionID] INT             NULL,
    [InitRecoveryId]           INT             NULL,
    [ExecRecoveryId]           INT             NULL,
    [ETLStatusID]              INT             NULL,
    [ETLStatusSource]          INT             NULL,
    [Message]                  NVARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([RecoveryItemId] ASC),
    CONSTRAINT [CK_RecoveryItem_RecoveryType] CHECK ([RecoveryType]=(2) OR [RecoveryType]=(1)),
    CONSTRAINT [FK_RecoveryItem_Client] FOREIGN KEY ([ClientID]) REFERENCES [etljob].[Client] ([ClientID]),
    CONSTRAINT [FK_RecoveryItem_JobExecution] FOREIGN KEY ([JobExecutionID]) REFERENCES [etljob].[JobExecution] ([JobExecutionID]),
    CONSTRAINT [FK_RecoveryItem_JobExecution_Recovering] FOREIGN KEY ([RecoveringJobExecutionID]) REFERENCES [etljob].[JobExecution] ([JobExecutionID]),
    CONSTRAINT [FK_RecoveryItem_JobStepCluster] FOREIGN KEY ([JobStepClusterID]) REFERENCES [etljob].[JobStepCluster] ([JobStepClusterID]),
    CONSTRAINT [FK_RecoveryItem_Recovery_Exec] FOREIGN KEY ([ExecRecoveryId]) REFERENCES [etljob].[Recovery] ([RecoveryId]),
    CONSTRAINT [FK_RecoveryItem_Recovery_Init] FOREIGN KEY ([InitRecoveryId]) REFERENCES [etljob].[Recovery] ([RecoveryId]),
    CONSTRAINT [FK_RecoveryItem_Stop] FOREIGN KEY ([StopID]) REFERENCES [etljob].[Stop] ([StopId])
);

