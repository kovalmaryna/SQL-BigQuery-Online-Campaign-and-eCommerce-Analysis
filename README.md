# SQL & BigQuery: Online Campaign and eCommerce Analysis
Final project of the SQL block in the Data Analyst courses from GoIT

## Project Overview
This project consolidated SQL knowledge into a comprehensive case study.  
The goal was to analyze online campaigns, practice SQL queries in BigQuery, connect to the GA4 dataset, and calculate the eCommerce funnel — from session start to purchase.

## Business Value & Insights
- **Campaign Effectiveness:** Identified top-performing campaigns across Google Ads and Facebook Ads.  
- **Conversion Funnel:** Measured user progression from session start to purchase, highlighting drop-off points.  
- **Unified Data Model:** Combined multiple sources (Google Ads, Facebook Ads, GA4) into a single analytical framework.  
- **Scalable Queries:** Leveraged BigQuery to process large datasets efficiently.  

## Technical Stack
- **SQL:** PostgreSQL (DBeaver IDE), BigQuery  
- **Datasets:** ads_analysis_goit_course, GA4 public dataset  
- **Visualization:** Tableau  

## Tasks
### 1. Online Campaign Analysis
- Aggregate daily spend (avg, max, min) for Google & Facebook.  
- Find top 5 days with highest ROMI.  
- Identify campaign with highest weekly value.  
- Detect campaign with largest month-to-month reach growth.  
- Longest continuous adset display.  

### 2. Data Preparation for BI
- Extract GA4 events for 2021 (session_start, view_item, add_to_cart, begin_checkout, add_shipping_info, add_payment_info, purchase).  

### 3. Conversion Funnel by Date & Channel
- Calculate visit-to-cart, visit-to-checkout, and visit-to-purchase conversions.  

### 4. Landing Page Comparison
- Conversion rates by page path (2020).  

### 5. Correlation Analysis
- Relationship between engagement and purchases.  

## Results
- **SQL Files:** Each task implemented in a separate `.sql` file.  
- **BigQuery Queries:** Saved and shared with public access.  
- **Visualizations:** Funnel charts and campaign performance dashboards.  

## Preview
### Advertising Effectiveness Indicators (Tableau Dashboard)
- **Dynamics of Spending (Google vs Facebook):** Line chart comparing daily spend across platforms.  
- **Top-5 Days by ROMI:** Bar chart highlighting peak return on marketing investment.  
- **Campaign Highlights:**  
  - Largest month-to-month reach growth.  
  - Record weekly value.  
  - Longest continuous Adset display.  

##  **You can view report here:** [View Tableau Report](https://public.tableau.com/app/profile/marina.koval8682/viz/Progect_SQL_Q1/sheet0)

<img width="1799" height="791" alt="зображення_2026-04-23_201157117" src="https://github.com/user-attachments/assets/9329c3e6-efc9-4b52-8c04-87b286c23a86" />
