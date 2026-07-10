import pandas as pd
from sqlalchemy import create_engine, text
import sqlite3
from datetime import date, timedelta
import os
import datetime

# CONFIGURATION
STAGING_DB_PATH = 'staging.db'
DW_CONN_STR = 'postgresql://postgres:admin@localhost:5432/Univ_DW'

# HELPER FUNCTIONS
def get_staging_data(table_name):
    if not os.path.exists(STAGING_DB_PATH):
        raise FileNotFoundError(f"Staging DB not found at {STAGING_DB_PATH}")
    with sqlite3.connect(STAGING_DB_PATH) as conn:
        return pd.read_sql(f"SELECT * FROM {table_name}", conn)

def load_table_to_postgres(df, target_table, engine, if_exists='append'):
    if df.empty:
        print(f"Skipping {target_table} (No data)")
        return
    print(f"Loading {target_table} ({len(df)} rows)...", end=" ")
    df.columns = df.columns.str.lower()
    df.to_sql(target_table.lower(), engine, if_exists=if_exists, index=False, method='multi', chunksize=1000)
    print("Success!")

def get_active_faculty_keys(engine):
    query = text("SELECT employee_no, faculty_key FROM dim_faculty WHERE current_row_indicator = TRUE")
    with engine.connect() as conn:
        result = pd.read_sql(query, conn)
    return dict(zip(result['employee_no'], result['faculty_key']))

def create_unknown_records(engine):
    print("\n--- ENSURING UNKNOWN RECORDS ---")
    with engine.connect() as conn:
        conn.execute(text("INSERT INTO dim_faculty (faculty_key, employee_no, full_name, designation, row_effective_date, current_row_indicator) VALUES (-1, 'UNK', 'External/Unknown', 'N/A', '1900-01-01', TRUE) ON CONFLICT (faculty_key) DO NOTHING;"))
        conn.execute(text("INSERT INTO dim_student (student_key, student_number, full_name, email_primary) VALUES (-1, 0, 'Unknown Student', 'N/A') ON CONFLICT (student_key) DO NOTHING;"))
        conn.execute(text("INSERT INTO dim_course (course_key, course_code, course_title) VALUES (-1, 'UNK', 'Unknown Course') ON CONFLICT (course_key) DO NOTHING;"))
        conn.execute(text("INSERT INTO dim_organization (org_key, unit_code, unit_name) VALUES (-1, 'UNK', 'Unknown Unit') ON CONFLICT (org_key) DO NOTHING;"))
        conn.execute(text("INSERT INTO dim_publication_metadata (pub_meta_key, publication_title) VALUES (-1, 'Unknown Publication') ON CONFLICT (pub_meta_key) DO NOTHING;"))
        conn.execute(text("INSERT INTO dim_program (program_key, program_code, program_title, college_group) VALUES (-1, 'UNK', 'Unknown Program', 'N/A') ON CONFLICT (program_key) DO NOTHING;"))
        conn.commit()


# TRUNCATE STRATEGY
def truncate_transaction_tables(engine):
    print("--- TRUNCATING TRANSACTION TABLES ---")
    with engine.connect() as conn:
        # Transactions (Safe to delete/reload)
        conn.execute(text("TRUNCATE TABLE fact_student_performance RESTART IDENTITY CASCADE;"))
        conn.execute(text("TRUNCATE TABLE fact_research_output RESTART IDENTITY CASCADE;"))
        
        # Note: We DO NOT truncate fact_faculty_stats. It is a snapshot table and we want to preserve history.
        
        conn.commit()
    print(" -> Transaction tables truncated. Snapshot history preserved.\n")


