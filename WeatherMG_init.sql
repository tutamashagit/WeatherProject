USE [master]
GO

/****** CREATE DATABASE [WeatherMG] ******/
IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE NAME = 'WeatherMG')
CREATE DATABASE [WeatherMG]
GO
/****** CREATE DATABASE [WeatherMG] ******/
USE [WeatherMG]
GO

IF OBJECT_ID('WeatherMG.dbo.StagingWeatherCurrent') IS NULL
CREATE TABLE [dbo].[StagingWeatherCurrent](
	[StationId] [int] NOT NULL,
	[MeasurentDate] [datetime2](0) NOT NULL,
	[MaxTemp] [decimal](5, 2) NOT NULL,
	[Rain] [decimal](6, 3) NULL
) ON [PRIMARY]
GO

/****** CREATE TABLE [dbo].[StagingWeatherForecast] ******/
IF OBJECT_ID('WeatherMG.dbo.StagingWeatherForecast') IS NULL
CREATE TABLE [dbo].[StagingWeatherForecast](
	[StationId] [int] NOT NULL,
	[MeasurentDate] [datetime2](0) NOT NULL,
	[MaxTemp] [decimal](5, 2) NOT NULL,
	[Rain] [decimal](6, 3) NULL
) ON [PRIMARY]
GO

/****** CREATE TABLE [dbo].[StagingWeatherHistory] ******/
IF OBJECT_ID('WeatherMG.dbo.StagingWeatherHistory') IS NULL
CREATE TABLE [dbo].[StagingWeatherHistory](
	[StationId] [int] NOT NULL,
	[Year] [smallint] NOT NULL,
	[Month] [smallint] NOT NULL,
	[MaxTemp] [decimal](5, 2) NULL,
	[Rain] [decimal](5, 2) NULL
) ON [PRIMARY]
GO

/****** CREATE TABLE [dbo].[WeatherStation] ******/
IF OBJECT_ID('WeatherMG.dbo.WeatherStation') IS NULL
CREATE TABLE [dbo].[WeatherStation](
    [WeatherStationKey] [int] IDENTITY (1,1) NOT NULL,
	[StationId] [int] NOT NULL,
	[StationName] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[WeatherStationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** INSERT INTO TABLE [dbo].[WeatherStation] ******/
IF OBJECT_ID('WeatherMG.dbo.WeatherStation') IS NOT NULL
BEGIN
IF NOT EXISTS (SELECT 1 FROM [dbo].[WeatherStation] WHERE [StationId] = 2637487)
INSERT [dbo].[WeatherStation] ([StationId], [StationName]) VALUES (2637487, N'Southampton')
IF NOT EXISTS (SELECT 1 FROM [dbo].[WeatherStation] WHERE [StationId] = 2640729)
INSERT [dbo].[WeatherStation] ([StationId], [StationName]) VALUES (2640729, N'Oxford')
IF NOT EXISTS (SELECT 1 FROM [dbo].[WeatherStation] WHERE [StationId] = 2654993)
INSERT [dbo].[WeatherStation] ([StationId], [StationName]) VALUES (2654993, N'Bradford')
IF NOT EXISTS (SELECT 1 FROM [dbo].[WeatherStation] WHERE [StationId] = 7284876)
INSERT [dbo].[WeatherStation] ([StationId], [StationName]) VALUES (7284876, N'Heathrow')
IF NOT EXISTS (SELECT 1 FROM [dbo].[WeatherStation] WHERE [StationId] = 7299942)
INSERT [dbo].[WeatherStation] ([StationId], [StationName]) VALUES (7299942, N'Camborne')
END

/****** CREATE TABLE [dbo].[DimDate] ******/
IF OBJECT_ID('WeatherMG.dbo.DimDate') IS NULL
CREATE TABLE dbo.DimDate (
   DateKey INT NOT NULL PRIMARY KEY,
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
   IsWeekend BIT NOT NULL,
   [IsHoliday] BIT NOT NULL
   )

/****** POPULATE TABLE [dbo].[DimDate] ******/
   SET NOCOUNT ON

--TRUNCATE TABLE DimDate
IF NOT EXISTS (SELECT 1 FROM WeatherMG.dbo.DimDate)
BEGIN
DECLARE @StartDate DATE = '1900-01-01'
DECLARE @EndDate DATE = '2030-12-31'

WHILE @StartDate < @EndDate
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

/****** CREATE TABLE [dbo].[DimTime] ******/
IF OBJECT_ID('WeatherMG.dbo.DimTime') IS NULL
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
IF NOT EXISTS (SELECT 1 FROM WeatherMG.dbo.DimTime)
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