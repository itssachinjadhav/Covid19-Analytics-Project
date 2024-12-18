# Analysis Steps for COVID-19 Analytics Project

This document provides a detailed explanation of the SQL queries used in the project. It outlines the purpose, logic, and expected outcomes of each step, from data preparation to analysis queries.

## 1. Database and Table Creation

The first step involves creating a database and a table to store the dataset. This ensures proper organization and accessibility of the data for analysis.

### SQL Code:
```sql
CREATE DATABASE Covid19_Project;
USE Covid19_Project;

    CREATE TABLE CovidP (
        Date_of_Datarecorded DATE,
        Residence_Jurisdiction VARCHAR(MAX),
        Period VARCHAR(MAX),
        Data_Recorded_Start_Date DATE,
        Data_Recorded_End_Date DATE,
        Covid_Deaths INT,
        Total_Covid_Prct FLOAT,
        Pct_Change_Weekly FLOAT,
        Pct_Diff_Weekly FLOAT,
        Crude_Covid_Rate FLOAT,
        African_Americn_Covid_Rate FLOAT
    );
```
**Purpose:** 

* To define the schema and ensure the data structure matches the analysis requirements.

## 2. Data Loading

Data is loaded into the CovidP table using the BULK INSERT command. This step imports data from a CSV file.

### SQL Code:
```sql
    BULK INSERT CovidP
    FROM 'C:\path_to_file\data.csv'
    WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', FIRSTROW = 2);
```

**Purpose:**

* To populate the table with raw data from the CSV file for further analysis.

## 3. Data Cleaning

**3.1 Handling NULL Values**
NULL values in critical columns are replaced to maintain data integrity.
    - Replace NULLs in Covid_Deaths, Total_Covid_Prct, and Crude_Covid_Rate with 0.
    - Replace NULLs in Pct_Change_Weekly and Pct_Diff_Weekly with the mean of non-NULL values.

**SQL Code:**
```sql
-- Replace NULLs with 0
UPDATE CovidP SET Covid_Deaths = 0 WHERE Covid_Deaths IS NULL;
UPDATE CovidP SET Total_Covid_Prct = 0 WHERE Total_Covid_Prct IS NULL;
UPDATE CovidP SET Crude_Covid_Rate = 0 WHERE Crude_Covid_Rate IS NULL;

-- Replace NULLs with mean values
UPDATE CovidP SET Pct_Change_Weekly = (
    SELECT ROUND(AVG(Pct_Change_Weekly), 2) FROM CovidP WHERE Pct_Change_Weekly IS NOT NULL)
WHERE Pct_Change_Weekly IS NULL;

UPDATE CovidP SET Pct_Diff_Weekly = (
    SELECT ROUND(AVG(Pct_Diff_Weekly), 2) FROM CovidP WHERE Pct_Diff_Weekly IS NOT NULL)
WHERE Pct_Diff_Weekly IS NULL;
```

**Purpose:**
* Ensures that missing data does not skew analysis results.

## 4. Choosing Data Categories
The dataset contains categories like Total, Weekly, and 3-month period. Weekly data is chosen for this analysis due to its consistency and regular distribution.

**SQL Code:**
```sql
SELECT SUM(Covid_Deaths) AS Total_Deaths,
       MIN(Data_Recorded_Start_Date) AS Start_Date,
       MAX(Data_Recorded_End_Date) AS End_Date
FROM CovidP
WHERE Period = 'Weekly';
```

**Purpose:**
* Identifies the range and total deaths in the Weekly category for focused analysis.

## 5. Analysis Queries

### Query 1: Retrieve the Jurisdiction with Highest COVID Death
Retrieve the jurisdiction residence with the highest number of COVID deaths for the latest weekly data period end date.
```sql
SELECT TOP 1 Residence_Jurisdiction, COVID_deaths, Data_Period_End
FROM CovidP
WHERE Data_Period_End = (
    SELECT MAX(Data_Period_End)
    FROM CovidP
) AND Period = 'Weekly'
ORDER BY COVID_deaths DESC;
```
**Purpose:**
Identifies the jurisdiction with the highest COVID deaths during the most recent weekly reporting period. This helps in pinpointing areas most affected by the pandemic in the latest timeframe.

### Query 2: Weekly Percentage Change in Crude COVID Rate
Calculate the week-over-week percentage change in the crude COVID rate for all jurisdictions and groups, sorted by the highest percentage change first.
```sql
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
            ELSE ROUND(((crude_COVID_rate - prev_crude_COVID_rate) / prev_crude_COVID_rate) * 100, 2)
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
    pct_change_wk DESC;
```

**Purpose:**
* Identifies week-over-week fluctuations in crude COVID rates across jurisdictions.
* Helps highlight areas with significant rate changes, which may indicate evolving pandemic hotspots or emerging trends.

### Query 3: Top 5 Jurisdictions by African American COVID Rate Difference
Retrieve the top 5 jurisdictions with the highest percentage difference in African American COVID rate compared to the overall crude COVID rate for the latest data period end date.
```sql
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
    pct_diff_aa_vs_crude DESC;
```
**Purpose:**
* Highlights jurisdictions with the largest percentage disparity between African American COVID rates and the overall crude COVID rate.
* Helps uncover potential demographic inequities in COVID's impact for the latest reporting period.

