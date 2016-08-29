
CREATE VIEW [etljob].[vw_SSISExecutions]
AS
SELECT execution_id
	,folder_name
	,project_name
	,package_name
	,reference_id
	,reference_type
	,environment_folder_name
	,environment_name
	,project_lsn
	,executed_as_sid
	,executed_as_name
	,use32bitruntime
	,operation_type
	,created_time
	,object_type
	,object_id
	,STATUS
	,start_time
	,end_time
	,caller_sid
	,caller_name
	,process_id
	,stopped_by_sid
	,stopped_by_name
	,dump_id
	,server_name
	,machine_name
	,total_physical_memory_kb
	,available_physical_memory_kb
	,total_page_file_kb
	,available_page_file_kb
	,cpu_count
FROM [$(SSISDB)].CATALOG.executions


