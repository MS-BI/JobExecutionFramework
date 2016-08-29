


CREATE VIEW [etljob].[vw_PackagesSSISDB]
AS
SELECT pkg.package_id
	,pkg.NAME
	,pkg.package_guid
	,pkg.description
	,pkg.package_format_version
	,pkg.version_major
	,pkg.version_minor
	,pkg.version_build
	,pkg.version_comments
	,pkg.version_guid
	,pkg.project_id
	,pkg.entry_point
	,pkg.validation_status
	,pkg.last_validation_time
	,prj.NAME AS ProjectName
	,fld.NAME AS FolderName
FROM [$(SSISDB)].CATALOG.packages pkg
INNER JOIN [$(SSISDB)].CATALOG.projects prj ON pkg.project_id = prj.project_id
INNER JOIN [$(SSISDB)].CATALOG.folders fld ON prj.folder_id = fld.folder_id
WHERE pkg.package_id IN (
		SELECT max(p.package_id)
		FROM [$(SSISDB)].[internal].[packages] p
		GROUP BY p.NAME
			,p.project_id
		)