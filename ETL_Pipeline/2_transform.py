import pandas as pd
import sqlite3
import hashlib
import os
import datetime

# SETUP & HELPER FUNCTIONS
STAGING_DB_PATH = 'staging.db'

def get_data(table_name):
    """Reads a table from staging.db into a Pandas DataFrame."""
    if not os.path.exists(STAGING_DB_PATH):
        print(f"[!] Staging DB not found: {STAGING_DB_PATH}")
        return pd.DataFrame()
        
    with sqlite3.connect(STAGING_DB_PATH) as conn:
        return pd.read_sql(f"SELECT * FROM {table_name}", conn)

def save_to_staging(df, table_name):
    """Saves a transformed DataFrame back to staging.db."""
    with sqlite3.connect(STAGING_DB_PATH) as conn:
        df.to_sql(table_name, conn, if_exists='replace', index=False)
    print(f" -> Saved {table_name} ({len(df)} rows)")

def generate_stable_key(value_str):
    """
    Generates a consistent Integer Key from a string input.
    Result is always the same for the same input string.
    """
    if pd.isna(value_str) or value_str == '':
        return -1
    
    # Create MD5 hash
    hash_obj = hashlib.md5(str(value_str).encode('utf-8'))
    # Convert first 8 bytes to int and constrain to PostgreSQL Integer range
    return int(hash_obj.hexdigest(), 16) % 2147483647


# TRANSFORM: DIM_STUDENT
def transform_dim_student():
    print("Transforming Dim_Student...", end=" ")
    
    students_df = get_data("raw_crs_students")
    programs_df = get_data("raw_crs_programs")
    
    # Deduplication
    students_df = students_df.drop_duplicates(subset=['student_number'], keep='first')

    # Merge
    merged_df = pd.merge(students_df, programs_df, on='program_id', how='left')
    
    dim_student = merged_df[[
        'student_number', 'full_name', 'email_primary', 
        'program_name', 'region', 'province', 'sex_assigned'
    ]].copy()
    
    # Cleaning
    dim_student[['region', 'province', 'program_name']] = dim_student[['region', 'province', 'program_name']].fillna('Unknown')
    dim_student['student_number'] = pd.to_numeric(dim_student['student_number'], errors='coerce').fillna(0).astype(int)
    dim_student['email_primary'] = dim_student['email_primary'].str.lower().str.strip()
    
    # Reorder
    cols = [c for c in dim_student.columns]
    save_to_staging(dim_student[cols], "dim_student")


