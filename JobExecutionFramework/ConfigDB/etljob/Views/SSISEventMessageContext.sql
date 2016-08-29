


CREATE VIEW [etljob].[SSISEventMessageContext]
AS
SELECT [context_id]
      ,[event_message_id]
      ,[context_depth]
      ,[package_path]
      ,[context_type]
      ,[context_source_name]
      ,[context_source_id]
      ,[property_name]
      ,[property_value]
  FROM [$(SSISDB)].CATALOG.event_message_context msg
