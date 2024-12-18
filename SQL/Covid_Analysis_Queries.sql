
-- 1. Database Creation:
Create Database Covid19_Project;

use Covid19_Project;

-- 2. Table Creation:
CREATE TABLE CovidP
(Date_of_Datarecorded DATE, Residence_Jurisdiction VARCHAR(MAX), Period VARCHAR(MAX), Data_Recorded_Start_Date DATE, 
 Data_Recorded_End_Date DATE, Covid_Deaths INT, Total_Covid_Prct FLOAT, Pct_Change_Weekly FLOAT, Pct_Diff_Weekly FLOAT,
 Crude_Covid_Rate FLOAT, African_Americn_Covid_Rate FLOAT)

 SELECT * FROM CovidP


-- 3. Data Loading
 BULK INSERT CovidP
 FROM
 'C:\Users\getla\OneDrive\Desktop\Dataset\project sept\DA_Data (1).csv'
 WITH(Fieldterminator=',',rowterminator='\n',firstrow=2)


 SELECT column_name ,data_type
FROM INFORMATION_SCHEMA.columns

-- 4. Data Cleaning

---Checkin for NULL values in each column----------
SELECT 
    COUNT(*) AS Total_Records, 
    SUM(CASE WHEN Crude_Covid_Rate IS NULL THEN 1 ELSE 0 END) AS Null_Count
FROM CovidP;										/* 1512 is the NULL count in Covid_deaths & Total_Covid_prct column*/		
													/* 12,728 is the NULL count in Pct_diff_weekly column */ 
													/* 13,299 is the NULL count in Pct_Change_Weekly */
													/* 2490 is the NULL count in Crude_covid_rate */


----Replacing the NULL values in Covid_deaths , Total_Covid_prct and Crude_covid_rate with '0' ------

UPDATE CovidP SET Covid_Deaths=0 WHERE Covid_Deaths IS NULL;
UPDATE CovidP SET Total_Covid_prct=0 WHERE Total_Covid_prct IS NULL;
UPDATE CovidP SET Crude_covid_rate=0 WHERE Crude_covid_rate IS NULL;



----Replacing the NULL values in Pct_Change_Weekly and Pct_diff_weekly column using mean --------

UPDATE CovidP SET Pct_Change_Weekly = (
									SELECT ROUND(AVG(Pct_Change_Weekly),2)
									FROM CovidP
									WHERE Pct_Change_Weekly IS NOT NULL)
									WHERE Pct_Change_Weekly IS NULL;


UPDATE CovidP SET Pct_Diff_Weekly = (
									SELECT ROUND(AVG(Pct_Diff_Weekly),2)
									FROM CovidP
									WHERE Pct_Diff_Weekly IS NOT NULL)
									WHERE Pct_Diff_Weekly IS NULL;



SELECT * FROM CovidP

----------------------------------------------
--Checking for the correct category in Group column for further analysis--
/* fOR 'TOTAL' Category */
SELECT 
	SUM(Covid_Deaths) as Total_deaths, 
	min(Data_Period_start) as Start_Date,
	MAX(Data_Period_end) as End_Date
FROM 
	CovidP
WHERE
	Period = 'Total'

/* For 'Weekly' Category */

SELECT 
	SUM(Covid_Deaths) as Total_deaths, 
	min(Data_Period_start) as Start_Date,
	MAX(Data_Period_end) as End_Date
FROM 
	CovidP
WHERE
	Period = 'Weekly'

/* For '3 month period' Category*/

SELECT 
	SUM(Covid_Deaths) as Total_deaths, 
	min(Data_Period_start) as Start_Date,
	MAX(Data_Period_end) as End_Date
FROM 
	CovidP
WHERE
	Period = '3 month period'


/* I've chosen weekly data for this analysis as it provides a properly distributed and consistent view of trends. 
In contrast, the total data represents a cumulative sum of daily figures, which can inflate the analysis  and 
the 3-month period covers only a 4-month range, making it less reliable for consistent comparison */


-- 4. SQL Queries:

--Query-1 Retrieve the jurisdiction residence with the highest number of COVID deaths for the latest  data period end date.---

SELECT TOP 1 Residence_Jurisdiction, COVID_deaths, data_Period_end
FROM CovidP
WHERE data_Period_end= ( SELECT MAX(data_Period_end) 
						 FROM CovidP
) AND Period ='weekly'
ORDER BY COVID_deaths DESC;


--Query-2 Calculate the week-over-week percentage change in crude COVID rate for all jurisdictions and  groups, 
--sorted by the highest percentage change first.--


