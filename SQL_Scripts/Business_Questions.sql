-- BUSINESS QUESTION 1: Enrollment by Region & Top Programs

SELECT 
    d.Region,
    d.Program_Name,
    COUNT(f.Fact_ID) AS Total_Enrollments
FROM 
    fact_student_performance f
JOIN 
    dim_student d ON f.Student_Key = d.Student_Key
WHERE 
    d.Region IS NOT NULL AND d.Region != 'Unknown'
GROUP BY 
    d.Region, 
    d.Program_Name
ORDER BY 
    d.Region ASC,             
    Total_Enrollments DESC;



-- BUSINESS QUESTION 2: Grade Distribution (Course & Instructor)

SELECT 
    dd.Academic_Year,
    dc.Course_Code,
    dc.Course_Title,
    df.Full_Name AS Instructor,
    
    -- Student Count
    COUNT(f.Fact_ID) AS Total_Students,
    
    -- Average Grade
    ROUND(AVG(f.Grade), 2) AS Average_Grade,
    
    -- Passing Rate
    ROUND(
        (SUM(f.Is_Passed)::NUMERIC / COUNT(f.Fact_ID)) * 100, 
    2) AS Pass_Rate

FROM 
    fact_student_performance f
JOIN 
    dim_date dd ON f.Date_Key = dd.Date_Key
JOIN 
    dim_course dc ON f.Course_Key = dc.Course_Key
JOIN 
    dim_faculty df ON f.Faculty_Key = df.Faculty_Key

WHERE 
    f.Grade IS NOT NULL             
    AND df.Employee_No != 'UNK'    
    AND dd.Academic_Year = '2024-2025'

GROUP BY 
    dd.Academic_Year,
    dc.Course_Code,
    dc.Course_Title,
    df.Full_Name

ORDER BY 
    dc.Course_Code ASC,
    Average_Grade ASC;



-- BUSINESS QUESTION 3: Faculty Ranks & Employment Distribution

SELECT 
    org.Parent_Unit_Name AS College,
    org.Unit_Name AS Department,
    fac.Designation AS Rank,
    fac.Employment_Status AS Employment_Type,
    
    -- Headcount
    COUNT(f.Fact_ID) AS Faculty_Count

FROM 
    fact_faculty_stats f
JOIN 
    dim_faculty fac ON f.Faculty_Key = fac.Faculty_Key
JOIN 
    dim_organization org ON f.Org_Key = org.Org_Key

WHERE 
    -- Latest snapshot
    f.Snapshot_Date_Key = (SELECT MAX(Snapshot_Date_Key) FROM fact_faculty_stats)
    
    -- Remove the "Unknown"
    AND fac.Employee_No != 'UNK'

GROUP BY 
    org.Parent_Unit_Name,
    org.Unit_Name,
    fac.Designation,
    fac.Employment_Status

ORDER BY 
    org.Parent_Unit_Name, 
    org.Unit_Name,
    Faculty_Count DESC;



-- BUSINESS QUESTION 4: Active Faculty Count by Dept/College

SELECT 
    o.parent_unit_name AS "College",
    o.unit_name AS "Department",
    SUM(f.headcount) AS "Active Faculty Count"
FROM fact_faculty_stats f
JOIN dim_organization o ON f.org_key = o.org_key
JOIN dim_faculty df ON f.faculty_key = df.faculty_key
WHERE 
    -- Latest snapshot
    f.snapshot_date_key = (SELECT MAX(snapshot_date_key) FROM fact_faculty_stats)
    -- Active status only
    AND df.is_active = TRUE
GROUP BY 
    o.parent_unit_name, 
    o.unit_name
ORDER BY 
    "Active Faculty Count" DESC;



-- BUSINESS QUESTION 5: Leaderboard (Promotion Worksheet)

WITH Research_Stats AS (
    SELECT 
        r.faculty_key,
        COUNT(*) AS recent_pubs
    FROM fact_research_output r
    JOIN dim_date d ON r.date_published_key = d.date_key
    WHERE d.year >= 2023
    GROUP BY r.faculty_key
),
Teaching_Stats AS (
    SELECT 
        p.faculty_key,
        ROUND(AVG(p.grade), 2) AS avg_grade,
        ROUND(AVG(p.is_passed) * 100, 1) AS pass_rate
    FROM fact_student_performance p
    GROUP BY p.faculty_key
)
SELECT 
    f.full_name,
    f.designation,
    COALESCE(rs.recent_pubs, 0) AS recent_pubs,
    f.h_index,
    f.total_citations,
    COALESCE(ts.avg_grade, 0.00) AS avg_grade,
    COALESCE(ts.pass_rate, 0.0) AS pass_rate
FROM dim_faculty f
JOIN Research_Stats rs ON f.faculty_key = rs.faculty_key
LEFT JOIN Teaching_Stats ts ON f.faculty_key = ts.faculty_key
WHERE f.current_row_indicator = TRUE and f.faculty_key != -1
ORDER BY 
    recent_pubs DESC, 
	f.h_index DESC, 
	f.total_citations DESC, 
	avg_grade, 
	pass_rate DESC
LIMIT 10;