# TRANSFORM: DIM_FACULTY (SCD2)
def transform_dim_faculty():
    print("Transforming Dim_Faculty...", end=" ")
    
    # Load Data
    emp_df = get_data("raw_hr_employees")
    person_df = get_data("raw_hr_persons")
    desig_df = get_data("raw_hr_designations")
    status_df = get_data("raw_hr_statuses")
    
    # Load CRS Data and RENAME key column immediately
    crs_students = get_data("raw_crs_students")
    crs_students = crs_students.rename(columns={'student_number': 'crs_linked_student_no'})
    
    auth_df = get_data("raw_pub_authors")
    pub_person_df = get_data("raw_pub_persons")

    # Prepare HR Base
    person_df['email_clean'] = person_df['email_primary'].astype(str).str.lower().str.strip()  # standardize
    
    # Merge HR tables
    hr_merged = pd.merge(emp_df, person_df, on='person_id', how='left')
    hr_merged = pd.merge(hr_merged, desig_df, left_on='emp_primary_designation_id', right_on='designation_id', how='left')
    hr_merged = pd.merge(hr_merged, status_df, on='emp_status_id', how='left')
    hr_merged = hr_merged.drop_duplicates(subset=['emp_number'])

    # Lookup (HR Email -> CRS Email)
    crs_students['email_clean'] = crs_students['email_primary'].astype(str).str.lower().str.strip()
    
    # Left Join: Attach CRS Student Number where Emails match
    hr_with_link = pd.merge(
        hr_merged, 
        crs_students[['email_clean', 'crs_linked_student_no']], 
        on='email_clean', 
        how='left'
    )
    
    # Prepare Publications
    pub_person_df['email'] = pub_person_df['email'].str.lower().str.strip()
    pub_merged = pd.merge(auth_df, pub_person_df, left_on='person_id', right_on='id', how='left')
    pub_metrics = pub_merged[['email', 'h_index', 'citation_count']].copy()
    pub_metrics = pub_metrics.groupby('email', as_index=False).max()

    # Final Merge (HR+Link -> Pubs)
    final_df = pd.merge(hr_with_link, pub_metrics, left_on='email_clean', right_on='email', how='left')
    
    # Build Dimension
    dim_fac = pd.DataFrame()
    dim_fac['Employee_No'] = final_df['emp_number']
    
    # Priority: CRS Link -> HR Record -> Default 0
    col_crs = final_df['crs_linked_student_no'] if 'crs_linked_student_no' in final_df.columns else pd.Series([None]*len(final_df))
    col_hr  = final_df['student_number'] if 'student_number' in final_df.columns else pd.Series([None]*len(final_df))
    
    dim_fac['Student_Number'] = col_crs.combine_first(col_hr).fillna(0).astype(int)
    
    dim_fac['Full_Name'] = final_df['full_name']
    dim_fac['Email_Address'] = final_df['email_primary']
    dim_fac['Designation'] = final_df['designation_name'].fillna('Unknown')
    dim_fac['Employment_Status'] = final_df['status_name'].fillna('Unknown')
    
    active_codes = ['PERM', 'TEMP', 'CONT']
    dim_fac['Is_Active'] = final_df['status_code'].isin(active_codes)
    dim_fac['H_Index'] = final_df['h_index'].fillna(0).astype(int)
    dim_fac['Total_Citations'] = final_df['citation_count'].fillna(0).astype(int)
    
    save_to_staging(dim_fac, "dim_faculty")


# TRANSFORM: DIM_ORGANIZATION
def transform_dim_organization():
    print("Transforming Dim_Organization...", end=" ")
    
    # CRS Data
    crs_dept = get_data("raw_crs_departments")
    crs_colleges = get_data("raw_crs_colleges")
    crs_merged = pd.merge(crs_dept, crs_colleges, on='college_id', how='left')
    
    # HR Data (Recursive)
    hr_units = get_data("raw_hr_units")
    hr_merged = pd.merge(hr_units, hr_units, left_on='parent_unit_id', right_on='unit_id', how='left', suffixes=('', '_parent'))
    
    # Conformed Format
    df_crs = pd.DataFrame()
    df_crs['unit_code'] = crs_merged['department_code'].str.upper().str.strip()
    df_crs['unit_name_crs'] = crs_merged['department_name']
    df_crs['parent_code_crs'] = crs_merged['college_code']
    df_crs['parent_name_crs'] = crs_merged['college_name']
    
    df_hr = pd.DataFrame()
    df_hr['unit_code'] = hr_merged['unit_code'].str.upper().str.strip()
    df_hr['unit_name_hr'] = hr_merged['unit_name']
    df_hr['parent_code_hr'] = hr_merged['unit_code_parent']
    df_hr['parent_name_hr'] = hr_merged['unit_name_parent']
    
    final_df = pd.merge(df_crs, df_hr, on='unit_code', how='outer')
    
    dim_org = pd.DataFrame()
    dim_org['Unit_Code'] = final_df['unit_code']
    dim_org['Unit_Name'] = final_df['unit_name_crs'].combine_first(final_df['unit_name_hr']).fillna('Top Level')
    dim_org['Parent_Unit_Code'] = final_df['parent_code_crs'].combine_first(final_df['parent_code_hr'])
    dim_org['Parent_Unit_Name'] = final_df['parent_name_crs'].combine_first(final_df['parent_name_hr'])
    
    # STABLE KEY
    dim_org['Org_Key'] = dim_org['Unit_Code'].apply(generate_stable_key)
    
    cols = ['Org_Key'] + [c for c in dim_org.columns if c != 'Org_Key']
    save_to_staging(dim_org[cols], "dim_organization")


