CREATE VIEW [etljob].[vw_LoadMessages]
AS
WITH EventMessages
AS (
	SELECT operation_id AS ID
		,message AS Msg
	FROM [etljob].vw_SSISErrorMessages
	)
SELECT t.ID
	,'Error :' + STUFF((
			SELECT CONVERT(CHAR(1), 0x0D) + CONVERT(CHAR(1), 0x0A) + s.Msg
			FROM EventMessages s
			WHERE s.ID = t.ID
			FOR XML PATH('')
				,TYPE
			).value('.', 'VARCHAR(MAX)'), 1, 1, '') AS ErrorMessages
FROM EventMessages AS t
GROUP BY t.ID