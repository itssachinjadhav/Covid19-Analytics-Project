# Project Overview: COVID-19 Analytics Project

## Objective

The primary objective of this project is to analyze provisional COVID-19 death data to uncover trends, patterns, and disparities across different jurisdictions and time periods. This analysis aims to support informed decision-making by providing key insights into the pandemic's impact.

## Scope

This project encompasses the following key areas:

1. **Data Cleaning and Preparation**:

    * Handling missing values and ensuring data consistency.
    * Categorizing data into relevant time periods (e.g., weekly, cumulative).

2. **SQL-Based Analysis:**

    * Identifying jurisdictions with the highest COVID deaths.
    * Calculating week-over-week percentage changes in death rates.
    * Comparing trends across different regions and demographic groups.
    * Implementing stored procedures and user-defined functions for advanced analytics.

3. **Power BI Visualizations:**

    * Creating dynamic dashboards for interactive exploration of data.
    * Highlighting trends, comparisons, and key statistics with visual clarity.

4. **Insights and Recommendations:**

    * Providing actionable insights derived from data.
    * Identifying areas for further exploration or policy focus.

## Data Sources

The dataset used for this project includes:
* **Provisional COVID-19 death data** containing fields such as:

    - Date_of_Datarecorded
    - Residence_Jurisdiction
    - Period
    - Data_Period_start
    - Data_Period_end
    - Covid_Deaths
    - Total_Covid_Prct
    - Pct_Change_Weekly
    - Pct_Diff_Weekly
    - Crude_Covid_Rate
    - aa_Covid_Rate

## Key Deliverables

1. **SQL Queries:**
    
    * A comprehensive set of SQL queries addressing key analytical questions.
    * Examples include identifying top jurisdictions, calculating weekly changes, and comparing death  rates.
    - For more details, visit [SQL Analysis Queries](../SQL/covid_analysis_queries.sql).

2. **Power BI Dashboard:**

    * An interactive report providing users with the ability to filter and explore data dynamically.
    * Download the dashboard here: [Power BI File](../PowerBI/covid_visuals.pbix).

3. **Documentation:**

    * Detailed explanation of the analysis process, SQL queries, and visualizations.
    * Additional resources:
      * [Analysis Steps](analysis_steps.md)
      * [Visualization Details](visualization_details.md)

## Tools and Technologies

* **SQL:** For data preparation and analysis.
* **Power BI:** For creating interactive and dynamic dashboards.
* **Microsoft SQL Server:** For database management.
* **Markdown Documentation:** For project documentation and presentation.

## Summary

This project demonstrates the power of data-driven insights to address real-world challenges. By leveraging SQL for data preparation and Power BI for visualization, it offers a comprehensive view of the pandemic's trends and impact across jurisdictions. The findings and visualizations can be utilized by policymakers, healthcare professionals, and researchers to develop more targeted responses to similar crises in the future.

### Helpful Links
- Return to the main documentation: [README](../README.md)