# TRANSFORM: DIM_COURSE
def transform_dim_course():
    print("Transforming Dim_Course...", end=" ")
    
    df = get_data("raw_crs_courses")
    df['course_code'] = df['course_code'].str.upper().str.strip()
    df['course_title'] = df['course_title'].str.title().str.strip()
    df['units'] = pd.to_numeric(df['units'], errors='coerce').fillna(0.0)
    
    df = df.drop_duplicates(subset=['course_code'])
    
    dim_course = df[['course_code', 'course_title', 'units']].copy()
    dim_course.columns = ['Course_Code', 'Course_Title', 'Units']
    
    # STABLE KEY
    dim_course['Course_Key'] = dim_course['Course_Code'].apply(generate_stable_key)
    
    cols = ['Course_Key'] + [c for c in dim_course.columns if c != 'Course_Key']
    save_to_staging(dim_course[cols], "dim_course")


# TRANSFORM: DIM_PROGRAM
def transform_dim_program():
    print("Transforming Dim_Program...", end=" ")
    
    # Get Raw Data
    programs_df = get_data("raw_crs_programs")     
    depts_df = get_data("raw_crs_departments")    
    colleges_df = get_data("raw_crs_colleges")  
    
    # Join to build hierarchy: Program -> Dept -> College
    merged = pd.merge(programs_df, depts_df, on='department_id', how='left')
    merged = pd.merge(merged, colleges_df, on='college_id', how='left')
    
    # Rename and Select Columns for Dimension
    dim_prog = pd.DataFrame()
    dim_prog['program_code'] = merged['program_code'].str.upper().str.strip()
    dim_prog['program_title'] = merged['program_name'].str.strip()
    dim_prog['college_group'] = merged['college_name'].fillna('Unknown')
    
    # Generate Stable Key
    dim_prog['Program_Key'] = dim_prog['program_code'].apply(generate_stable_key)
    
    cols = ['Program_Key', 'program_code', 'program_title', 'college_group']
    save_to_staging(dim_prog[cols], "dim_program")


# TRANSFORM: DIM_PUB_METADATA
def transform_dim_pub_metadata():
    print("Transforming Dim_Publication_Metadata...", end=" ")
    
    pubs_df = get_data("raw_pub_publications")
    sources_df = get_data("raw_pub_sources")
    types_df = get_data("raw_pub_types")
    
    merged_src = pd.merge(pubs_df, sources_df, left_on='source_id', right_on='id', how='left', suffixes=('', '_src'))
    final_df = pd.merge(merged_src, types_df, left_on='publication_type_id', right_on='id', how='left', suffixes=('', '_type'))

    dim_meta = pd.DataFrame()
    dim_meta['Publication_Title'] = final_df['title'].str.strip()
    dim_meta['Publication_Type'] = final_df['name'].fillna('Other')
    dim_meta['Publisher'] = final_df['publisher'].fillna('Unknown').str.strip()
    dim_meta['Indexing_Type'] = final_df['index_coverage'].fillna('None').str.strip()

    dim_meta = dim_meta.drop_duplicates(subset=['Publication_Title'])
    
    # STABLE KEY
    dim_meta['Pub_Meta_Key'] = dim_meta['Publication_Title'].apply(generate_stable_key)
    
    cols = ['Pub_Meta_Key'] + [c for c in dim_meta.columns if c != 'Pub_Meta_Key']
    save_to_staging(dim_meta[cols], "dim_pub_metadata")


# TRANSFORM: DIM_DATE (Generated)
def generate_dim_date():
    print("Generating Dim_Date...", end=" ")
    
    date_range = pd.date_range(start='2010-01-01', end='2030-12-31')
    dim_date = pd.DataFrame(date_range, columns=['Full_Date'])
    
    dim_date['Date_Key'] = dim_date['Full_Date'].dt.strftime('%Y%m%d').astype(int)
    dim_date['Year'] = dim_date['Full_Date'].dt.year
    dim_date['Month_Name'] = dim_date['Full_Date'].dt.month_name()
    
    def get_semester(month):
        if month in [8, 9, 10, 11, 12]: return '1st Semester'
        elif month in [1, 2, 3, 4, 5]: return '2nd Semester'
        else: return 'Midyear'
            
    dim_date['Semester_Name'] = dim_date['Full_Date'].dt.month.apply(get_semester)
    
    def get_academic_year(row):
        year = row['Year']
        if row['Full_Date'].month >= 8: return f"{year}-{year+1}"
        else: return f"{year-1}-{year}"
            
    dim_date['Academic_Year'] = dim_date.apply(get_academic_year, axis=1)

    cols = ['Date_Key'] + [c for c in dim_date.columns if c != 'Date_Key']
    save_to_staging(dim_date[cols], "dim_date")