# DIMENSION LOADERS
# A. SAFE LOADER (For Dimensions linked to History)
def load_dimension_safe(staging_table, dw_table, key_column, engine):
    """
    Inserts ONLY new rows. Never deletes.
    Crucial for Dim_Organization and Dim_Date to prevent Cascade Deletes of History.
    """
    print(f"\n--- SAFE LOAD: {dw_table.upper()} ---")
    
    # 1. Read Staging
    df_new = get_staging_data(staging_table)
    if df_new.empty: return

    # 2. Get Existing Keys from DW
    with engine.connect() as conn:
        try:
            existing_keys = pd.read_sql(f"SELECT {key_column} FROM {dw_table}", conn)
            existing_set = set(existing_keys[key_column.lower()].tolist())
        except Exception:
            existing_set = set()

    # 3. Filter New vs Existing
    if key_column in df_new.columns:
        key_col_staging = key_column
    else:
        key_col_staging = next((c for c in df_new.columns if c.lower() == key_column.lower()), None)
    
    if key_col_staging:
        df_load = df_new[~df_new[key_col_staging].isin(existing_set)].copy()
    else:
        df_load = df_new

    # 4. Load
    if not df_load.empty:
        print(f" -> Found {len(df_load)} new rows to insert.")
        load_table_to_postgres(df_load, dw_table, engine, if_exists='append')
    else:
        print(" -> No new rows. Table is up to date.")

# TYPE 1 LOADER (Full Refresh)
def load_dimension_type_1(staging_table, dw_table, engine):
    """
    Wipes and Reloads the table.
    Use ONLY for dimensions NOT referenced by the Snapshot Fact (or transient ones).
    """
    print(f"\n--- REFRESH LOAD: {dw_table.upper()} (SCD Type 1) ---")
    
    df = get_staging_data(staging_table)
    if df.empty: 
        print(" -> Skipping (No Data)")
        return

    with engine.connect() as conn:
        conn.execute(text(f"TRUNCATE TABLE {dw_table} RESTART IDENTITY CASCADE;"))
        conn.commit()
        print(f" -> Table {dw_table} truncated.")

    load_table_to_postgres(df, dw_table, engine, if_exists='append')

# SCD TYPE 2 LOADER (Faculty, Student)
def load_dim_faculty_scd2(dw_engine):
    print("\n--- LOADING DIM_FACULTY (SCD Type 2) ---")
    
    # Read New
    staging_df = get_staging_data("dim_faculty")
    cols_to_drop = ['Faculty_Key', 'Faculty_Staging_Key']
    staging_df = staging_df.drop(columns=[c for c in cols_to_drop if c in staging_df.columns])
    staging_df['Is_Active'] = staging_df['Is_Active'].astype(bool)
    if 'Student_Number' in staging_df.columns:
        staging_df['Student_Number'] = staging_df['Student_Number'].fillna(0).astype(int)

    # Read Old
    query = """
        SELECT employee_no, designation, employment_status, is_active, student_number
        FROM dim_faculty 
        WHERE current_row_indicator = TRUE
    """
    try:
        target_df = pd.read_sql(query, dw_engine)
        target_df.columns = ['Employee_No', 'Designation', 'Employment_Status', 'Is_Active', 'Student_Number']
        target_df['Student_Number'] = target_df['Student_Number'].fillna(0).astype(int)
    except Exception:
        target_df = pd.DataFrame(columns=['Employee_No', 'Designation', 'Employment_Status', 'Is_Active', 'Student_Number'])
    
    target_df.columns = [f"{col}_old" for col in target_df.columns]
    
    # Detect Changes
    merged = pd.merge(staging_df, target_df, left_on='Employee_No', right_on='Employee_No_old', how='left')
    
    new_hires = merged[merged['Employee_No_old'].isna()].copy()
    
    condition_changed = (
        (merged['Employee_No_old'].notna()) & 
        (
            (merged['Designation'] != merged['Designation_old']) | 
            (merged['Employment_Status'] != merged['Employment_Status_old']) |
            (merged['Is_Active'] != merged['Is_Active_old']) |
            (merged['Student_Number'] != merged['Student_Number_old'])
        )
    )
    promotions = merged[condition_changed].copy()
    
    print(f" -> Analysis: {len(new_hires)} New Hires, {len(promotions)} Updates/Promotions.")

    # Expire Old
    if not promotions.empty:
        employees_to_expire = tuple(promotions['Employee_No'].tolist())
        yesterday = date.today() - timedelta(days=1)
        emp_tuple_str = str(employees_to_expire)
        if len(employees_to_expire) == 1: emp_tuple_str = f"('{employees_to_expire[0]}')"

        update_query = text(f"""
            UPDATE dim_faculty
            SET row_expiration_date = :exp_date, current_row_indicator = FALSE
            WHERE employee_no IN {emp_tuple_str} AND current_row_indicator = TRUE
        """)
        with dw_engine.connect() as conn:
            conn.execute(update_query, {"exp_date": yesterday})
            conn.commit()

    # Insert New
    rows_to_insert = pd.concat([new_hires, promotions], ignore_index=True)
    if not rows_to_insert.empty:
        rows_to_insert['row_effective_date'] = date.today()
        rows_to_insert['row_expiration_date'] = None
        rows_to_insert['current_row_indicator'] = True
        
        final_cols = [c for c in rows_to_insert.columns if not c.endswith('_old')]
        load_table_to_postgres(rows_to_insert[final_cols], "dim_faculty", dw_engine)
    else:
        print(" -> Dim_Faculty is up to date.")

