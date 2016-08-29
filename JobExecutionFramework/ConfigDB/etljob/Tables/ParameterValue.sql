CREATE TABLE [etljob].[ParameterValue] (
    [ParameterValueID]       INT         IDENTITY (1, 1) NOT NULL,
    [ParameterValueObjectID] INT         NOT NULL,
    [ParameterValueLevelID]  INT         NOT NULL,
    [SystemID]               INT         CONSTRAINT [DF__Parameter__Syste__10AB74EC] DEFAULT ((0)) NOT NULL,
    [ParameterID]            INT         NOT NULL,
    [ParameterValue]         SQL_VARIANT NULL,
    [IsActive]               SMALLINT    CONSTRAINT [DF__Parameter__IsAct__1293BD5E] DEFAULT ((1)) NOT NULL,
    [DateInserted]           DATETIME    CONSTRAINT [DF_ParameterValue_DateInserted] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ParameterValue] PRIMARY KEY CLUSTERED ([ParameterValueID] ASC),
    CONSTRAINT [CK_ParameterValue_IsActive] CHECK ([IsActive]=(1) OR [IsActive]=(0)),
    CONSTRAINT [FK_ParameterValue_Parameter] FOREIGN KEY ([ParameterID]) REFERENCES [etljob].[Parameter] ([ParameterId]),
    CONSTRAINT [FK_ParameterValue_ParameterValueLevel] FOREIGN KEY ([ParameterValueLevelID]) REFERENCES [etljob].[ParameterValueLevel] ([ParameterValueLevelID])
);











GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ParameterValue]
    ON [etljob].[ParameterValue]([ParameterID] ASC, [ParameterValueLevelID] ASC, [ParameterValueObjectID] ASC);


GO


-- =============================================
-- Author:		 (Ceteris AG; Christoph Seck)
-- Create date: 2015-09-07
-- Change CS 2015-09-09: Include first error in Message
-- Description: Checks Base Type of ParameterValue against etljob.Parameter
-- =============================================
CREATE TRIGGER [etljob].[tr_ParameterValue_After_Insert_Update] ON [etljob].[ParameterValue]
AFTER INSERT
	,UPDATE
AS
BEGIN
	IF @@ROWCOUNT = 0
		RETURN

	SET NOCOUNT ON

	DECLARE @FirstError NVARCHAR(250)

	SELECT TOP (1) @FirstError = p.ParameterName + ': ' + convert(NVARCHAR(250), sql_variant_property(i.ParameterValue, 'BaseType')) + '/' + p.DataType
	FROM [etljob].[vw_Parameter] p
	INNER JOIN inserted i
		ON p.ParameterID = i.ParameterID
	WHERE p.DataType <> sql_variant_property(i.ParameterValue, 'BaseType')

	IF NOT @FirstError IS NULL
	BEGIN
		IF EXISTS (
				SELECT *
				FROM DELETED
				)
			UPDATE pv
			SET pv.DateInserted = d.DateInserted
				,pv.IsActive = d.IsActive
				,pv.ParameterValue = d.ParameterValue
				,pv.ParameterID = d.ParameterID
				,ParameterValueLevelID = d.ParameterValueLevelID
				,pv.ParameterValueObjectID = d.ParameterValueObjectID
				,pv.SystemID = d.SystemID
			FROM [etljob].[ParameterValue] pv
			INNER JOIN deleted d
				ON PV.ParameterValueID = d.ParameterValueID
		ELSE
			DELETE [etljob].[ParameterValue]
			WHERE ParameterValueID IN (
					SELECT ParameterValueID
					FROM inserted
					)

		RAISERROR (
				'Base Type of ParameterValue is different from Value in etljob.Parameter: %s'
				,16
				,1
				,@FirstError
				)
	END
END