# TRANSFORM: FACT_STUDENT_PERFORMANCE
def transform_fact_student_perf():
    print("Transforming Fact_Student_Performance...", end=" ")
    
    # 1. Load Sources
    enroll_df = get_data("raw_crs_enrollments")
    offer_df  = get_data("raw_crs_offerings")
    assign_df = get_data("raw_crs_assignments")
    
    # 2. Load Lookups & Standardize Columns
    raw_stud = get_data("raw_crs_students")
    raw_stud.columns = raw_stud.columns.str.lower()
    
    raw_course = get_data("raw_crs_courses")
    raw_course.columns = raw_course.columns.str.lower()
    
    raw_fac = get_data("raw_crs_faculty") 
    raw_fac.columns = raw_fac.columns.str.lower()
    
    raw_dept = get_data("raw_crs_departments")
    raw_dept.columns = raw_dept.columns.str.lower()
    
    raw_prog = get_data("raw_crs_programs")
    raw_prog.columns = raw_prog.columns.str.lower()

    # 3. Load Dimensions (for Keys)
    dim_stud  = get_data("dim_student")
    dim_course = get_data("dim_course")
    dim_fac   = get_data("dim_faculty") 
    dim_org   = get_data("dim_organization")
    
    # Load Dim_Program and standardize
    dim_prog = get_data("dim_program")
    dim_prog.columns = dim_prog.columns.str.lower()
    
    # Denormalize Transaction Data
    tx_df = pd.merge(enroll_df, offer_df, on='class_id', how='left')
    tx_df = pd.merge(tx_df, assign_df, on='class_id', how='left')
    
    # Bridge to Natural Keys
    tx_df = pd.merge(tx_df, raw_stud[['student_id', 'student_number', 'program_id']], on='student_id', how='left')
    
    # JOIN FACULTY
    tx_df = pd.merge(tx_df, raw_fac[['faculty_id', 'faculty_name', 'faculty_email']], on='faculty_id', how='left')
    
    # Link Course -> Dept
    course_dept_link = pd.merge(raw_course, raw_dept, on='department_id', how='left')
    course_dept_map = course_dept_link[['course_id', 'department_code']].copy()
    course_dept_map['department_code'] = course_dept_map['department_code'].str.upper().str.strip()
    tx_df = pd.merge(tx_df, course_dept_map, on='course_id', how='left')

    # Start LOOKUPS
    fact = pd.DataFrame()
    
    # A. Student Key
    fact['Student_Number'] = tx_df['student_number'].fillna(0).astype(int)
    
    # B. Course Key
    tx_df = pd.merge(tx_df, raw_course[['course_id', 'course_code']], on='course_id', how='left', suffixes=('', '_raw'))
    tx_df['course_code'] = tx_df['course_code'].str.upper().str.strip()
    
    tmp_course = pd.merge(tx_df, dim_course[['Course_Code', 'Course_Key']], 
                          left_on='course_code', right_on='Course_Code', how='left')
    fact['Course_Key'] = tmp_course['Course_Key'].fillna(-1).astype(int)
    
    # C. Program Key
    tx_df = pd.merge(tx_df, raw_prog[['program_id', 'program_code']], on='program_id', how='left', suffixes=('', '_prog'))
    tx_df['program_code'] = tx_df['program_code'].str.upper().str.strip()
    
    tmp_prog = pd.merge(tx_df, dim_prog[['program_code', 'program_key']], on='program_code', how='left')
    fact['Program_Key'] = tmp_prog['program_key'].fillna(-1).astype(int)

    # D. Faculty Key
    # CRS 'faculty_email' -> Dim_Faculty 'Email_Address'
    
    tx_df['faculty_email_clean'] = tx_df['faculty_email'].str.lower().str.strip()
    dim_fac['email_clean'] = dim_fac['Email_Address'].str.lower().str.strip()
    
    tmp_fac = pd.merge(tx_df, dim_fac[['email_clean', 'Employee_No']], 
                       left_on='faculty_email_clean', right_on='email_clean', how='left')
    fact['Employee_No'] = tmp_fac['Employee_No'] 
    
    # E. Org Key
    tmp = pd.merge(tx_df, dim_org[['Unit_Code', 'Org_Key']], left_on='department_code', right_on='Unit_Code', how='left')
    fact['Org_Key'] = tmp['Org_Key'].fillna(-1).astype(int)
    
    # F. Date Key
    fact['Date_Key'] = pd.to_numeric(pd.to_datetime(tx_df['date_of_completion'], errors='coerce').dt.strftime('%Y%m%d')).fillna(19000101).astype(int)

    # Measures
    fact['Grade'] = pd.to_numeric(tx_df['grade'], errors='coerce')
    
    def check_pass(grade):
        if pd.isna(grade): return 0
        if 1.0 <= grade <= 3.0: return 1
        return 0
    fact['Is_Passed'] = fact['Grade'].apply(check_pass)
    
    units_map = raw_course[['course_id', 'units']].set_index('course_id')['units']
    tx_df['course_units'] = tx_df['course_id'].map(units_map).fillna(0.0)
    
    fact['Units_Earned'] = fact.apply(lambda row: tx_df.loc[row.name, 'course_units'] if row['Is_Passed'] == 1 else 0.0, axis=1)
    fact['Remarks'] = tx_df['remarks'].str.title().str.strip().fillna('Unknown')

    save_to_staging(fact, "fact_student_performance")
    