def load_dim_student_scd2(dw_engine):
    print("\n--- LOADING DIM_STUDENT (SCD Type 2) ---")
    
    staging_df = get_staging_data("dim_student")
    if 'Student_Key' in staging_df.columns: 
        staging_df = staging_df.drop(columns=['Student_Key'])

    # Read Existing
    query = "SELECT student_number, program_name, region, row_effective_date FROM dim_student WHERE current_row_indicator = TRUE"
    try:
        target_df = pd.read_sql(query, dw_engine)
    except:
        target_df = pd.DataFrame(columns=['student_number', 'program_name', 'region'])
    target_df.columns = [f"{col}_old" for col in target_df.columns]

    # Detect Changes
    merged = pd.merge(staging_df, target_df, left_on='student_number', right_on='student_number_old', how='left')
    
    # New Records (Initial Load)
    new_recs = merged[merged['student_number_old'].isna()].copy()
    if not new_recs.empty:
        new_recs['row_effective_date'] = date(1900, 1, 1)   # Default to 1900-01-01 during initial load
        new_recs['row_expiration_date'] = None
        new_recs['current_row_indicator'] = True

    # Updates (Program/Region Changes)
    updates = merged[
        (merged['student_number_old'].notna()) & 
        ((merged['program_name'] != merged['program_name_old']) | (merged['region'] != merged['region_old']))
    ].copy()
    
    if not updates.empty:
        updates['row_effective_date'] = date.today()       # Keep as Today
        updates['row_expiration_date'] = None
        updates['current_row_indicator'] = True
        
        # Expire Old Rows
        ids = tuple(updates['student_number'].tolist())
        yesterday = date.today() - timedelta(days=1)
        id_str = str(ids) if len(ids) > 1 else f"({ids[0]})"
        sql = f"UPDATE dim_student SET row_expiration_date = '{yesterday}', current_row_indicator = FALSE WHERE student_number IN {id_str} AND current_row_indicator = TRUE"
        with dw_engine.connect() as conn:
            conn.execute(text(sql))
            conn.commit()

    print(f" -> Analysis: {len(new_recs)} New (Backfilled), {len(updates)} Updates.")

    # Combine and Load
    final_load = pd.concat([new_recs, updates], ignore_index=True)
    if not final_load.empty:
        cols = ['student_number','full_name','email_primary','program_name','region','province','sex_assigned','row_effective_date','row_expiration_date','current_row_indicator']
        load_table_to_postgres(final_load[cols], "dim_student", dw_engine)
    else:
        print(" -> Dim_Student is up to date.")

# FACT LOADERS
def load_fact_with_faculty_lookup(table_name, engine, if_exists='append'):
    print(f"\n--- LOADING {table_name.upper()} ---")
    df = get_staging_data(table_name)
    if df.empty: return

    active_keys_map = get_active_faculty_keys(engine)
    if 'Employee_No' in df.columns:
        df['Faculty_Key'] = df['Employee_No'].map(active_keys_map).fillna(-1).astype(int)
        df = df.drop(columns=['Employee_No'])
    
    load_table_to_postgres(df, table_name, engine, if_exists=if_exists)

