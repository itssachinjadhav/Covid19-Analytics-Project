# Pandemic Mortality Trends: COVID-19 Data Analysis 🌍📊

## 🗒️Project Overview

This project delves into the provisional COVID-19 death data, providing insights into mortality trends across jurisdictions, exploring rate comparisons, and identifying key patterns. By leveraging SQL for data analysis and Power BI for dynamic visualizations, the project aims to reveal actionable insights about the pandemic's impact.

## ⭐Features

### 🛠️SQL Analysis

* **Top Jurisdictions**: Retrieve jurisdictions with the highest COVID deaths for the latest data period.

* **Weekly Trends**: Calculate week-over-week percentage changes in crude COVID rates.

* **Regional Comparisons**: Compare the top 5 jurisdictions with the highest difference in African American COVID rates and overall crude COVID rates.

* **Regional Comparisons**: Compare the top 5 jurisdictions with the highest difference in African American COVID rates and overall crude COVID rates.

* **Custom Procedures**: Implement stored procedures and user-defined functions to calculate average weekly percentage changes and crude COVID rates.

### 📈Power BI Visualizations

* **Dynamic Reports**:
    - Regional trends in COVID deaths.
    - Crude death rates by jurisdiction compared to national averages.
    - Weekly percentage changes and comparisons across jurisdictions.

* **Interactive Features**:
    - Buttons and bookmarks to toggle between visuals.
    - Slicers for filtering by region, time, and demographic groups.

## 🖥️Technologies Used

* **SQL**: For data extraction, transformation, and analysis.
* **Power BI**: To create interactive and dynamic visualizations.
* **Dataset**: Provisional COVID-19 death data, sourced from publicly available records.

## 🧹Data Preparation and Cleaning

To ensure high-quality analysis, the following steps were performed on the dataset:

1. Database and Table Creation
    
    * A SQL database Covid19_Project and table CovidP were created to store COVID-19 data.
    
    ```sql
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

2. **Data Loading**:
   
    * Data was imported into the table using the BULK INSERT command.
    
    ```sql 
    BULK INSERT CovidP
    FROM 'C:\Users\getla\OneDrive\Desktop\Dataset\project sept\DA_Data (1).csv'
    WITH (Fieldterminator = ',', Rowterminator = '\n', Firstrow = 2);
    

3. **Handling NULL Values**:
    
    * NULL values in critical columns like Covid_Deaths, Total_Covid_Prct, and Crude_Covid_Rate were replaced with 0.
    * NULL values in Pct_Change_Weekly and Pct_Diff_Weekly were replaced with the mean values of the respective columns.
    
    ```sql
    UPDATE CovidP SET Covid_Deaths = 0 WHERE Covid_Deaths IS NULL;
    UPDATE CovidP SET Total_Covid_Prct = 0 WHERE Total_Covid_Prct IS NULL;
    UPDATE CovidP SET Crude_covid_rate = 0 WHERE Crude_covid_rate IS NULL;

    UPDATE CovidP SET Pct_Change_Weekly = (
    SELECT ROUND(AVG(Pct_Change_Weekly), 2) FROM CovidP WHERE Pct_Change_Weekly IS NOT NULL
    ) WHERE Pct_Change_Weekly IS NULL;

    UPDATE CovidP SET Pct_Diff_Weekly = (
    SELECT ROUND(AVG(Pct_Diff_Weekly), 2) FROM CovidP WHERE Pct_Diff_Weekly IS NOT NULL
    ) WHERE Pct_Diff_Weekly IS NULL;

4. **Data Categorization**:
    
    * Verified and categorized data under Period column into three groups:
        - **Total**: Represents cumulative deaths
        - **Weekly**: Weekly distribution of deaths (chosen for analysis due to consistency).
        - **3-Month Period**: Data aggregated over irregular 4-month intervals.
        
        ```sql
        SELECT SUM(Covid_Deaths) AS Total_deaths, MIN(Data_Recorded_Start_Date) AS Start_Date,
        MAX(Data_Recorded_End_Date) AS End_Date
        FROM CovidP WHERE Period = 'Weekly';

## 📖How to Use

1. **Clone the Repository**:
 git clone t


2. **SQL Analysis**:
    * Open the SQL/ folder and execute the scripts in a compatible SQL environment (e.g., MySQL, MSSQL).
    * Queries are modular to support specific insights, such as weekly trends and jurisdictional comparisons.

3. **Power BI Dashboard**:
    * Open covid_visuals.pbix in Power BI Desktop.
    * Use slicers and bookmarks to navigate the dashboard dynamically.

4. **Data Dictionary**:
    * Refer to Data/data_dictionary.md for a detailed explanation of dataset fields.

## 🗂️SQL Queries

### Key Queries Included:

   1. **Top Jurisdictions**: Retrieve the jurisdiction residence with the highest number of COVID deaths for the latest data period.
   
   2. **Weekly Percentage Change**: Calculate week-over-week changes in crude COVID rate, sorted by the highest percentage change.
   
   3. **Top 5 Comparisons**: Identify the top 5 jurisdictions with the highest difference in African American COVID rates compared to overall crude COVID rates
   
   4. **Cumulative Deaths**: Calculate cumulative deaths grouped by jurisdiction for the latest data period.
   
   5. **Exclusion of Zero Deaths**: Exclude jurisdictions with zero deaths or missing data in the latest data period.

   For a detailed explanation of the SQL analysis, refer to [Analysis Steps](./Documentation/analysis_steps.md).

## 📊Power BI Visuals:

### Key Visuals Included:

   1. **Bar Chart**:

      * **Purpose**: Show distribution of COVID deaths across jurisdictions.
      * **Features**: Includes slicers for region and time filtering.
   
   3. **Line Chart**:
      
      * **Purpose**: Analyze weekly trends in crude COVID rates.
      * **Interactivity**: Toggle between cumulative and non-cumulative views using bookmarks.

   5. **Custom Analysis**: A user-driven insight added to showcase trends not initially included in the dataset.

## 🎯Results Highlights

* **Top Jurisdictions**: Region 3 recorded the highest COVID deaths in the latest data.

* **Crude Death Rate Trends**: Jurisdictions with rates higher than 50 per 100,000 people stand out

* **Weekly Changes**: Steepest weekly increase of 35% observed in Region 9.

* **Regional Comparisons**: Region 1 consistently had the lowest mortality rates.

## Acknowledgments

Special thanks to publicly available data sources and tools that enabled this analysis. This project was part of the LearnBay advanced analytics curriculum, focusing on real-world data insights.
