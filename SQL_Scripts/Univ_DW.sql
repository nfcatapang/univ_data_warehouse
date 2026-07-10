-- UNIV_DW

-- 1. DROP EXISTING TABLES
DROP TABLE IF EXISTS fact_person_summary CASCADE;
DROP TABLE IF EXISTS fact_student_performance CASCADE;
DROP TABLE IF EXISTS fact_faculty_stats CASCADE;
DROP TABLE IF EXISTS fact_research_output CASCADE;
DROP TABLE IF EXISTS dim_faculty CASCADE;
DROP TABLE IF EXISTS dim_student CASCADE;
DROP TABLE IF EXISTS dim_course CASCADE;
DROP TABLE IF EXISTS dim_program CASCADE;
DROP TABLE IF EXISTS dim_organization CASCADE;
DROP TABLE IF EXISTS dim_publication_metadata CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;



-- 2. CREATE DIMENSION TABLES

-- A. DIM_DATE (Standard Calendar Dimension)
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,         -- YYYYMMDD
    full_date DATE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    day INT,
    day_name VARCHAR(20),
    academic_year VARCHAR(20),        -- e.g., "2023-2024"
    semester_name VARCHAR(20)         -- e.g., "1st Semester"
);

-- B. DIM_ORGANIZATION (Departments & Colleges)
CREATE TABLE dim_organization (
    org_key INT PRIMARY KEY,         
    unit_code VARCHAR(20),            
    unit_name VARCHAR(100),
    parent_unit_code VARCHAR(20),    
    parent_unit_name VARCHAR(100)
);

-- C. DIM_PROGRAM (Context for Grades)
CREATE TABLE dim_program (
    program_key SERIAL PRIMARY KEY,
    program_code VARCHAR(50),         -- e.g., "BS MATH"
    program_title VARCHAR(150),       -- e.g., "Bachelor of Science in Mathematics"
    college_group VARCHAR(100)        -- e.g., "College of Science"
);

-- D. DIM_COURSE (Catalog)
CREATE TABLE dim_course (
    course_key SERIAL PRIMARY KEY,
    course_code VARCHAR(20),     
    course_title VARCHAR(100),
    units INT
);

-- E. DIM_STUDENT (Profile - SCD Type 2)
CREATE TABLE dim_student (
    student_key SERIAL PRIMARY KEY,
    student_number BIGINT,
    full_name VARCHAR(100),
    email_primary VARCHAR(100),
    program_name VARCHAR(100),
    sex_assigned VARCHAR(20),
    region VARCHAR(50),
    province VARCHAR(50),

	-- SCD Type 2 Columns
    row_effective_date DATE,
    row_expiration_date DATE,
    current_row_indicator BOOLEAN
);

-- F. DIM_FACULTY (Profile - SCD Type 2)
CREATE TABLE dim_faculty (
    faculty_key SERIAL PRIMARY KEY,
    employee_no VARCHAR(20),
    student_number BIGINT DEFAULT 0,
    full_name VARCHAR(100),
    email_address VARCHAR(100),
    designation VARCHAR(100),
    employment_status VARCHAR(50),    -- e.g., Permanent, Temporary
    is_active BOOLEAN,
    h_index INT,
    total_citations INT,
    -- SCD Type 2 Columns
    row_effective_date DATE,
    row_expiration_date DATE,
    current_row_indicator BOOLEAN
);

-- G. DIM_PUBLICATION_METADATA (Research Details)
CREATE TABLE dim_publication_metadata (
    pub_meta_key int PRIMARY KEY,
    publication_title VARCHAR(255),
    publication_type VARCHAR(50),     -- Journal, Conference
    publisher VARCHAR(255),
	indexing_type varchar(50)
);



-- 3. CREATE FACT TABLES

-- H. FACT_FACULTY_STATS (Periodic Snapshot)
-- Tracks headcount and active status at specific points in time.
CREATE TABLE fact_faculty_stats (
    Fact_ID SERIAL PRIMARY KEY,
    snapshot_date_key INT REFERENCES dim_date(date_key),
    org_key INT REFERENCES dim_organization(org_key),
    faculty_key INT REFERENCES dim_faculty(faculty_key),
    headcount INT,
    fte_value DECIMAL(3,2)      
);

-- I. FACT_RESEARCH_OUTPUT (Transaction Fact)
-- Tracks publication metrics per author per paper.
CREATE TABLE fact_research_output (
    Fact_ID SERIAL PRIMARY KEY,
    date_published_key INT REFERENCES dim_date(date_key),
    faculty_key INT REFERENCES dim_faculty(faculty_key),
    pub_meta_key INT REFERENCES dim_publication_metadata(pub_meta_key),
    org_key INT REFERENCES dim_organization(org_key),
    publication_count INT,
    citation_count INT,
    impact_factor DECIMAL(10,2)
);

-- J. FACT_STUDENT_PERFORMANCE (Transaction Fact)
-- Tracks grades.
CREATE TABLE fact_student_performance (
    Fact_ID SERIAL PRIMARY KEY,
    date_key INT REFERENCES dim_date(date_key),
    student_key INT REFERENCES dim_student(student_key),
    faculty_key INT REFERENCES dim_faculty(faculty_key),
    course_key INT REFERENCES dim_course(course_key),
    program_key INT REFERENCES dim_program(program_key),
    org_key INT REFERENCES dim_organization(org_key),
    grade DECIMAL(4,2),
    is_passed INT,
    units_earned DECIMAL(3,1),        
    remarks VARCHAR(50)
);

-- K. FACT_PERSON_SUMMARY (Snapshot)
CREATE TABLE fact_person_summary (
    summary_id SERIAL PRIMARY KEY,
    
    -- FOREIGN KEYS
    faculty_key INT REFERENCES dim_faculty(faculty_key),
    student_key INT REFERENCES dim_student(student_key),
    org_key INT REFERENCES dim_organization(org_key),
    
    -- RESEARCH STATS
    total_publications INT DEFAULT 0,
    total_citations INT DEFAULT 0,
    h_index INT DEFAULT 0,
    latest_pub_year INT,
    avg_impact_factor DECIMAL(10,2),

    -- TEACHING STATS (Faculty View)
    total_students_taught INT DEFAULT 0,
    avg_grade_given DECIMAL(4,2),
    overall_pass_rate DECIMAL(5,2),
    
    -- STUDENT HISTORY (Student View)
    was_former_student BOOLEAN,
    student_gwa DECIMAL(4,2),
    year_last_enrolled INT,
    
    last_updated_date DATE DEFAULT CURRENT_DATE
);