 
CREATE PROCEDURE [internal].[cleanup_server_retention_window]
WITH EXECUTE AS 'AllSchemaOwner'
AS
    SET NOCOUNT ON
    
    DECLARE @enable_clean_operation bit
    DECLARE @retention_window_length int
    
    DECLARE @caller_name nvarchar(256)
    DECLARE @caller_sid  varbinary(85)
    DECLARE @operation_id bigint
    
	EXECUTE AS CALLER
        SET @caller_name =  SUSER_NAME()
        SET @caller_sid =   SUSER_SID()
	REVERT
         
    
    BEGIN TRY
        SELECT @enable_clean_operation = CONVERT(bit, property_value) 
            FROM [catalog].[catalog_properties]
            WHERE property_name = 'OPERATION_CLEANUP_ENABLED'
        
        IF @enable_clean_operation = 1
        BEGIN
            SELECT @retention_window_length = CONVERT(int,property_value)  
                FROM [catalog].[catalog_properties]
                WHERE property_name = 'RETENTION_WINDOW'
                
            IF @retention_window_length <= 0 
            BEGIN
                RAISERROR(27163    ,16,1,'RETENTION_WINDOW')
            END
            
            INSERT INTO [internal].[operations] (
                [operation_type],  
                [created_time], 
                [object_type],
                [object_id],
                [object_name],
                [status], 
                [start_time],
                [caller_sid], 
                [caller_name]
                )
            VALUES (
                2,
                SYSDATETIMEOFFSET(),
                NULL,                     
                NULL,                     
                NULL,                     
                1,      
                SYSDATETIMEOFFSET(),
                @caller_sid,            
                @caller_name            
                ) 
            SET @operation_id = SCOPE_IDENTITY() 
            
            DECLARE @temp_date datetime
            DECLARE @rows_affected bigint
            DECLARE @delete_batch_size int
            DECLARE @deleted_ops TABLE(operation_id bigint, operation_type smallint)

            
            SET @delete_batch_size = 10  
            SET @rows_affected = @delete_batch_size
            
            SET @temp_date = GETDATE() - @retention_window_length
            
            WHILE (@rows_affected = @delete_batch_size)
            BEGIN
                DELETE TOP (@delete_batch_size)
                    FROM [internal].[operations] 
                    OUTPUT DELETED.operation_id, DELETED.operation_type INTO @deleted_ops
                    WHERE ( [end_time] <= @temp_date
                    
                    OR ([end_time] IS NULL AND [status] = 1 AND [created_time] <= @temp_date ))
                    
                SET @rows_affected = @@ROWCOUNT
            END
            
            DECLARE @execution_id bigint
            DECLARE @sqlString              nvarchar(1024)
            DECLARE @key_name               [internal].[adt_name]
            DECLARE @certificate_name       [internal].[adt_name]
            
            
            DECLARE execution_cursor CURSOR LOCAL FOR 
                SELECT operation_id FROM @deleted_ops 
                WHERE operation_type = 200
            
            OPEN execution_cursor
            FETCH NEXT FROM execution_cursor INTO @execution_id
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @key_name = 'MS_Enckey_Exec_'+CONVERT(varchar,@execution_id)
                SET @certificate_name = 'MS_Cert_Exec_'+CONVERT(varchar,@execution_id)
                SET @sqlString = 'IF EXISTS (SELECT name FROM sys.symmetric_keys WHERE name = ''' + @key_name +''') '
                    +'DROP SYMMETRIC KEY '+ @key_name
                    EXECUTE sp_executesql @sqlString
                SET @sqlString = 'IF EXISTS (select name from sys.certificates WHERE name = ''' + @certificate_name +''') '
                    +'DROP CERTIFICATE '+ @certificate_name
                    EXECUTE sp_executesql @sqlString
                FETCH NEXT FROM execution_cursor INTO @execution_id
            END
            CLOSE execution_cursor
            DEALLOCATE execution_cursor
            
            UPDATE [internal].[operations]
                SET [status] = 7,
                [end_time] = SYSDATETIMEOFFSET()
                WHERE [operation_id] = @operation_id                                  
        END
    END TRY
    BEGIN CATCH
        
        
        IF (CURSOR_STATUS('local', 'execution_cursor') = 1 
            OR CURSOR_STATUS('local', 'execution_cursor') = 0)
        BEGIN
            CLOSE execution_cursor
            DEALLOCATE execution_cursor            
        END
        
        UPDATE [internal].[operations]
            SET [status] = 4,
            [end_time] = SYSDATETIMEOFFSET()
            WHERE [operation_id] = @operation_id;       
        THROW
    END CATCH
    
    RETURN 0
