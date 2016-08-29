

CREATE VIEW [etljob].[vw_SSISErrorMessages]
AS
SELECT [event_message_id]
      ,[operation_id]
      ,[message_time]
      ,[message_type]
      ,[message_source_type]
      ,[message]
      ,[extended_info_id]
      ,[package_name]
      ,[event_name]
      ,[message_source_name]
      ,[message_source_id]
      ,[subcomponent_name]
      ,[package_path]
      ,[execution_path]
      ,[threadID]
      ,[message_code]
  FROM [$(SSISDB)].[catalog].[event_messages] msg
  WHERE msg.event_name = 'OnError'