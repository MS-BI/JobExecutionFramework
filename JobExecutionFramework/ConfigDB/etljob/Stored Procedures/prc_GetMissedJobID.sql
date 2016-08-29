
CREATE PROCEDURE [etljob].[prc_GetMissedJobID] (
	@startDate DATETIME
	,@endDate DATETIME
	,@JobCat SYSNAME
	)
AS
SET NOCOUNT ON

-- Create a tally table. If you already have one of your own please use that instead.
CREATE TABLE #tallyNumbers (num SMALLINT PRIMARY KEY CLUSTERED)

DECLARE @index SMALLINT

SET @index = 1

WHILE @index <= 8640
BEGIN
	INSERT #tallyNumbers (num)
	VALUES (@index)

	SET @index = @index + 1
END

-- Create a staging table for jobschedules
CREATE TABLE #jobSchedules (
	rowID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED
	,serverName SYSNAME NOT NULL
	,jobName SYSNAME NOT NULL
	,jobDescription NVARCHAR(512) NOT NULL
	,scheduleName SYSNAME NOT NULL
	,scheduleID INT NOT NULL
	,categoryName SYSNAME NOT NULL
	,freq_type INT NOT NULL
	,freq_interval INT NOT NULL
	,freq_subday_type INT NOT NULL
	,freq_subday_interval INT NOT NULL
	,freq_relative_interval INT NOT NULL
	,freq_recurrence_factor INT NOT NULL
	,startDate DATETIME NOT NULL
	,startTime DATETIME NOT NULL
	,endDate DATETIME NOT NULL
	,endTime DATETIME NOT NULL
	,jobEnabled INT NOT NULL
	,scheduleEnabled INT NOT NULL
	,job_id [uniqueidentifier] NOT NULL
	)

-- Popoulate the staging table for JobSchedules
INSERT #JobSchedules (
	serverName
	,jobName
	,jobDescription
	,scheduleName
	,scheduleID
	,categoryName
	,freq_type
	,freq_interval
	,freq_subday_type
	,freq_subday_interval
	,freq_relative_interval
	,freq_recurrence_factor
	,startDate
	,startTime
	,endDate
	,endTime
	,jobEnabled
	,scheduleEnabled
	,job_id
	)
SELECT srv.srvname
	,sj.NAME
	,COALESCE(sj.description, '')
	,ss.NAME
	,ss.schedule_id
	,sc.NAME
	,ss.freq_type
	,ss.freq_interval
	,ss.freq_subday_type
	,ss.freq_subday_interval
	,ss.freq_relative_interval
	,ss.freq_recurrence_factor
	,COALESCE(STR(ss.active_start_date, 8), CONVERT(CHAR(8), GETDATE(), 112))
	,STUFF(STUFF(REPLACE(STR(ss.active_start_time, 6), ' ', '0'), 3, 0, ':'), 6, 0, ':')
	,STR(ss.active_end_date, 8)
	,STUFF(STUFF(REPLACE(STR(ss.active_end_time, 6), ' ', '0'), 3, 0, ':'), 6, 0, ':')
	,sj.enabled
	,ss.enabled
	,sj.job_id
FROM msdb..sysschedules AS ss
INNER JOIN msdb..sysjobschedules AS sjs
	ON sjs.schedule_id = ss.schedule_id
INNER JOIN msdb..sysjobs AS sj
	ON sj.job_id = sjs.job_id
INNER JOIN sys.sysservers AS srv
	ON srv.srvid = sj.originating_server_id
INNER JOIN msdb..syscategories AS sc
	ON sc.category_id = sj.category_id
WHERE ss.freq_type IN (
		1
		,4
		,8
		,16
		,32
		)
	AND sc.NAME = @JobCat
ORDER BY srv.srvname
	,sj.NAME
	,ss.NAME

-- Only deal with jobs that has active start date before @endDate
DELETE
FROM #JobSchedules
WHERE startDate > @endDate

-- Only deal with jobs that has active end date after @startDate
DELETE
FROM #JobSchedules
WHERE endDate < @startDate

-- Deal with first, second, third, fourth and last occurence
DECLARE @tempStart DATETIME
	,@tempEnd DATETIME

SELECT @tempStart = DATEADD(MONTH, DATEDIFF(MONTH, '19000101', @startDate), '19000101')
	,@TempEnd = DATEADD(MONTH, DATEDIFF(MONTH, '18991231', @endDate), '18991231')

CREATE TABLE #dayInformation (
	TheDate DATETIME PRIMARY KEY CLUSTERED
	,weekdayName VARCHAR(9) NOT NULL
	,statusCode INT NOT NULL
	,lastDay TINYINT DEFAULT 0
	)