# TRANSFORM: FACT_FACULTY_STATS
def transform_fact_faculty_stats():
    print("Transforming Fact_Faculty_Stats...", end=" ")
    
    emp_df = get_data("raw_hr_employees")
    unit_df = get_data("raw_hr_units")
    sub_status_df = get_data("raw_hr_sub_statuses")
    dim_org = get_data("dim_organization")
    
    merged = pd.merge(emp_df, unit_df, left_on='emp_primary_home_unit_id', right_on='unit_id', how='left')
    merged = pd.merge(merged, sub_status_df, on='emp_sub_status_id', how='left')

    fact = pd.DataFrame()
    fact['Employee_No'] = merged['emp_number']
    
    merged['unit_code_clean'] = merged['unit_code'].str.upper().str.strip()
    tmp_org = pd.merge(merged, dim_org[['Unit_Code', 'Org_Key']], left_on='unit_code_clean', right_on='Unit_Code', how='left')
    fact['Org_Key'] = tmp_org['Org_Key'].fillna(-1).astype(int)
    
    current_date_key = int(datetime.datetime.now().strftime('%Y%m%d'))
    fact['Snapshot_Date_Key'] = current_date_key

    fact['Headcount'] = 1
    
    def calc_fte(sub_status):
        if str(sub_status).upper() == 'FULL TIME': return 1.0
        elif str(sub_status).upper() == 'PART TIME': return 0.5
        else: return 0.0
    fact['FTE_Value'] = merged['sub_status_name'].apply(calc_fte)

    save_to_staging(fact, "fact_faculty_stats")


