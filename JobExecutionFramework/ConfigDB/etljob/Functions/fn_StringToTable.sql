CREATE FUNCTION [etljob].[fn_StringToTable]
(
   @String VARCHAR(max), /* input string */
   @Delimeter char(1),   /* delimiter */
   @TrimSpace bit)      /* kill whitespace? */
RETURNS @Table TABLE ( [Val] VARCHAR(4000) )
AS
BEGIN
    DECLARE @Val    VARCHAR(4000)
    WHILE LEN(@String) > 0
    BEGIN
        SET @Val    = LEFT(@String,
             ISNULL(NULLIF(CHARINDEX(@Delimeter, @String) - 1, -1),
             LEN(@String)))
        SET @String = SUBSTRING(@String,
             ISNULL(NULLIF(CHARINDEX(@Delimeter, @String), 0),
             LEN(@String)) + 1, LEN(@String))
  IF @TrimSpace = 1 Set @Val = LTRIM(RTRIM(@Val))
    INSERT INTO @Table ( [Val] )
        VALUES ( @Val )
    END
    RETURN
END