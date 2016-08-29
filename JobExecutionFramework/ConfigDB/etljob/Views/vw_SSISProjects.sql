

CREATE VIEW [etljob].[vw_SSISProjects]
AS
SELECT prj.[project_id]
	,prj.[folder_id]
	,prj.[name] as Name
	,prj.[description]
	,prj.[project_format_version]
	,prj.[deployed_by_sid]
	,prj.[deployed_by_name]
	,prj.[last_deployed_time]
	,prj.[created_time]
	,prj.[object_version_lsn]
	,prj.[validation_status]
	,prj.[last_validation_time]
	,fld.[name] as Foldername
FROM ssis.[projects] prj INNER Join ssis.folders fld
on  prj.[folder_id] = fld.[folder_id]