def load_fact_student_history(dw_engine):
    print("\n--- LOADING FACT_STUDENT_PERFORMANCE (With History & Alignment) ---")
    
    # Get Fact Staging
    fact_df = get_staging_data("fact_student_performance")
    if fact_df.empty: return

    # Get FULL Student Dimension History
    dim_student = pd.read_sql("SELECT student_key, student_number, program_name, row_effective_date, row_expiration_date FROM dim_student", dw_engine)
    
    # Get Program Dimension for Lookup
    dim_program = pd.read_sql("SELECT program_key, program_title FROM dim_program", dw_engine)
    prog_map = dict(zip(dim_program['program_title'].str.upper().str.strip(), dim_program['program_key']))   # Mapping Program Title to Program Key

    # Prepare Dates
    dim_student['eff'] = pd.to_datetime(dim_student['row_effective_date']).fillna(pd.Timestamp.min)
    dim_student['exp'] = pd.to_datetime(dim_student['row_expiration_date']).fillna(pd.Timestamp.max)
    
    # Join Fact to Student History (SCD Type 2 Lookup)
    merged = pd.merge(fact_df, dim_student, left_on='Student_Number', right_on='student_number', how='left')
    merged['fact_date'] = pd.to_datetime(merged['Date_Key'].astype(str), format='%Y%m%d', errors='coerce')
    
    # Filter for the Correct Time Slice
    valid_rows = merged[
        (merged['fact_date'] >= merged['eff']) & 
        (merged['fact_date'] <= merged['exp'])
    ].copy()   # valid rows are those where the fact date falls within the effective and expiration dates
    
    # Map Faculty Keys
    active_keys_map = get_active_faculty_keys(dw_engine)
    if 'Employee_No' in valid_rows.columns:
        valid_rows['Faculty_Key'] = valid_rows['Employee_No'].map(active_keys_map).fillna(-1).astype(int)
    else:
        valid_rows['Faculty_Key'] = -1

    # This is for cases where a student switches programs.
    # Overwrite Program Key (Alignment)
    # Use the 'program_name' from the HISTORICAL Student Record. This ensures Fact.Program_Key matches Dim_Student.Program_Name
    valid_rows['program_name_clean'] = valid_rows['program_name'].str.upper().str.strip()
    valid_rows['Program_Key'] = valid_rows['program_name_clean'].map(prog_map).fillna(-1).astype(int)

    # Clean up
    valid_rows['Student_Key'] = valid_rows['student_key'].astype(int)
    cols_to_load = ['Date_Key','Student_Key','Faculty_Key','Course_Key','Program_Key','Org_Key','Grade','Is_Passed','Units_Earned','Remarks']
    final_df = valid_rows[[c for c in cols_to_load if c in valid_rows.columns]]
    
    load_table_to_postgres(final_df, "fact_student_performance", dw_engine)

# Snapshot Loader for Fact_Faculty_Stats
def load_fact_snapshot(table_name, engine):
    """
    Idempotent Snapshot Loader.
    Deletes today's existing snapshot (if any) and inserts fresh data.
    Preserves historical snapshots.
    """
    print(f"\n--- LOADING SNAPSHOT: {table_name.upper()} ---")
    
    df = get_staging_data(table_name)
    if df.empty: return

    # Identify "Today's" Key from the incoming data
    snapshot_keys = df['Snapshot_Date_Key'].unique().tolist()
    
    # Delete existing records for THESE keys only
    if snapshot_keys:
        keys_str = ",".join(map(str, snapshot_keys))
        print(f" -> Clearing potential duplicates for dates: {keys_str}")
        delete_query = text(f"DELETE FROM {table_name} WHERE snapshot_date_key IN ({keys_str})")
        
        with engine.connect() as conn:
            conn.execute(delete_query)
            conn.commit()

    # Map Faculty Keys
    active_keys_map = get_active_faculty_keys(engine)
    if 'Employee_No' in df.columns:
        df['Faculty_Key'] = df['Employee_No'].map(active_keys_map).fillna(-1).astype(int)
        df = df.drop(columns=['Employee_No'])

    # Append
    load_table_to_postgres(df, table_name, engine, if_exists='append')