WHILE @tempStart <= @tempEnd
BEGIN
	INSERT #dayInformation (
		TheDate
		,weekdayName
		,statusCode
		)
	SELECT @tempStart
		,DATENAME(WEEKDAY, @tempStart)
		,CASE 
			WHEN DATEPART(DAY, @tempStart) BETWEEN 1
					AND 7
				THEN 1
			WHEN DATEPART(DAY, @tempStart) BETWEEN 8
					AND 14
				THEN 2
			WHEN DATEPART(DAY, @tempStart) BETWEEN 15
					AND 21
				THEN 4
			WHEN DATEPART(DAY, @tempStart) BETWEEN 22
					AND 28
				THEN 8
			ELSE 0
			END

	SET @tempStart = DATEADD(DAY, 1, @tempStart)
END

UPDATE di
SET di.statusCode = di.statusCode + 16
FROM #dayInformation AS di
INNER JOIN (
	SELECT DATEDIFF(MONTH, '19000101', TheDate) AS theMonth
		,DATEPART(DAY, MAX(TheDate)) - 6 AS theDay
	FROM #dayInformation
	GROUP BY DATEDIFF(MONTH, '19000101', TheDate)
	) AS x
	ON x.theMonth = DATEDIFF(MONTH, '19000101', di.TheDate)
WHERE DATEPART(DAY, di.TheDate) >= x.theDay

UPDATE di
SET di.lastDay = 16
FROM #dayInformation AS di
INNER JOIN (
	SELECT DATEDIFF(MONTH, '19000101', TheDate) AS theMonth
		,MAX(TheDate) AS theDay
	FROM #dayInformation
	GROUP BY DATEDIFF(MONTH, '19000101', TheDate)
	) AS x
	ON x.theMonth = DATEDIFF(MONTH, '19000101', di.TheDate)
WHERE di.TheDate = x.theDay

UPDATE #dayInformation
SET lastDay = DATEPART(DAY, TheDate)
WHERE DATEPART(DAY, TheDate) BETWEEN 1
		AND 4

-- Stage all individual schedule times
CREATE TABLE #scheduleTimes (
	rowID INT NOT NULL
	,TheDate DATETIME NOT NULL
	,startTime DATETIME NOT NULL
	,endTime DATETIME NOT NULL
	,waitSeconds INT DEFAULT 0
	,effectiveTime DATETIME NULL
	)

CREATE CLUSTERED INDEX IX_rowID ON #scheduleTimes (rowID)

-- Insert one time only schedules
INSERT #scheduleTimes (
	rowID
	,TheDate
	,startTime
	,endTime
	)
SELECT rowID
	,startDate
	,startTime
	,endTime
FROM #jobSchedules
WHERE freq_type = 1
	AND startDate >= @StartDate
	AND startDate <= @EndDate

-- Insert daily schedules
INSERT #scheduleTimes (
	rowID
	,TheDate
	,startTime
	,endTime
	,waitSeconds
	)
SELECT js.rowID
	,di.TheDate
	,js.startTime
	,js.endTime
	,CASE js.freq_subday_type
		WHEN 1
			THEN 0
		WHEN 2
			THEN js.freq_subday_interval
		WHEN 4
			THEN 60 * js.freq_subday_interval
		WHEN 8
			THEN 3600 * js.freq_subday_interval
		END
FROM #jobSchedules AS js
INNER JOIN #dayInformation AS di
	ON di.TheDate >= @startDate
		AND di.TheDate <= @endDate
WHERE js.freq_type = 4
	AND DATEDIFF(DAY, js.startDate, di.TheDate) % js.freq_interval = 0

-- Insert weekly schedules
INSERT #scheduleTimes (
	rowID
	,TheDate
	,startTime
	,endTime
	,waitSeconds
	)
SELECT js.rowID
	,di.TheDate
	,js.startTime
	,js.endTime
	,CASE js.freq_subday_type
		WHEN 1
			THEN 0
		WHEN 2
			THEN js.freq_subday_interval
		WHEN 4
			THEN 60 * js.freq_subday_interval
		WHEN 8
			THEN 3600 * js.freq_subday_interval
		END
FROM #jobSchedules AS js
INNER JOIN #dayInformation AS di
	ON di.TheDate >= @startDate
		AND di.TheDate <= @endDate
WHERE js.freq_type = 8
	AND 1 = CASE 
		WHEN js.freq_interval & 1 = 1
			AND di.weekdayName = 'Sunday'
			THEN 1
		WHEN js.freq_interval & 2 = 2
			AND di.weekdayName = 'Monday'
			THEN 1
		WHEN js.freq_interval & 4 = 4
			AND di.weekdayName = 'Tuesday'
			THEN 1
		WHEN js.freq_interval & 8 = 8
			AND di.weekdayName = 'Wednesday'
			THEN 1
		WHEN js.freq_interval & 16 = 16
			AND di.weekdayName = 'Thursday'
			THEN 1
		WHEN js.freq_interval & 32 = 32
			AND di.weekdayName = 'Friday'
			THEN 1
		WHEN js.freq_interval & 64 = 64
			AND di.weekdayName = 'Saturday'
			THEN 1
		ELSE 0
		END
	AND (DATEDIFF(DAY, js.startDate, di.TheDate) / 7) % js.freq_recurrence_factor = 0

