import pandas as pd
from sqlalchemy import create_engine
import sqlite3
import os

# CONFIGURATION
CRS_CONN = 'postgresql://postgres:admin@localhost:5432/CRS_DB'
HR_CONN  = 'postgresql://postgres:admin@localhost:5432/Employees_DB'
PUB_CONN = 'postgresql://postgres:admin@localhost:5432/Publications_DB'

# Staging Layer
STAGING_DB_PATH = 'staging.db'

# EXTRACTION ENGINE
def extract_and_load(source_engine, source_query, staging_table_name):
    """
    1. Connects to Source (Postgres).
    2. Reads data into Pandas.
    3. Overwrites data into Staging (SQLite).
    """
    try:
        print(f"Extracting [{staging_table_name}]...", end=" ")
        
        # A. EXTRACT
        df = pd.read_sql(source_query, source_engine)
        
        # B. LOAD (Write to Staging)
        with sqlite3.connect(STAGING_DB_PATH) as conn:
            df.to_sql(staging_table_name, conn, if_exists='replace', index=False)   # Overwrite existing table if it exists
            
        print(f"Success! ({len(df)} rows)")
        
    except Exception as e:
        print(f"\n[!] Error on {staging_table_name}: {e}")

# MAIN PIPELINE
def run_pipeline():
    print("--- STARTING EXTRACTION PHASE ---")
    
    # Initialize Database Engines
    crs_engine = create_engine(CRS_CONN)
    hr_engine  = create_engine(HR_CONN)
    pub_engine = create_engine(PUB_CONN)

    # SOURCE 1: CRS
    extract_and_load(crs_engine, "SELECT * FROM students",        "raw_crs_students")
    extract_and_load(crs_engine, "SELECT * FROM courses",         "raw_crs_courses")
    extract_and_load(crs_engine, "SELECT * FROM enrollments",     "raw_crs_enrollments")
    extract_and_load(crs_engine, "SELECT * FROM departments",     "raw_crs_departments")
    extract_and_load(crs_engine, "SELECT * FROM colleges",        "raw_crs_colleges")
    extract_and_load(crs_engine, "SELECT * FROM degree_programs", "raw_crs_programs")
    extract_and_load(crs_engine, "SELECT * FROM course_offerings", "raw_crs_offerings")
    extract_and_load(crs_engine, "SELECT * FROM class_assignments", "raw_crs_assignments")
    extract_and_load(crs_engine, "SELECT * FROM faculty",         "raw_crs_faculty")


    # SOURCE 2: HR
    extract_and_load(hr_engine, "SELECT * FROM employees",          "raw_hr_employees")
    extract_and_load(hr_engine, "SELECT * FROM persons",            "raw_hr_persons")
    extract_and_load(hr_engine, "SELECT * FROM units",              "raw_hr_units")
    extract_and_load(hr_engine, "SELECT * FROM designations",       "raw_hr_designations")
    extract_and_load(hr_engine, "SELECT * FROM employee_statuses",  "raw_hr_statuses")
    extract_and_load(hr_engine, "SELECT * FROM employee_sub_statuses", "raw_hr_sub_statuses")


    # SOURCE 3: PUBLICATIONS
    
    # Metadata in 'publications' table
    pub_query = """
        SELECT id, title, publication_type_id, source_id, volume, issue, page, 
               month_published, day_published, year_published, document, status_id, 
               CAST(metadata AS TEXT) as metadata, 
               created_by, created_at, updated_by, updated_at, approved_by, approved_at
        FROM publications
    """
    extract_and_load(pub_engine, pub_query, "raw_pub_publications")
    extract_and_load(pub_engine, "SELECT * FROM publication_types", "raw_pub_types")
    extract_and_load(pub_engine, "SELECT * FROM authors", "raw_pub_authors")
    extract_and_load(pub_engine, "SELECT * FROM persons", "raw_pub_persons") 
    extract_and_load(pub_engine, "SELECT * FROM sources", "raw_pub_sources")
    
    # Metadata in 'publication_authors' table
    link_query = """
        SELECT publication_id, author_id, status_id, 
               CAST(metadata AS TEXT) as metadata, 
               created_by, created_at, approved_by, approved_at 
        FROM publication_authors
    """
    extract_and_load(pub_engine, link_query, "raw_pub_links")

    print("--- EXTRACTION COMPLETE ---")
    print(f"Data saved to: {os.path.abspath(STAGING_DB_PATH)}")

if __name__ == "__main__":
    run_pipeline()