WITH Week_Over_Week AS (
    SELECT 
        Residence_Jurisdiction,
        Period,
        data_period_start,
        Data_Period_end,
        crude_COVID_rate,
        LAG(crude_COVID_rate) OVER (PARTITION BY Residence_Jurisdiction, Period ORDER BY data_period_end) AS prev_crude_COVID_rate
    FROM 
        CovidP
	WHERE 
		Period = 'weekly'
),
Pct_change_calc AS (
	SELECT
		Residence_Jurisdiction,
		Period,
		data_period_start,
		data_period_end,
		crude_COVID_rate,
		prev_crude_COVID_rate,
		CASE 
			WHEN prev_crude_COVID_rate = 0 OR prev_crude_COVID_rate IS NULL THEN NULL
			ELSE ROUND(((crude_COVID_rate - prev_crude_COVID_rate) / prev_crude_COVID_rate) * 100,2)
		END AS pct_change_wk
	FROM
		Week_Over_Week
	)
SELECT * 
FROM 
	pct_change_calc
WHERE 
	pct_change_wk IS NOT NULL 
ORDER BY
	pct_change_wk DESC



--Query -3 Retrieve the top 5 jurisdictions with the highest percentage difference in aa_COVID_rate  
--compared to the overall crude COVID rate for the latest data period end date.


SELECT TOP 5
    Residence_Jurisdiction, 
    aa_COVID_rate, 
    crude_COVID_rate,
    ((aa_COVID_rate - crude_COVID_rate) / NULLIF(crude_COVID_rate, 0)) * 100 AS pct_diff_aa_vs_crude
FROM 
    CovidP
WHERE 
    data_period_end = (SELECT MAX(data_period_end) FROM CovidP)
    AND crude_COVID_rate <> 0 
	AND Period = 'Weekly'
ORDER BY 
    pct_diff_aa_vs_crude DESC;  


---Query-4 Calculate the average COVID deaths per week for each jurisdiction residence and group, for  the latest 4 data period end dates.

WITH LatestPeriods AS (
 
    SELECT TOP 4 Data_Period_end
	FROM CovidP 
	GROUP BY Data_Period_end 
    ORDER BY Data_Period_End DESC
)
SELECT 
	Residence_Jurisdiction,
	Period,
    Avg(Covid_deaths) as Avg_Covid_Deaths_Per_Week
FROM 
	CovidP
 WHERE 
	Data_Period_End IN (SELECT Data_Period_End FROM LatestPeriods) AND Period='Weekly'
GROUP BY 
	Residence_Jurisdiction,Period
ORDER BY 
	Avg_Covid_Deaths_Per_Week DESC;

---Query -5 Retrieve the data for the latest data period end date, 
--but exclude any jurisdictions that had  zero COVID deaths and have missing values in any other column.

SELECT *
FROM covidp
WHERE Data_Period_end = (
    SELECT MAX(Data_Period_end) 
    FROM covidp
)
AND Covid_Deaths > 0
AND Residence_Jurisdiction IS NOT NULL
AND Date_of_Datarecorded IS NOT NULL
AND Period IS NOT NULL
AND Data_Period_start IS NOT NULL
AND Total_Covid_Prct IS NOT NULL
AND Pct_Change_Weekly IS NOT NULL
AND Pct_Diff_Weekly IS NOT NULL
AND Crude_Covid_Rate IS NOT NULL
AND aa_Covid_Rate IS NOT NULL
AND Period='Weekly';

--Query-6 Calculate the week-over-week percentage change in COVID_pct_of_total for all jurisdictions  and groups, 
--but only for the data period start dates after March 1, 2020.

WITH week_over_week AS ( 
	SELECT
		Residence_jurisdiction,
		Period,
		Data_Period_start,
		Data_Period_end,
		Total_Covid_Prct,
		LAG(Total_Covid_Prct) OVER (PARTITION BY Residence_Jurisdiction, Period ORDER BY Data_Period_Start) AS Prev_Week_Prct
	FROM 
		CovidP
	WHERE 
		Data_Period_start >= '2020-03-01'
		AND Period='Weekly'),
Pct_diff_calc AS (
	SELECT 
		Residence_jurisdiction,
		Period,
		Data_Period_start,
		Data_Period_end,
		Total_Covid_Prct,
		Prev_Week_Prct,
		CASE
			WHEN Prev_week_Prct =0 or Prev_Week_Prct is NULL THEN NULL
			ELSE ((Total_Covid_Prct-Prev_Week_Prct)/Prev_Week_Prct)*100
		END AS Pct_change_weekly  
	FROM 
		week_over_week
	WHERE 
		Period='Weekly')
SELECT 
	Residence_jurisdiction,
	Period,
	Data_Period_start,
	Data_Period_end,
	Total_Covid_Prct,
	Prev_Week_Prct,
	Pct_change_weekly
FROM 
	Pct_diff_calc
WHERE 
	Pct_change_weekly IS NOT NULL
ORDER BY 
	Pct_change_weekly DESC;


