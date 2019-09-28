USE [master]
GO

/****** CREATE DATABASE [WeatherMG] ******/
IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE NAME = 'WeatherMG')
CREATE DATABASE [WeatherMG]
GO
/****** CREATE DATABASE [WeatherMG] ******/
USE [WeatherMG]
GO

IF OBJECT_ID('dbo.StagingWeatherCurrent') IS NULL
CREATE TABLE [dbo].[StagingWeatherCurrent](
	[StationId] [int] NOT NULL,
	[MeasurementDate] [datetime2](0) NOT NULL,
	[MaxTemp] [decimal](5, 2) NOT NULL,
	[Rain] [decimal](6, 3) NULL,
	[LoadedStamp] [datetime2](0) NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[StagingWeatherCurrent] ADD  DEFAULT (getdate()) FOR [LoadedStamp]
GO


/****** CREATE TABLE [dbo].[StagingWeatherForecast] ******/
IF OBJECT_ID('dbo.StagingWeatherForecast') IS NULL
CREATE TABLE [dbo].[StagingWeatherForecast](
	[StationId] [int] NOT NULL,
	[MeasurementDate] [datetime2](0) NOT NULL,
	[MaxTemp] [decimal](5, 2) NOT NULL,
	[Rain] [decimal](6, 3) NULL,
	[LoadedStamp] [datetime2](0) NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[StagingWeatherForecast] ADD  DEFAULT (getdate()) FOR [LoadedStamp]
GO

/****** CREATE TABLE [dbo].[StagingWeatherHistory] ******/
IF OBJECT_ID('dbo.StagingWeatherHistory') IS NULL
CREATE TABLE [dbo].[StagingWeatherHistory](
	[StationId] [int] NOT NULL,
	[Year] [smallint] NOT NULL,
	[Month] [smallint] NOT NULL,
	[MaxTemp] [decimal](5, 2) NULL,
	[Rain] [decimal](5, 2) NULL
) ON [PRIMARY]
GO

/****** CREATE TABLE [dbo].[DimWeatherStation] ******/
IF OBJECT_ID('dbo.DimWeatherStation') IS NULL
CREATE TABLE [dbo].[DimWeatherStation](
    [WeatherStationKey] [int] IDENTITY (1,1) NOT NULL,
	[StationId] [int] NOT NULL,
	[StationName] [varchar](50) NULL,
 CONSTRAINT [PK_DimWeatherStation] PRIMARY KEY CLUSTERED 
(
	WeatherStationKey ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** INSERT INTO TABLE [dbo].[DimWeatherStation] ******/
IF OBJECT_ID('dbo.DimWeatherStation') IS NOT NULL
BEGIN
IF NOT EXISTS (SELECT 1 FROM [dbo].[DimWeatherStation] WHERE [StationId] = 2637487)
INSERT [dbo].[DimWeatherStation] ([StationId], [StationName]) VALUES (2637487, N'Southampton')
IF NOT EXISTS (SELECT 1 FROM [dbo].[DimWeatherStation] WHERE [StationId] = 2640729)
INSERT [dbo].[DimWeatherStation] ([StationId], [StationName]) VALUES (2640729, N'Oxford')
IF NOT EXISTS (SELECT 1 FROM [dbo].[DimWeatherStation] WHERE [StationId] = 2654993)
INSERT [dbo].[DimWeatherStation] ([StationId], [StationName]) VALUES (2654993, N'Bradford')
IF NOT EXISTS (SELECT 1 FROM [dbo].[DimWeatherStation] WHERE [StationId] = 7284876)
INSERT [dbo].[DimWeatherStation] ([StationId], [StationName]) VALUES (7284876, N'Heathrow')
IF NOT EXISTS (SELECT 1 FROM [dbo].[DimWeatherStation] WHERE [StationId] = 7299942)
INSERT [dbo].[DimWeatherStation] ([StationId], [StationName]) VALUES (7299942, N'Camborne')
END

/****** CREATE TABLE [dbo].[DimDate] ******/
IF OBJECT_ID('dbo.DimDate') IS NULL
BEGIN
CREATE TABLE dbo.DimDate (
   DateKey INT NOT NULL,
   [Date] DATE NOT NULL,
   [Day] TINYINT NOT NULL,
   [DaySuffix] CHAR(2) NOT NULL,
   [Weekday] TINYINT NOT NULL,
   [WeekDayName] VARCHAR(10) NOT NULL,
   [WeekDayName_Short] CHAR(3) NOT NULL,
   [WeekDayName_FirstLetter] CHAR(1) NOT NULL,
   [DOWInMonth] TINYINT NOT NULL,
   [DayOfYear] SMALLINT NOT NULL,
   [WeekOfMonth] TINYINT NOT NULL,
   [WeekOfYear] TINYINT NOT NULL,
   [Month] TINYINT NOT NULL,
   [MonthName] VARCHAR(10) NOT NULL,
   [MonthName_Short] CHAR(3) NOT NULL,
   [MonthName_FirstLetter] CHAR(1) NOT NULL,
   [Quarter] TINYINT NOT NULL,
   [QuarterName] VARCHAR(6) NOT NULL,
   [Year] INT NOT NULL,
   [MMYYYY] CHAR(6) NOT NULL,
   [MonthYear] CHAR(7) NOT NULL,
   IsWeekend BIT NOT NULL
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED 
(
	DateKey ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY])

/****** POPULATE TABLE [dbo].[DimDate] ******/
   SET NOCOUNT ON

--TRUNCATE TABLE DimDate
IF NOT EXISTS (SELECT 1 FROM dbo.DimDate)
BEGIN
DECLARE @StartDate DATE = '1853-01-01'
DECLARE @EndDate DATE = '2029-12-31'

WHILE @StartDate <= @EndDate
BEGIN
   INSERT INTO [dbo].[DimDate] (
      [DateKey],
      [Date],
      [Day],
      [DaySuffix],
      [Weekday],
      [WeekDayName],
      [WeekDayName_Short],
      [WeekDayName_FirstLetter],
      [DOWInMonth],
      [DayOfYear],
      [WeekOfMonth],
      [WeekOfYear],
      [Month],
      [MonthName],
      [MonthName_Short],
      [MonthName_FirstLetter],
      [Quarter],
      [QuarterName],
      [Year],
      [MMYYYY],
      [MonthYear],
      [IsWeekend]
	
      )

   SELECT DateKey = YEAR(@StartDate) * 10000 + MONTH(@StartDate) * 100 + DAY(@StartDate),
      DATE = @StartDate,
      Day = DAY(@StartDate),
      [DaySuffix] = CASE 
         WHEN DAY(@StartDate) = 1
            OR DAY(@StartDate) = 21
            OR DAY(@StartDate) = 31
            THEN 'st'
         WHEN DAY(@StartDate) = 2
            OR DAY(@StartDate) = 22
            THEN 'nd'
         WHEN DAY(@StartDate) = 3
            OR DAY(@StartDate) = 23
            THEN 'rd'
         ELSE 'th'
         END,
      WEEKDAY = DATEPART(dw, @StartDate),
      WeekDayName = DATENAME(dw, @StartDate),
      WeekDayName_Short = UPPER(LEFT(DATENAME(dw, @StartDate), 3)),
      WeekDayName_FirstLetter = LEFT(DATENAME(dw, @StartDate), 1),
      [DOWInMonth] = DAY(@StartDate),
      [DayOfYear] = DATENAME(dy, @StartDate),
      [WeekOfMonth] = DATEPART(WEEK, @StartDate) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM, 0, @StartDate), 0)) + 1,
      [WeekOfYear] = DATEPART(wk, @StartDate),
      [Month] = MONTH(@StartDate),
      [MonthName] = DATENAME(mm, @StartDate),
      [MonthName_Short] = UPPER(LEFT(DATENAME(mm, @StartDate), 3)),
      [MonthName_FirstLetter] = LEFT(DATENAME(mm, @StartDate), 1),
      [Quarter] = DATEPART(q, @StartDate),
      [QuarterName] = CASE 
         WHEN DATENAME(qq, @StartDate) = 1
            THEN 'First'
         WHEN DATENAME(qq, @StartDate) = 2
            THEN 'second'
         WHEN DATENAME(qq, @StartDate) = 3
            THEN 'third'
         WHEN DATENAME(qq, @StartDate) = 4
            THEN 'fourth'
         END,
      [Year] = YEAR(@StartDate),
      [MMYYYY] = RIGHT('0' + CAST(MONTH(@StartDate) AS VARCHAR(2)), 2) + CAST(YEAR(@StartDate) AS VARCHAR(4)),
      [MonthYear] = CAST(YEAR(@StartDate) AS VARCHAR(4)) + UPPER(LEFT(DATENAME(mm, @StartDate), 3)),
      [IsWeekend] = CASE 
         WHEN DATENAME(dw, @StartDate) = 'Sunday'
            OR DATENAME(dw, @StartDate) = 'Saturday'
            THEN 1
         ELSE 0
         END
   
   SET @StartDate = DATEADD(DD, 1, @StartDate)
END
END

ALTER TABLE DIMDATE ADD  FirstDayOfMonth   DATE NULL
ALTER TABLE DIMDATE ADD  LastDayOfMonth   DATE NULL

;WITH CTE AS (
    SELECT  [year], [month], MIN([date]) OVER (PARTITION BY [year], [month] ) as FirstDayOfMonth,
             MAX([date]) OVER (PARTITION BY [year], [month] ) as LastDayOfMonth
    FROM    DimDate

)
UPDATE DimDate 
SET FirstDayOfMonth = CTE.FirstDayOfMonth,
    LastDayOfMonth      = CTE.LastDayOfMonth
	FROM DIMDATE INNER JOIN CTE
	ON CTE.[year] = DimDate.[year] AND CTE.[month] = DimDate.[month]

ALTER TABLE DIMDATE ALTER COLUMN FirstDayOfMonth  DATE NOT NULL
ALTER TABLE DIMDATE ALTER COLUMN LastDayOfMonth   DATE NOT NULL
END


/****** CREATE TABLE [dbo].[DimTime] ******/
IF OBJECT_ID('dbo.DimTime') IS NULL
CREATE TABLE [dbo].[DimTime](
[TimeKey] [int] NOT NULL,
[Hour24] [int] NULL,
[Hour24ShortString] [VARCHAR](2) NULL,
[Hour24MinString] [VARCHAR](5) NULL,
[Hour24FullString] [VARCHAR](8) NULL,
[Hour12] [int] NULL,
[Hour12ShortString] [VARCHAR](2) NULL,
[Hour12MinString] [VARCHAR](5) NULL,
[Hour12FullString] [VARCHAR](8) NULL,
[AmPmCode] [int] NULL,
[AmPmString] [VARCHAR](2) NOT NULL,
[Minute] [int] NULL,
[MinuteCode] [int] NULL,
[MinuteShortString] [VARCHAR](2) NULL,
[MinuteFullString24] [VARCHAR](8) NULL,
[MinuteFullString12] [VARCHAR](8) NULL,
[HalfHour] [int] NULL,
[HalfHourCode] [int] NULL,
[HalfHourShortString] [VARCHAR](2) NULL,
[HalfHourFullString24] [VARCHAR](8) NULL,
[HalfHourFullString12] [VARCHAR](8) NULL,
[Second] [int] NULL,
[SecondShortString] [VARCHAR](2) NULL,
[FullTimeString24] [VARCHAR](8) NULL,
[FullTimeString12] [VARCHAR](8) NULL,
[FullTime] [time](7) NULL,
[Interval3h] [int] NULL,
[Interval3hString] [VARCHAR](11),
CONSTRAINT [PK_DimTime] PRIMARY KEY CLUSTERED
(
[TimeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

/****** POPULATE TABLE [dbo].[DimTime] ******/
IF NOT EXISTS (SELECT 1 FROM dbo.DimTime)
BEGIN
DECLARE @hour int
DECLARE @minute int
DECLARE @second int

SET @hour=0
WHILE @hour<24

BEGIN
SET @minute=0
WHILE @minute<60

BEGIN
SET @second=0
WHILE @second<60

BEGIN
INSERT INTO [dbo].[DimTime]
([TimeKey]
,[Hour24]
,[Hour24ShortString]
,[Hour24MinString]
,[Hour24FullString]
,[Hour12]
,[Hour12ShortString]
,[Hour12MinString]
,[Hour12FullString]
,[AmPmCode]
,[AmPmString]
,[Minute]
,[MinuteCode]
,[MinuteShortString]
,[MinuteFullString24]
,[MinuteFullString12]
,[HalfHour]
,[HalfHourCode]
,[HalfHourShortString]
,[HalfHourFullString24]
,[HalfHourFullString12]
,[Second]
,[SecondShortString]
,[FullTimeString24]
,[FullTimeString12]
,[FullTime]
,[Interval3h]
,[Interval3hString]
)

SELECT
(@hour*10000) + (@minute*100) + @second as TimeKey,
@hour AS [Hour24],
RIGHT('0'+CONVERT(VARCHAR(2),@hour),2) [Hour24ShortString],
RIGHT('0'+CONVERT(VARCHAR(2),@hour),2)+':00' [Hour24MinString],
RIGHT('0'+CONVERT(VARCHAR(2),@hour),2)+':00:00' [Hour24FullString],
@hour%12 AS [Hour12],
RIGHT('0'+CONVERT(VARCHAR(2),@hour%12),2) [Hour12ShortString],
RIGHT('0'+CONVERT(VARCHAR(2),@hour%12),2)+':00' [Hour12MinString],
RIGHT('0'+CONVERT(VARCHAR(2),@hour%12),2)+':00:00' [Hour12FullString],
@hour/12 AS [AmPmCode],
CASE WHEN @hour<12 THEN 'AM' ELSE 'PM' END AS [AmPmString],
@minute AS [Minute],
(@hour*100) + (@minute) [MinuteCode],
RIGHT('0'+CONVERT(VARCHAR(2),@minute),2) [MinuteShortString],
RIGHT('0'+CONVERT(VARCHAR(2),@hour),2)+':'+
RIGHT('0'+CONVERT(VARCHAR(2),@minute),2)+':00' [MinuteFullString24],
RIGHT('0'+CONVERT(VARCHAR(2),@hour%12),2)+':'+
RIGHT('0'+CONVERT(VARCHAR(2),@minute),2)+':00' [MinuteFullString12],
@minute/30 AS [HalfHour],
(@hour*100) + ((@minute/30)*30) [HalfHourCode],
RIGHT('0'+CONVERT(VARCHAR(2),((@minute/30)*30)),2) [HalfHourShortString],
RIGHT('0'+CONVERT(VARCHAR(2),@hour),2)+':'+
RIGHT('0'+CONVERT(VARCHAR(2),((@minute/30)*30)),2)+':00' [HalfHourFullString24],
RIGHT('0'+CONVERT(VARCHAR(2),@hour%12),2)+':'+
RIGHT('0'+CONVERT(VARCHAR(2),((@minute/30)*30)),2)+':00' [HalfHourFullString12],
@second AS [Second],
RIGHT('0'+CONVERT(VARCHAR(2),@second),2) [SecondShortString],
RIGHT('0'+CONVERT(VARCHAR(2),@hour),2)+':'+
RIGHT('0'+CONVERT(VARCHAR(2),@minute),2)+':'+
RIGHT('0'+CONVERT(VARCHAR(2),@second),2) [FullTimeString24],
RIGHT('0'+CONVERT(VARCHAR(2),@hour%12),2)+':'+
RIGHT('0'+CONVERT(VARCHAR(2),@minute),2)+':'+
RIGHT('0'+CONVERT(VARCHAR(2),@second),2) [FullTimeString12],
CONVERT(TIME,RIGHT('0'+CONVERT(VARCHAR(2),@hour),2)+':'+
RIGHT('0'+CONVERT(VARCHAR(2),@minute),2)+':'+
RIGHT('0'+CONVERT(VARCHAR(2),@second),2)) AS [FullTime],
CASE 
 WHEN @hour BETWEEN 0 and 2 THEN 1  
 WHEN @hour BETWEEN 3 and 5 THEN 2  
 WHEN @hour BETWEEN 6 and 8 THEN 3  
 WHEN @hour BETWEEN 9 and 11 THEN 4  
 WHEN @hour BETWEEN 12 and 14 THEN 5 
 WHEN @hour BETWEEN 15 and 17 THEN 6  
 WHEN @hour BETWEEN 18 and 20 THEN 7  
 WHEN @hour BETWEEN 21 and 23 THEN 8
  END,
CASE 
 WHEN @hour BETWEEN 0 and 2 THEN '0.00-2.59'  
 WHEN @hour BETWEEN 3 and 5 THEN '3.00-5.59'   
 WHEN @hour BETWEEN 6 and 8 THEN '6.00-8.59'   
 WHEN @hour BETWEEN 9 and 11 THEN '9.00-11.59'  
 WHEN @hour BETWEEN 12 and 14 THEN '12.00-14.59' 
 WHEN @hour BETWEEN 15 and 17 THEN '13.00-17.59'   
 WHEN @hour BETWEEN 18 and 20 THEN '18.00-20.59'  
 WHEN @hour BETWEEN 21 and 23 THEN '21.00-23.59' 
  END
SET @second=@second+1
END
SET @minute=@minute+1
END
SET @hour=@hour+1
END
END

USE [WeatherMG]
GO

---CREATE FactWeatherHistory

IF OBJECT_ID('WeatherMG.dbo.FactWeatherHistory') IS NULL
CREATE TABLE [dbo].[FactWeatherHistory]
(
[WeatherHistoryKey] INT IDENTITY (1,1) NOT NULL,
[WeatherStationKey] INT NOT NULL,
[DateKey] INT NOT NULL,
[MeanMaxTemperature_degC] DECIMAL (4,2),
[TotalRain_mm] DECIMAL (5,2),
CONSTRAINT [PK_FactWeatherHistory] PRIMARY KEY CLUSTERED
(
[WeatherHistoryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
--Adding Foreign Keys
IF NOT EXISTS (SELECT *   FROM sys.foreign_keys 
WHERE object_id = OBJECT_ID(N'dbo.FK_FactWeatherHistory_DimWeatherStation') AND parent_object_id = OBJECT_ID(N'dbo.FactWeatherHistory'))
ALTER TABLE [dbo].[FactWeatherHistory]
ADD CONSTRAINT FK_FactWeatherHistory_DimWeatherStation FOREIGN KEY ([WeatherStationKey])
REFERENCES [dbo].[DimWeatherStation] ([WeatherStationKey])

IF NOT EXISTS (SELECT *   FROM sys.foreign_keys 
WHERE object_id = OBJECT_ID(N'dbo.FK_FactWeatherHistory_DimDate') AND parent_object_id = OBJECT_ID(N'dbo.FactWeatherHistory'))
ALTER TABLE [dbo].[FactWeatherHistory]
ADD CONSTRAINT FK_FactWeatherHistory_DimDate FOREIGN KEY ([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey])

---CREATE FactWeatherCurrent
IF OBJECT_ID('dbo.FactWeatherCurrent') IS NULL
CREATE TABLE [dbo].[FactWeatherCurrent]
(
[WeatherCurrentKey] INT IDENTITY (1,1) NOT NULL,
[WeatherStationKey] INT NOT NULL,
[DateKey] INT NOT NULL,
[TimeKey] INT NOT NULL,
[Date] INT NOT NULL,
[TimeInterval] VARCHAR(11),
[Temperature_degC] DECIMAL (4,2),
[Rain_mm] DECIMAL (5,2),
CONSTRAINT [PK_FactWeatherCurrent] PRIMARY KEY CLUSTERED
(
[WeatherCurrentKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
--Adding Foreign Keys
IF NOT EXISTS (SELECT *   FROM sys.foreign_keys 
WHERE object_id = OBJECT_ID(N'dbo.FK_FactWeatherCurrent_DimWeatherStation') AND parent_object_id = OBJECT_ID(N'dbo.FactWeatherCurrent'))
ALTER TABLE [dbo].[FactWeatherCurrent]
ADD CONSTRAINT FK_FactWeatherCurrent_DimWeatherStation FOREIGN KEY ([WeatherStationKey])
REFERENCES [dbo].[DimWeatherStation] ([WeatherStationKey])

IF NOT EXISTS (SELECT *   FROM sys.foreign_keys 
WHERE object_id = OBJECT_ID(N'dbo.FK_FactWeatherCurrent_DimDate') AND parent_object_id = OBJECT_ID(N'dbo.FactWeatherCurrent'))
ALTER TABLE [dbo].[FactWeatherCurrent]
ADD CONSTRAINT FK_FactWeatherCurrent_DimDate FOREIGN KEY ([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey])

IF NOT EXISTS (SELECT *   FROM sys.foreign_keys 
WHERE object_id = OBJECT_ID(N'dbo.FK_FactWeatherCurrent_DimTime') AND parent_object_id = OBJECT_ID(N'dbo.FactWeatherCurrent'))
ALTER TABLE [dbo].[FactWeatherCurrent]
ADD CONSTRAINT FK_FactWeatherCurrent_DimTime FOREIGN KEY ([TimeKey])
REFERENCES [dbo].[DimTime] ([TimeKey])

---CREATE FactWeatherForecast
IF OBJECT_ID('dbo.FactWeatherForecast') IS NULL
CREATE TABLE [dbo].[FactWeatherForecast]
(
[WeatherForecastKey] INT IDENTITY (1,1) NOT NULL,
[WeatherStationKey] INT NOT NULL,
[DateKey] INT NOT NULL,
[TimeKey] INT NOT NULL,
[Date] INT NOT NULL,
[TimeInterval] VARCHAR(11),
[Temperature_degC] DECIMAL (4,2),
[Rain_mm] DECIMAL (5,2),
CONSTRAINT [PK_FactWeatherForecast] PRIMARY KEY CLUSTERED
(
[WeatherForecastKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
--Adding Foreign Keys
IF NOT EXISTS (SELECT *   FROM sys.foreign_keys 
WHERE object_id = OBJECT_ID(N'dbo.FK_FactWeatherForecast_DimWeatherStation') AND parent_object_id = OBJECT_ID(N'dbo.FactWeatherForecast'))
ALTER TABLE [dbo].[FactWeatherForecast]
ADD CONSTRAINT FK_FactWeatherForecast_DimWeatherStation FOREIGN KEY ([WeatherStationKey])
REFERENCES [dbo].[DimWeatherStation] ([WeatherStationKey])

IF NOT EXISTS (SELECT *   FROM sys.foreign_keys 
WHERE object_id = OBJECT_ID(N'dbo.FK_FactWeatherForecast_DimDate') AND parent_object_id = OBJECT_ID(N'dbo.FactWeatherForecast'))
ALTER TABLE [dbo].[FactWeatherForecast]
ADD CONSTRAINT FK_FactWeatherForecast_DimDate FOREIGN KEY ([DateKey])
REFERENCES [dbo].[DimDate] ([DateKey])

IF NOT EXISTS (SELECT *   FROM sys.foreign_keys 
WHERE object_id = OBJECT_ID(N'dbo.FK_FactWeatherForecast_DimTime') AND parent_object_id = OBJECT_ID(N'dbo.FactWeatherForecast'))
ALTER TABLE [dbo].[FactWeatherForecast]
ADD CONSTRAINT FK_FactWeatherForecast_DimTime FOREIGN KEY ([TimeKey])
REFERENCES [dbo].[DimTime] ([TimeKey])

---CREATE PackageExecutionStamp
IF OBJECT_ID('dbo.PackageExecutionStamp') IS NULL
CREATE TABLE [dbo].[PackageExecutionStamp](
	[PackageExecutionId] [int] IDENTITY(1,1) NOT NULL,
	[PackageID] [uniqueidentifier] NOT NULL,
	[PackageName] [varchar](50) NOT NULL,
	[ExecutionStamp] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_PackageExecutionStamp] PRIMARY KEY CLUSTERED 
(
	[PackageExecutionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
