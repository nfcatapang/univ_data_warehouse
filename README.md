# University Data Warehouse and ETL Pipeline

This project builds a simple university data warehouse from three separate source systems:

- CRS database for student, course, and enrollment data
- HR database for employee, faculty, and organization data
- Publications database for research output data

The pipeline extracts data from the source databases, transforms it with Python and Pandas, and loads it into a centralized PostgreSQL data warehouse. A Dash app sits on top of the warehouse to visualize faculty and student insights and answer business questions.

## What the project includes

- `ETL_Pipeline/` - scripts for extract, transform, and load steps
- `SQL_Scripts/` - DDL scripts for data warehouse, and analysis queries
- `Dash/` - a Dash dashboard that reads from the warehouse

## What it does

1. Pulls data from the CRS, HR, and Publications databases.
2. Cleans, combines, and prepares the data for analytics.
3. Loads the final tables into the university data warehouse.
4. Uses SQL and a Dash dashboard to explore faculty performance, enrollment trends, and publication activity.

## Tech Stack

- Python
- Pandas
- SQLAlchemy
- PostgreSQL
- SQLite for staging
- Dash for the dashboard
- Plotly
- SQL