def load_fact_person_summary(dw_engine):
    print("\n--- LOADING FACT_PERSON_SUMMARY (Aggregated Snapshot) ---")

    # Get Staging Data
    staging_df = get_staging_data("fact_person_summary")
    if staging_df.empty: 
        print(" -> Skipping (No Data)")
        return

    # Get Active Keys for Lookups
    query_fac = "SELECT faculty_key, employee_no FROM dim_faculty WHERE current_row_indicator = TRUE"
    with dw_engine.connect() as conn:
        dim_fac = pd.read_sql(query_fac, conn)

    query_stud = "SELECT student_key, student_number FROM dim_student WHERE current_row_indicator = TRUE"
    with dw_engine.connect() as conn:
        dim_stud = pd.read_sql(query_stud, conn)

    # Merge
    # Faculty Key Map
    merged = pd.merge(staging_df, dim_fac, left_on='Employee_No', right_on='employee_no', how='left')

    # Student Key Map
    merged['Student_Number'] = pd.to_numeric(merged['Student_Number'], errors='coerce').fillna(0).astype(int)
    dim_stud['student_number'] = pd.to_numeric(dim_stud['student_number'], errors='coerce').fillna(0).astype(int)
    merged = pd.merge(merged, dim_stud, left_on='Student_Number', right_on='student_number', how='left')

    # Prepare Final DataFrame
    final_df = pd.DataFrame()
    
    # Keys
    final_df['faculty_key'] = merged['faculty_key'].fillna(-1).astype(int)
    final_df['student_key'] = merged['student_key'].fillna(-1).astype(int) 
    final_df['org_key'] = merged['org_key'].fillna(-1).astype(int)

    # Metrics
    final_df['total_publications'] = merged['total_publications']
    final_df['total_citations'] = merged['total_citations']
    final_df['h_index'] = merged['h_index']
    final_df['latest_pub_year'] = merged['latest_pub_year']
    final_df['avg_impact_factor'] = merged['avg_impact_factor']
    
    final_df['total_students_taught'] = merged['total_students_taught']
    final_df['avg_grade_given'] = merged['avg_grade_given']
    final_df['overall_pass_rate'] = merged['overall_pass_rate']
    
    final_df['was_former_student'] = merged['was_former_student'].fillna(0).astype(bool)
    final_df['student_gwa'] = merged['student_gwa']
    final_df['year_last_enrolled'] = merged['year_last_enrolled']
    
    final_df['last_updated_date'] = date.today()

    # Load to Postgres (Full Refresh)
    with dw_engine.connect() as conn:
        conn.execute(text("TRUNCATE TABLE fact_person_summary RESTART IDENTITY CASCADE;"))
        conn.commit()
    
    load_table_to_postgres(final_df, "fact_person_summary", dw_engine)


# EXECUTION PIPELINE
def run_pipeline():
    dw_engine = create_engine(DW_CONN_STR)
    truncate_transaction_tables(dw_engine)
    
    # Static Dimensions
    load_dimension_safe("dim_organization", "dim_organization", "Org_Key", dw_engine)
    load_dimension_safe("dim_date", "dim_date", "Date_Key", dw_engine)
    
    # Type 1 Dimensions
    load_dimension_type_1("dim_course", "dim_course", dw_engine)
    load_dimension_type_1("dim_program", "dim_program", dw_engine)
    load_dimension_type_1("dim_pub_metadata", "dim_publication_metadata", dw_engine)

    # Type 2 Dimensions (History)
    create_unknown_records(dw_engine)   # Ensure Unknowns exist before FK loads
    load_dim_faculty_scd2(dw_engine)
    load_dim_student_scd2(dw_engine)
    
    # Facts
    load_fact_student_history(dw_engine)
    load_fact_with_faculty_lookup("fact_research_output", dw_engine)
    load_fact_snapshot("fact_faculty_stats", dw_engine) 
    load_fact_person_summary(dw_engine)

if __name__ == "__main__":
    run_pipeline()