# TRANSFORM: FACT_RESEARCH_OUTPUT
def transform_fact_research_output():
    print("Transforming Fact_Research_Output...", end=" ")
    
    links_df = get_data("raw_pub_links")
    pubs_df  = get_data("raw_pub_publications")
    auth_df  = get_data("raw_pub_authors")
    pers_df  = get_data("raw_pub_persons")
    emp_df   = get_data("raw_hr_employees")
    unit_df  = get_data("raw_hr_units")
    src_df   = get_data("raw_pub_sources")
    
    dim_org  = get_data("dim_organization")
    dim_fac  = get_data("dim_faculty")
    dim_meta = get_data("dim_pub_metadata")
    
    merged = pd.merge(links_df, pubs_df, left_on='publication_id', right_on='id', how='left', suffixes=('', '_pub'))
    merged = pd.merge(merged, auth_df, left_on='author_id', right_on='id', how='left', suffixes=('', '_auth'))
    merged = pd.merge(merged, pers_df, left_on='person_id', right_on='id', how='left', suffixes=('', '_pers'))
    
    fact = pd.DataFrame()
    
    merged['email_clean'] = merged['email'].str.lower().str.strip()
    dim_fac['email_clean'] = dim_fac['Email_Address'].str.lower().str.strip()
    
    tmp_fac = pd.merge(merged, dim_fac[['email_clean', 'Employee_No']], 
                       left_on='email_clean', right_on='email_clean', how='left')
    fact['Employee_No'] = tmp_fac['Employee_No']
    
    merged['title_clean'] = merged['title'].str.strip()
    tmp_meta = pd.merge(merged, dim_meta[['Publication_Title', 'Pub_Meta_Key']], 
                        left_on='title_clean', right_on='Publication_Title', how='left')
    fact['Pub_Meta_Key'] = tmp_meta['Pub_Meta_Key'].fillna(-1).astype(int)
    
    def make_date_key(row):
        y = int(row['year_published']) if pd.notna(row['year_published']) else 1900
        m = int(row['month_published']) if pd.notna(row['month_published']) else 1
        d = int(row['day_published']) if pd.notna(row['day_published']) else 1
        return int(f"{y:04d}{m:02d}{d:02d}")
    fact['Date_Published_Key'] = merged.apply(make_date_key, axis=1)
    
    emp_unit = pd.merge(emp_df, unit_df, left_on='emp_primary_home_unit_id', right_on='unit_id')
    emp_unit['unit_code'] = emp_unit['unit_code'].str.upper().str.strip()
    
    fac_org_map = pd.merge(dim_fac, emp_unit[['emp_number', 'unit_code']], 
                           left_on='Employee_No', right_on='emp_number', how='left')
    fac_org_map = pd.merge(fac_org_map, dim_org[['Unit_Code', 'Org_Key']], 
                           left_on='unit_code', right_on='Unit_Code', how='left')
    
    tmp_org = pd.merge(fact, fac_org_map[['Employee_No', 'Org_Key']], on='Employee_No', how='left')
    fact['Org_Key'] = tmp_org['Org_Key'].fillna(-1).astype(int)

    fact['Publication_Count'] = 1
    fact['Citation_Count'] = None
    
    merged_imp = pd.merge(merged, src_df[['id', 'h_index']], 
                          left_on='source_id', right_on='id', how='left', suffixes=('', '_src'))
    
    if 'h_index_src' in merged_imp.columns:
        col_name = 'h_index_src'
    else:
        col_name = 'h_index_y'
        
    fact['Impact_Factor'] = pd.to_numeric(merged_imp[col_name], errors='coerce').fillna(0.0)

    save_to_staging(fact, "fact_research_output")

