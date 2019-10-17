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
	[MaxTemp] [decimal](5, 2) NULL,
	[Rain] [decimal](6, 3) NULL,
	[LoadedStamp] [datetime2](0) NOT NULL DEFAULT (GETUTCDATE())
) ON [PRIMARY]
GO


/****** CREATE TABLE [dbo].[StagingWeatherForecast] ******/
IF OBJECT_ID('dbo.StagingWeatherForecast') IS NULL
CREATE TABLE [dbo].[StagingWeatherForecast](
	[StationId] [int] NOT NULL,
	[MeasurementDate] [datetime2](0) NOT NULL,
	[MaxTemp] [decimal](5, 2) NULL,
	[Rain] [decimal](6, 3) NULL,
	[LoadedStamp] [datetime2](0) NOT NULL DEFAULT (GETUTCDATE()) 
) ON [PRIMARY]
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

---CREATE FactWeatherMonthly
IF OBJECT_ID('dbo.FactWeatherMonthly') IS NULL
CREATE TABLE [dbo].[FactWeatherMonthly]
(
[WeatherMonthlyKey] INT IDENTITY (1,1) NOT NULL,
[WeatherStationKey] INT NOT NULL,
[Date] Date NOT NULL,
[MeanMaxTemp_degC] DECIMAL (4,2),
[TotalRain_mm] DECIMAL (5,2),
CONSTRAINT [PK_FactWeatherMonthly] PRIMARY KEY CLUSTERED
(
[WeatherMonthlyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
--Adding Foreign Keys
IF NOT EXISTS (SELECT *   FROM sys.foreign_keys 
WHERE object_id = OBJECT_ID(N'dbo.FK_FactWeatherMonthly_DimWeatherStation') AND parent_object_id = OBJECT_ID(N'dbo.FactWeatherMonthly'))
ALTER TABLE [dbo].[FactWeatherMonthly]
ADD CONSTRAINT FK_FactWeatherMonthly_DimWeatherStation FOREIGN KEY ([WeatherStationKey])
REFERENCES [dbo].[DimWeatherStation] ([WeatherStationKey])


---CREATE FactWeatherCurrent

IF OBJECT_ID('dbo.FactWeather3h') IS NULL
CREATE TABLE [dbo].[FactWeather3h]
(
[FactWeather3hKey] INT IDENTITY (1,1) NOT NULL,
[WeatherStationKey] INT NOT NULL ,
[Date] DATE NOT NULL,
[TimeInterval] INT NOT NULL,
[ForecastMeanMaxTemp_degC] DECIMAL (4,2),
[CurrentMeanMaxTemp_degC] DECIMAL (4,2),
[ForecastTotalRain_mm] DECIMAL (5,2),
[CurrentTotalRain_mm] DECIMAL (5,2),
CONSTRAINT [PK_FactWeather3h] PRIMARY KEY CLUSTERED
(
[FactWeather3hKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
--Adding Foreign Keys
IF NOT EXISTS (SELECT *   FROM sys.foreign_keys 
WHERE object_id = OBJECT_ID(N'dbo.FK_FactWeather3h_DimWeatherStation') AND parent_object_id = OBJECT_ID(N'dbo.FactWeather3h'))
ALTER TABLE [dbo].[FactWeather3h]
ADD CONSTRAINT FK_FactWeather3h_DimWeatherStation FOREIGN KEY ([WeatherStationKey])
REFERENCES [dbo].[DimWeatherStation] ([WeatherStationKey])

---CREATE FactWeatherCurrent
IF OBJECT_ID('dbo.FactWeatherDaily') IS NULL
CREATE TABLE [dbo].[FactWeatherDaily]
(
[FactWeatherDailyKey] INT IDENTITY (1,1) NOT NULL,
[WeatherStationKey] INT NOT NULL ,
[Date] DATE NOT NULL,
[ForecastMeanMaxTemp_degC] DECIMAL (4,2),
[CurrentMeanMaxTemp_degC] DECIMAL (4,2),
[ForecastTotalRain_mm] DECIMAL (5,2),
[CurrentTotalRain_mm] DECIMAL (5,2),
CONSTRAINT [PK_FactWeatherDaily] PRIMARY KEY CLUSTERED
(
[FactWeatherDailyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
--Adding Foreign Keys
IF NOT EXISTS (SELECT *   FROM sys.foreign_keys 
WHERE object_id = OBJECT_ID(N'dbo.FK_FactWeatherCurrent_DimWeatherStation') AND parent_object_id = OBJECT_ID(N'dbo.FactWeatherDaily'))
ALTER TABLE [dbo].[FactWeatherDaily]
ADD CONSTRAINT FK_FactWeatherCurrent_DimWeatherStation FOREIGN KEY ([WeatherStationKey])
REFERENCES [dbo].[DimWeatherStation] ([WeatherStationKey])

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


DECLARE @StartDate DATE = '18400101', @NumberOfYears INT = 130;

-- prevent set or regional settings from interfering with 
-- interpretation of dates / literals

SET DATEFIRST 7;
SET DATEFORMAT mdy;
SET LANGUAGE US_ENGLISH;

DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);

-- this is just a holding table for intermediate calculations:
If not exists (select * from sys.tables where name = 'dimdate')
begin
CREATE TABLE DimDate
(
  [Date]       DATE PRIMARY KEY, 
  [Day]        AS DATEPART(DAY,      [date]),
  [Month]      AS DATEPART(MONTH,    [date]),
  [FirstOfMonth] AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [date]), 0)),
  [MonthName]  AS DATENAME(MONTH,    [date]),
  [Week]       AS DATEPART(WEEK,     [date]),
  [ISOweek]    AS DATEPART(ISO_WEEK, [date]),
  [DayOfWeek]  AS DATEPART(WEEKDAY,  [date]),
  [DayName]	   AS DATENAME(dw, [date]),
  [quarter]    AS DATEPART(QUARTER,  [date]),
  [year]       AS DATEPART(YEAR,     [date]),
  FirstOfYear  AS CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [date]), 0)),
  Style112     AS CONVERT(CHAR(8),   [date], 112),
  Style101     AS CONVERT(CHAR(10),  [date], 101)
);

-- use the catalog views to generate as many rows as we need

INSERT DimDate([date]) 
SELECT d
FROM
(
  SELECT d = DATEADD(DAY, rn - 1, @StartDate)
  FROM 
  (
    SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
      rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
    FROM sys.all_objects AS s1
    CROSS JOIN sys.all_objects AS s2
    -- on my system this would support > 5 million days
    ORDER BY s1.[object_id]
  ) AS x
) AS y;


ALTER TABLE DimDate 
ADD Primary Key (DateKey)

ALTER TABLE [dbo].[FactWeatherDaily] ADD FOREIGN KEY (Date) 
REFERENCES DimDate(Date);

ALTER TABLE[dbo].[FactWeatherMonthly]
ADD FOREIGN KEY (Date) 
REFERENCES DimDate(Date);

ALTER TABLE [dbo].[FactWeather3h] ADD FOREIGN KEY (Date) 
REFERENCES DimDate(Date);

end