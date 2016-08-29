CREATE VIEW [etljob].[vw_LoadVariables]
AS
WITH EventMessages
AS (
	SELECT DISTINCT TOP (100) PERCENT [etljob].vw_SSISErrorMessages.operation_id AS ID
		,[etljob].[vw_SSISEventMessageContext].context_source_name + ': ' + convert(NVARCHAR(1000), [etljob].[vw_SSISEventMessageContext].property_value) AS Variable
	FROM [etljob].vw_SSISErrorMessages
	INNER JOIN [etljob].[vw_SSISEventMessageContext] ON [etljob].vw_SSISErrorMessages.event_message_id = [etljob].[vw_SSISEventMessageContext].event_message_id
	WHERE ([etljob].[vw_SSISEventMessageContext].context_type = 70)
		AND ([etljob].[vw_SSISEventMessageContext].context_depth = 1)
	ORDER BY 1
		,2
	)
SELECT t.ID
	,STUFF((
			SELECT CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + s.Variable
			FROM EventMessages s
			WHERE s.ID = t.ID
			FOR XML PATH('')
				,TYPE
			).value('.', 'VARCHAR(MAX)'), 1, 1, '') AS Variables
FROM EventMessages AS t
GROUP BY t.ID