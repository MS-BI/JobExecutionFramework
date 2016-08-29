
CREATE VIEW [internal].[current_user_object_permissions]
AS
SELECT     [object_type],
           [object_id],
           [permission_type], 
           [sid],
           [is_role],
           [is_deny]
FROM       [internal].[object_permissions]
WHERE      IS_MEMBER(USER_NAME([internal].[get_principal_id_by_sid]([sid])))=1
	   OR [sid] = USER_SID (DATABASE_PRINCIPAL_ID())
	