# TRANSFORM: FACT_PERSON_SUMMARY (One-Page Profile)
def transform_fact_person_summary():
    print("Transforming Fact_Person_Summary...", end=" ")
    
    # Load DataFrames
    dim_fac = get_data("dim_faculty")
    dim_stud = get_data("dim_student")
    dim_date = get_data("dim_date")  
    fact_res = get_data("fact_research_output")
    fact_perf = get_data("fact_student_performance")
    fact_stats = get_data("fact_faculty_stats") 
    
    # Prepare Base: Active Faculty
    base_df = dim_fac.copy()
    if 'H_Index' not in base_df.columns:
        base_df['H_Index'] = 0 
    base_df = base_df[['Employee_No', 'Student_Number', 'H_Index', 'Total_Citations']].drop_duplicates()

    # RESEARCH STATS
    res_merged = pd.merge(fact_res, dim_date[['Date_Key', 'Year']], 
                          left_on='Date_Published_Key', right_on='Date_Key', how='left')
    
    res_stats = res_merged.groupby('Employee_No').agg(
        total_publications=('Publication_Count', 'sum'),
        total_citations=('Citation_Count', 'sum'),
        avg_impact_factor=('Impact_Factor', 'mean'), 
        latest_pub_year=('Year', 'max')
    ).reset_index()
    
    final_df = pd.merge(base_df, res_stats, on='Employee_No', how='left')

    # TEACHING STATS 
    teach_stats = fact_perf.groupby('Employee_No').agg(
        total_students_taught=('Student_Number', 'nunique'),
        avg_grade_given=('Grade', 'mean'),
        overall_pass_rate=('Is_Passed', 'mean')
    ).reset_index()
    
    teach_stats['overall_pass_rate'] = (teach_stats['overall_pass_rate'] * 100).round(2)
    final_df = pd.merge(final_df, teach_stats, on='Employee_No', how='left')

    # STUDENT HISTORY
    stud_stats = fact_perf.groupby('Student_Number').agg(
        student_gwa=('Grade', 'mean'),
        last_date_key=('Date_Key', 'max')
    ).reset_index()
    
    stud_stats = pd.merge(stud_stats, dim_date[['Date_Key', 'Year']], 
                          left_on='last_date_key', right_on='Date_Key', how='left')
    stud_stats.rename(columns={'Year': 'year_last_enrolled'}, inplace=True)
    
    final_df = pd.merge(final_df, stud_stats[['Student_Number', 'student_gwa', 'year_last_enrolled']], 
                        on='Student_Number', how='left')


    # ORG KEY
    current_org_map = fact_stats.sort_values('Snapshot_Date_Key', ascending=False)
    current_org_map = current_org_map.drop_duplicates(subset=['Employee_No'], keep='first')
    
    final_df = pd.merge(final_df, current_org_map[['Employee_No', 'Org_Key']], on='Employee_No', how='left')
    final_df['Org_Key'] = final_df['Org_Key'].fillna(-1).astype(int)

    # FINAL MAPPING
    final_df['total_publications'] = final_df['total_publications'].fillna(0).astype(int)
    final_df['total_citations'] = final_df['total_citations'].fillna(0).astype(int)
    final_df['avg_impact_factor'] = final_df['avg_impact_factor'].round(3)
    final_df['latest_pub_year'] = final_df['latest_pub_year'].fillna(0).astype(int)
    
    final_df['total_students_taught'] = final_df['total_students_taught'].fillna(0).astype(int)
    final_df['avg_grade_given'] = final_df['avg_grade_given'].round(2)
    final_df['overall_pass_rate'] = final_df['overall_pass_rate'].round(2)
    
    final_df['was_former_student'] = final_df['year_last_enrolled'].notna()
    final_df['student_gwa'] = final_df['student_gwa'].round(2)
    final_df['year_last_enrolled'] = final_df['year_last_enrolled'].fillna(0).astype(int)
    
    # OUTPUT DATAFRAME
    output_df = pd.DataFrame()
    output_df['Employee_No'] = final_df['Employee_No'] 
    output_df['Student_Number'] = final_df['Student_Number'].fillna(0).astype(int) 
    output_df['org_key'] = final_df['Org_Key']
    output_df['total_publications'] = final_df['total_publications']
    output_df['total_citations'] = final_df['Total_Citations'].fillna(0).astype(int)
    output_df['h_index'] = final_df['H_Index'].fillna(0).astype(int)
    output_df['latest_pub_year'] = final_df['latest_pub_year']
    output_df['avg_impact_factor'] = final_df['avg_impact_factor']
    output_df['total_students_taught'] = final_df['total_students_taught']
    output_df['avg_grade_given'] = final_df['avg_grade_given']
    output_df['overall_pass_rate'] = final_df['overall_pass_rate']
    output_df['was_former_student'] = final_df['was_former_student']
    output_df['student_gwa'] = final_df['student_gwa']
    output_df['year_last_enrolled'] = final_df['year_last_enrolled']
    
    save_to_staging(output_df, "fact_person_summary")


# EXECUTION BLOCK
if __name__ == "__main__":
    print("--- STARTING TRANSFORMATION PHASE ---")
    
    transform_dim_student()
    transform_dim_faculty()
    transform_dim_organization()
    transform_dim_course()
    transform_dim_program()
    transform_dim_pub_metadata()
    generate_dim_date()

    transform_fact_student_perf()
    transform_fact_faculty_stats()
    transform_fact_research_output()
    transform_fact_person_summary()

    print("--- TRANSFORMATION PHASE COMPLETE ---")