--Query-7 Group the data by jurisdiction residence and calculate the cumulative COVID deaths for each  jurisdiction, 
--but only up to the latest data period end date.

SELECT 
   Residence_Jurisdiction, 
    SUM(COVID_deaths) AS cumulative_COVID_deaths
FROM 
    CovidP
WHERE 
    data_period_end <= (SELECT MAX(data_period_end) FROM CovidP)
	AND Period = 'Weekly'
GROUP BY 
    Residence_Jurisdiction
ORDER BY 
    cumulative_COVID_deaths DESC;

--Query-8 Identify the jurisdiction with the highest percentage increase in COVID deaths from the  previous week, 
--and provide the actual numbers of deaths for each week.This would require  a subquery to calculate the previous week's deaths.

WITH Previous_Week_Deaths AS (
    SELECT 
        Residence_Jurisdiction,
        Period,
        Covid_Deaths,
        LAG(Covid_Deaths, 1) OVER (PARTITION BY Residence_Jurisdiction ORDER BY Period) AS Previous_Week_Deaths
    FROM covidp
	WHERE Period = 'Weekly'
)
SELECT 
    Residence_Jurisdiction,
    Period,
    Covid_Deaths,
    Previous_Week_Deaths,
    CASE 
        WHEN Previous_Week_Deaths = 0 THEN NULL
        ELSE ((Covid_Deaths - Previous_Week_Deaths) / Previous_Week_Deaths) * 100
    END AS Pct_Increase_Weekly
FROM Previous_Week_Deaths
WHERE Period = 'Weekly'
ORDER BY Pct_Increase_Weekly DESC;

--Query-9 Compare the crude COVID death rates for different age groups, but only for jurisdictions  
--where the total number of deaths exceeds a certain threshold (e.g. 100).

/*Due to insufficient Data for Age cannot do any further analysis for age */
SELECT 
    Residence_Jurisdiction, 
    Crude_Covid_Rate, 
    SUM(Covid_Deaths) AS Total_Covid_Deaths
FROM 
    covidp
WHERE 
    Covid_Deaths > 100
GROUP BY 
    Residence_Jurisdiction, 
    Crude_Covid_Rate
ORDER BY 
    Total_Covid_Deaths DESC;



	
----Query-10 Implementation of Function & Procedure-"Create a stored procedure that takes in a date  range and calculates the average weekly percentage change in 
--COVID deaths for each  jurisdiction. The procedure should return the average weekly percentage change along with  the jurisdiction and date range as output. 
--Additionally, create a user-defined function that  takes in a jurisdiction as input and returns the average crude COVID rate for that jurisdiction  over the 
--entire dataset. Use both the stored procedure and the user-defined function to  compare the average weekly percentage change in COVID deaths for each jurisdiction 
--to the  average crude COVID rate for that jurisdiction.
	 

--Step 1 Creating a Function--
Drop Function AvgCrudeCovidRate

CREATE FUNCTION AvgCrudeCovidRate
(
    @jurisdiction VARCHAR(255)
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @AvgCrudeCovidRate FLOAT;

    SELECT @AvgCrudeCovidRate = AVG(Crude_Covid_Rate)
    FROM covidp
    WHERE Residence_Jurisdiction = @jurisdiction
	AND Period = 'Weekly'
    RETURN @AvgCrudeCovidRate;
END;
GO

--step 2. creating the stored procedure--
Drop Procedure CompareCovidData
CREATE PROCEDURE CompareCovidData
(
    @StartDate DATE,
    @EndDate DATE
)
AS
BEGIN
 
    CREATE TABLE #Results       /* Temporary table */
    (
        Jurisdiction VARCHAR(255),
        AvgPctChangeWeekly FLOAT,
        AvgCrudeCovidRate FLOAT
    );

    
    INSERT INTO #Results (Jurisdiction, AvgPctChangeWeekly, AvgCrudeCovidRate)    /*Calculating the average weekly percentage change in COVID deaths for each jurisdiction*/
    SELECT 
        Residence_Jurisdiction,
        AVG(Pct_Change_Weekly) AS AvgPctChangeWeekly,
        dbo.AvgCrudeCovidRate(Residence_Jurisdiction) AS AvgCrudeCovidRate
    FROM 
        covidp
    WHERE 
        Date_of_Datarecorded BETWEEN @StartDate AND @EndDate
		AND Period = 'Weekly'
    GROUP BY 
        Residence_Jurisdiction;

    
    SELECT 
        Jurisdiction,
        AvgPctChangeWeekly,
        AvgCrudeCovidRate
    FROM 
        #Results;

    
    DROP TABLE #Results;  /* Cleaning up Temp tabel */
END;
GO

EXEC CompareCovidData '2023-01-01', '2023-12-31';