### Query 4: Average COVID Deaths per Week
Calculate the average COVID deaths per week for each jurisdiction and group for the latest 4 data period end dates.
```sql
WITH LatestPeriods AS (
    SELECT TOP 4 Data_Period_End
    FROM CovidP 
    GROUP BY Data_Period_End 
    ORDER BY Data_Period_End DESC
)
SELECT 
    Residence_Jurisdiction,
    Period,
    AVG(Covid_Deaths) AS Avg_Covid_Deaths_Per_Week
FROM 
    CovidP
WHERE 
    Data_Period_End IN (SELECT Data_Period_End FROM LatestPeriods) AND Period = 'Weekly'
GROUP BY 
    Residence_Jurisdiction, Period
ORDER BY 
    Avg_Covid_Deaths_Per_Week DESC;
```

**Purpose:**
* Provides insights into the average weekly COVID deaths for jurisdictions over the most recent data periods.
* Helps monitor the consistency of death rates and compare them across jurisdictions.

### Query 5: Exclude Zero Deaths and Missing Data
Retrieve the data for the latest data period end date, but exclude any jurisdictions that had zero COVID deaths and have missing values in any other column.
```sql
SELECT *
FROM CovidP
WHERE Data_Period_end = (
    SELECT MAX(Data_Period_end) 
    FROM CovidP
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
AND Period = 'Weekly';
```

**Purpose:**
* Focuses on high-quality data for analysis by excluding records with zero deaths or missing values in critical columns.
* Ensures the dataset is clean and representative of meaningful trends for the latest period.

### Query 6: Weekly Percentage Change in Total COVID Percentage
Calculate the week-over-week percentage change in Total_Covid_Prct for all jurisdictions and groups, but only for data period start dates after March 1, 2020.
```sql
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
        AND Period='Weekly'
),
Pct_diff_calc AS (
    SELECT 
        Residence_jurisdiction,
        Period,
        Data_Period_start,
        Data_Period_end,
        Total_Covid_Prct,
        Prev_Week_Prct,
        CASE
            WHEN Prev_week_Prct = 0 OR Prev_Week_Prct IS NULL THEN NULL
            ELSE ((Total_Covid_Prct - Prev_Week_Prct) / Prev_Week_Prct) * 100
        END AS Pct_change_weekly  
    FROM 
        week_over_week
    WHERE 
        Period='Weekly'
)
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
```

**Purpose:**
* Analyzes week-over-week percentage changes in the total COVID percentage (Total_Covid_Prct) for jurisdictions after March 1, 2020.
* Helps identify trends and anomalies in the proportion of total COVID deaths attributed to various regions over time.

### Query 7: Cumulative COVID Deaths by Jurisdiction
Group the data by jurisdiction residence and calculate the cumulative COVID deaths for each jurisdiction, but only up to the latest data period end date.
```sql
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
    cumulative_COVID_deaths DESC;
```

**Purpose:**
* Tracks the total cumulative COVID deaths by jurisdiction up to the most recent reporting period.
* Provides an overview of which jurisdictions have been most impacted over time.

### Query 8: Identify Jurisdiction with Highest Weekly Percentage Increase in COVID Deaths
Retrieve the jurisdiction with the highest percentage increase in COVID deaths from the previous week, while providing the actual numbers of deaths for both the current and previous weeks.
```sql
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
```

**Purpose:**
* **Monitor Trends:** Highlights jurisdictions with the sharpest week-over-week increases in COVID deaths, allowing for targeted intervention or analysis.
* **Accurate Comparisons:** By using the LAG function, the query effectively calculates deaths for the previous week, enabling precise percentage change calculations.
* **Data Quality:** Excludes divisions where previous deaths are zero to avoid invalid percentage calculations.
* **Actionable Insights:** Provides a ranked list based on percentage increase, facilitating quick identification of jurisdictions with concerning trends.

### Query 9: Compare Crude COVID Death Rates for Jurisdictions Exceeding Death Threshold
Retrieve and compare the crude COVID death rates for different jurisdictions, but only include those where the total number of deaths exceeds a specified threshold (e.g., 100).
```sql
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
```

**Purpose:**
* Focus on jurisdictions with significant COVID deaths (over 100) to ensure meaningful comparisons of crude death rates and prioritize high-impact regions for analysis.

### Query 10: Implementation of Function & Procedure
Create a stored procedure and a user-defined function to compare the average weekly percentage change in COVID deaths to the average crude COVID rate for each jurisdiction
```sql
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
```

**Purpose:**
* **Reusable Function:** The AvgCrudeCovidRate function calculates the average crude COVID rate for a given jurisdiction across the entire dataset.

* **Dynamic Analysis:** The CompareCovidData stored procedure calculates the average weekly percentage change in COVID deaths for each jurisdiction within a specified date range.

* **Holistic Comparison:** Combines results from both the function and procedure to analyze trends and compare weekly changes to the crude death rate, enabling a comprehensive understanding of jurisdictional COVID patterns. 

* **Efficient Execution:** Use of a temporary table streamlines data storage and processing for output results

## Conclusion
These steps ensure a structured approach to preparing, cleaning, and analyzing COVID-19 data. The SQL queries provide insights into trends, demographic disparities, and regional comparisons.