-- Insert monthly schedules
INSERT #scheduleTimes (
	rowID
	,TheDate
	,startTime
	,endTime
	,waitSeconds
	)
SELECT js.rowID
	,di.TheDate
	,js.startTime
	,js.endTime
	,CASE js.freq_subday_type
		WHEN 1
			THEN 0
		WHEN 2
			THEN js.freq_subday_interval
		WHEN 4
			THEN 60 * js.freq_subday_interval
		WHEN 8
			THEN 3600 * js.freq_subday_interval
		END
FROM #jobSchedules AS js
INNER JOIN #dayInformation AS di
	ON di.TheDate >= @startDate
		AND di.TheDate <= @endDate
WHERE js.freq_type = 16
	AND DATEPART(DAY, di.TheDate) = js.freq_interval
	AND DATEDIFF(MONTH, js.startDate, di.TheDate) % js.freq_recurrence_factor = 0

-- Insert monthly relative schedules
INSERT #scheduleTimes (
	rowID
	,TheDate
	,startTime
	,endTime
	,waitSeconds
	)
SELECT js.rowID
	,di.TheDate
	,js.startTime
	,js.endTime
	,CASE js.freq_subday_type
		WHEN 1
			THEN 0
		WHEN 2
			THEN js.freq_subday_interval
		WHEN 4
			THEN 60 * js.freq_subday_interval
		WHEN 8
			THEN 3600 * js.freq_subday_interval
		END
FROM #jobSchedules AS js
INNER JOIN #dayInformation AS di
	ON di.TheDate >= @startDate
		AND di.TheDate <= @endDate
WHERE js.freq_type = 32
	AND 1 = CASE 
		WHEN js.freq_interval = 1
			AND di.weekdayName = 'Sunday'
			THEN 1
		WHEN js.freq_interval = 2
			AND di.weekdayName = 'Monday'
			THEN 1
		WHEN js.freq_interval = 3
			AND di.weekdayName = 'Tuesday'
			THEN 1
		WHEN js.freq_interval = 4
			AND di.weekdayName = 'Wednesday'
			THEN 1
		WHEN js.freq_interval = 5
			AND di.weekdayName = 'Thursday'
			THEN 1
		WHEN js.freq_interval = 6
			AND di.weekdayName = 'Friday'
			THEN 1
		WHEN js.freq_interval = 7
			AND di.weekdayName = 'Saturday'
			THEN 1
		WHEN js.freq_interval = 8
			AND js.freq_relative_interval = di.lastDay
			THEN 1
		WHEN js.freq_interval = 9
			AND di.weekdayName NOT IN (
				'Sunday'
				,'Saturday'
				)
			THEN 1
		WHEN js.freq_interval = 10
			AND di.weekdayName IN (
				'Sunday'
				,'Saturday'
				)
			THEN 1
		ELSE 0
		END
	AND di.statusCode & js.freq_relative_interval = js.freq_relative_interval
	AND DATEDIFF(MONTH, js.startDate, di.TheDate) % js.freq_recurrence_factor = 0

-- Get the daily recurring schedule times
INSERT #scheduleTimes (
	rowID
	,TheDate
	,startTime
	,endTime
	,waitSeconds
	)
SELECT st.rowID
	,st.TheDate
	,DATEADD(SECOND, tn.num * st.waitSeconds, st.startTime)
	,st.endTime
	,st.waitSeconds
FROM #scheduleTimes AS st
CROSS JOIN #tallyNumbers AS tn
WHERE tn.num * st.waitSeconds <= DATEDIFF(SECOND, st.startTime, st.endTime)
	AND st.waitSeconds > 0

SELECT js.job_id
	,Min(dateadd(hour, datepart(hour, st.startTime), dateadd(minute, datepart(minute, st.startTime), dateadd(second, datepart(second, st.startTime), st.TheDate)))) AS FirstOccurrence
FROM #scheduleTimes AS st
INNER JOIN #jobSchedules AS js
	ON js.rowID = st.rowID
WHERE dateadd(hour, datepart(hour, st.startTime), dateadd(minute, datepart(minute, st.startTime), dateadd(second, datepart(second, st.startTime), st.TheDate))) >= @startDate
	AND dateadd(hour, datepart(hour, st.startTime), dateadd(minute, datepart(minute, st.startTime), dateadd(second, datepart(second, st.startTime), st.TheDate))) <= @endDate
GROUP BY js.job_id
ORDER BY Min(dateadd(hour, datepart(hour, st.startTime), dateadd(minute, datepart(minute, st.startTime), dateadd(second, datepart(second, st.startTime), st.TheDate)))) ASC

-- Clean up
DROP TABLE #jobSchedules
	,#dayInformation
	,#scheduleTimes
	,#tallyNumbers
