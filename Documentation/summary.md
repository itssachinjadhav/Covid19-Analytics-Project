# Project Summary: COVID-19 Data Analysis

## Overview

This project provides an in-depth analysis of **COVID-19 trends**, focusing on **death counts**, **rates** and **regional comparisons** across the United States. The project is divided into two key phases:

1. **SQL Analysis** – Data extraction, transformation, and key metrics generation.
2. **Power BI Visualization** – Visual representation and interactive dashboards for insights discovery.

The analysis answers critical questions regarding COVID-19 trends, including changes over time, geographical comparisons, and patterns across jurisdictions and time periods.

## 1. SQL Analysis

SQL was used to clean, transform, and analyze the dataset, focusing on **COVID death metrics**. Below are the key queries and insights derived:

### Key Queries and Results:
**1.Top Jurisdiction with Highest COVID Deaths:**
   * Identified regions with the highest death counts for the latest available period.
   * **Result:** For the latest date, **California** had the highest total COVID deaths.

**2. Week-over-Week Percentage Change in Crude COVID Rate:**
   * Calculated weekly trends in crude COVID rates to understand the rate fluctuations.
   * Observation: **Michigan** experienced notable spikes during peak COVID waves.

**3. Top 5 Regions with Highest Percentage Differences:**
   * Compared the AA COVID Rate against the Crude COVID Rate for jurisdictions.
   * **Result:** Certain regions demonstrated a significantly higher deviation in specific COVID rates.

**4. Average COVID Deaths Per Week:**
   * Generated average weekly death counts for each jurisdiction over the most recent 4 periods.
   * **Finding:** The average number of weekly COVID deaths across jurisdictions shows a consistent trend in certain regions, with **United States** having the highest weekly death toll.

**5. Excluding Zero Death Regions:**
   * Filtered out regions with missing data and zero deaths for the latest period.
   * This ensures data accuracy for further analysis and comparison.

**6. Cumulative COVID Deaths:**
   * The cumulative COVID deaths up to the latest data period indicate that United States continues to lead in total deaths, reflecting the long-term impact of COVID-19 in this region. This highlights areas that were hit hardest throughout the pandemic.

**7. Jurisdiction with Highest Percentage Increase in Weekly Deaths:**
   * Analyzed weekly death trends to detect sharp increases across regions.
   * Michigan had the highest percentage increase in COVID deaths from the previous week. This rise indicates an emerging hot spot in the pandemic, with rapid growth in mortality over a short period, demanding further attention to contain the spread.

## 2. Power BI Analysis
   
   Power BI was used to transform the SQL results into dynamic visuals for storytelling and actionable insights. Below are the key visualizations and their contributions to the project:

### Key Visuals and Analysis

**1.COVID Deaths Over Time Across Regions**

  * **Visualization:** A multi-line chart showing the number of deaths over time for various regions.
  * **Purpose:** To track COVID waves and highlight the regions most impacted during specific timeframes.
  * **Observation:**
    
      * Significant spikes occurred in **January 2021** and **August 2021**.
      * States like **California** and **New York** experienced higher peaks compared to others.

**2. Yearly Change in COVID Deaths Across Regions** 

  * **Visualization:** A stacked bar chart displaying the yearly percentage breakdown of COVID deaths across different regions.
  * **Purpose:** To compare the proportional impact of COVID deaths across regions on a yearly basis.
  * **Observation:**
    
      * Some regions (e.g., Connecticut, New Jersey) showed high early death rates in 2020.
      * Yearly trends show fluctuations across different states as the pandemic evolved.   

**3. Additional Interactivity:**
   * Slicers, bookmarks, and buttons were implemented to allow users to filter and dynamically explore the data for specific jurisdictions, time periods, or metrics.

## 3. Key Insights 

### Overall Trends:
   
   * **COVID Death Waves:** Major peaks occurred in early 2021 and mid-2021, aligning with pandemic surges and variants like Delta.
   * **Geographical Disparities:**
      * States with high population density (e.g., **California, New York**) reported larger death counts.
      * Some regions demonstrated sharp percentage increases despite lower overall deaths.

### Regional Comparisons:

   * Yearly changes highlight how the pandemic affected regions differently over time.
   * Certain states had disproportionately high early death rates, while others showed spikes in later periods.

### SQL Insights Contribution:

   The SQL analysis provided a foundation for understanding:
   
  1. Death trends (weekly, cumulative, and top regions).
  2. Regions with sharp spikes and significant rate differences.
  3. Accurate metrics for visualization, ensuring robust Power BI outputs.

## 4. Conclusion

This project successfully combined SQL analysis and Power BI visualization to analyze and present COVID-19 death trends comprehensively. By answering critical questions and providing interactive visuals, the project highlights:

   * **Temporal patterns** in COVID deaths.
   * **Regional disparities** and yearly changes.
   * Actionable insights for further analysis or policymaking.

   This analysis can be extended to include other factors like vaccination rates, hospitalization data, and demographic impacts for a more holistic understanding.
