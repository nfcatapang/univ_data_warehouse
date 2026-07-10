import dash
from dash import dcc, html, dash_table, Input, Output, State
import pandas as pd
from sqlalchemy import create_engine, text
import plotly.express as px

# 1. CONFIGURATION
DB_CONN_STR = 'postgresql://postgres:admin@localhost:5432/Univ_DW'
dw_engine = create_engine(DB_CONN_STR)



# ----------------------------------------------------------------------------
# 2. SQL QUERIES
# A. ONE-PAGE PROFILE
# Person Summary
SQL_PERSON_SUMMARY = """
SELECT 
    f.full_name,
    f.designation,
    f.email_address,
    o.unit_name AS department,
    
    s.total_publications,
    s.total_citations,
    s.h_index,
    s.avg_impact_factor,
    
    s.total_students_taught,
    s.avg_grade_given,
    s.overall_pass_rate,
    
    s.was_former_student,
    s.student_gwa,
    s.year_last_enrolled
    
FROM fact_person_summary s
JOIN dim_faculty f ON s.faculty_key = f.faculty_key
JOIN dim_organization o ON s.org_key = o.org_key
WHERE f.employee_no = '{emp_id}'
"""

# Latest 3 Publications
SQL_LATEST_PUBS = """
SELECT 
    m.publication_title,
    d.year,
    m.publisher
FROM fact_research_output r
JOIN dim_publication_metadata m ON r.pub_meta_key = m.pub_meta_key
JOIN dim_date d ON r.date_published_key = d.date_key
JOIN dim_faculty f ON r.faculty_key = f.faculty_key
WHERE f.employee_no = '{emp_id}'
ORDER BY r.date_published_key DESC
LIMIT 3;
"""

# Latest 3 Courses Taught
SQL_LATEST_COURSES = """
SELECT 
    c.course_code,
    c.course_title,
    d.academic_year,
    d.semester_name
FROM fact_student_performance p
JOIN dim_course c ON p.course_key = c.course_key
JOIN dim_date d ON p.date_key = d.date_key
JOIN dim_faculty f ON p.faculty_key = f.faculty_key
WHERE f.employee_no = '{emp_id}'
GROUP BY 
    c.course_code, 
    c.course_title, 
    d.academic_year, 
    d.semester_name
ORDER BY MAX(d.date_key) DESC
LIMIT 3;
"""

# B. DASHBOARD QUERIES (BQ1 - BQ5)
SQL_BQ1 = """
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
"""

SQL_BQ2 = """
SELECT 
    dd.Academic_Year,
    dc.Course_Code,
    dc.Course_Title,
    df.Full_Name AS Instructor,
    
    -- Metric 1: Student Count
    COUNT(f.Fact_ID) AS Total_Students,
    
    -- Metric 2: Average Grade
    ROUND(AVG(f.Grade), 2) AS Average_Grade,
    
    -- Metric 3: Passing Rate
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
"""

SQL_BQ3 = """
SELECT 
    org.Parent_Unit_Name AS College,
    org.Unit_Code AS Department,
    fac.Designation AS Rank,
    fac.Employment_Status AS Employment_Type,
    
    -- Metric: Headcount
    COUNT(f.Fact_ID) AS Faculty_Count

FROM 
    fact_faculty_stats f
JOIN 
    dim_faculty fac ON f.Faculty_Key = fac.Faculty_Key
JOIN 
    dim_organization org ON f.Org_Key = org.Org_Key

WHERE 
    -- Get the latest snapshot
    f.Snapshot_Date_Key = (SELECT MAX(Snapshot_Date_Key) FROM fact_faculty_stats)
    
    -- Remove the "Unknown"
    AND fac.Employee_No != 'UNK'

GROUP BY 
    org.Parent_Unit_Name,
    org.Unit_Code,
    fac.Designation,
    fac.Employment_Status

ORDER BY 
    org.Parent_Unit_Name, 
    org.Unit_Code,
    Faculty_Count DESC;
"""

SQL_BQ4 = """
SELECT 
    o.parent_unit_name AS "College",
    o.unit_name AS "Department",
    SUM(f.headcount) AS "Active Faculty Count"
FROM fact_faculty_stats f
JOIN dim_organization o ON f.org_key = o.org_key
JOIN dim_faculty df ON f.faculty_key = df.faculty_key
WHERE 
    -- 1. Most recent snapshot (Current State)
    f.snapshot_date_key = (SELECT MAX(snapshot_date_key) FROM fact_faculty_stats)
    -- 2. Active status only
    AND df.is_active = TRUE
GROUP BY 
    o.parent_unit_name, 
    o.unit_name
ORDER BY 
    "Active Faculty Count" DESC;
"""

# FACULTY LEADERBOARD
SQL_BQ5 = """
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
ORDER BY recent_pubs DESC, f.h_index DESC, f.total_citations DESC, avg_grade, pass_rate DESC
LIMIT 10;
"""

# ----------------------------------------------------------------------------



# 3. PRE-LOAD DASHBOARD DATA
try:
    with dw_engine.connect() as conn:
        df_bq1 = pd.read_sql(text(SQL_BQ1), conn)
        df_bq2 = pd.read_sql(text(SQL_BQ2), conn)
        df_bq3 = pd.read_sql(text(SQL_BQ3), conn)
        df_bq4 = pd.read_sql(text(SQL_BQ4), conn)
        df_bq5 = pd.read_sql(text(SQL_BQ5), conn)
    
    fig_bq1 = px.bar(
        df_bq1, 
        x='region', 
        y='total_enrollments', 
        color='program_name',
        title='Student Enrollments by Region & Program', 
        labels={
            'region': 'Region', 
            'total_enrollments': 'Student Count',
            'program_name': 'Degree Program'
            },
        barmode='stack')
    fig_bq1.update_layout(legend_title_text='Programs')

    fig_bq2 = px.bar(
    df_bq2, 
    x='course_code', 
    y='average_grade', 
    color='instructor', 
    barmode='group', 
    title='Instructor Grading Analysis (A.Y. 2024-2025)', 
    
    hover_data={
        'average_grade': ':.2f',
        'total_students': True,
        'pass_rate': ':.1f',
        'course_code': False
    },
    
    labels={
        'course_code': 'Course', 
        'average_grade': 'Avg Grade',
        'total_students': 'Class Size',
        'pass_rate': 'Pass Rate (%)'
    })
    fig_bq2.update_yaxes(range=[3.0, 1.0])

    fig_bq3 = px.bar(
    df_bq3, 
    x='department', 
    y='faculty_count', 
    color='rank', 
    pattern_shape='employment_type',
    facet_col='college', 
    facet_col_wrap=2,
    
    title='Faculty Workforce Distribution by College & Dept',
    labels={
        'department': 'Department', 
        'faculty_count': 'Headcount',
        'college': 'Unit'
    },
    height=800
)
    fig_bq3.update_xaxes(matches=None)
    fig_bq3.for_each_xaxis(lambda axis: axis.update(showticklabels=True))

    fig_bq4 = px.bar(
    df_bq4, 
    x='Active Faculty Count', 
    y='Department', 
    color='College',
    orientation='h', 
    title='Active Faculty Workforce Size by Department', 
    text='Active Faculty Count',
    labels={
        'Active Faculty Count': 'Headcount', 
        'Department': 'Dept',
        'College': 'College'
    },
    height=600 
)
    fig_bq4.update_traces(textposition='outside')
    fig_bq4.update_layout(yaxis=dict(autorange="reversed"))

except Exception as e:
    fig_bq1 = fig_bq2 = fig_bq3 = fig_bq4 = px.bar(title=f"Error: {e}")
    df_bq5 = pd.DataFrame()


# 4. APP LAYOUT
app = dash.Dash(__name__, title="University Analytics")

app.layout = html.Div(style={'fontFamily': 'Arial, sans-serif', 'maxWidth': '1200px', 'margin': 'auto', 'padding': '20px'}, children=[
    
    # Global Header
    html.Div([
        html.H1("University Analytics Portal", style={'textAlign': 'center', 'color': '#2c3e50'}),
        html.P("Data Warehouse Capstone Project", style={'textAlign': 'center', 'color': '#7f8c8d'}),
        html.Hr()
    ]),

    # TABS INTERFACE
    dcc.Tabs([
        
        # TAB 1: One-Page Profile
        dcc.Tab(label='Faculty One-Page Profile', children=[
            html.Div(style={'padding': '20px'}, children=[
                html.Div(style={'display': 'flex', 'justifyContent': 'center', 'marginBottom': '30px'}, children=[
                    dcc.Input(id='input-emp-id', type='text', placeholder='Enter Employee No (e.g., 1001, 50001)', value='1001', style={'padding': '10px', 'width': '300px', 'fontSize': '16px'}),
                    html.Button('Load Profile', id='btn-search', n_clicks=0, style={'padding': '10px 20px', 'fontSize': '16px', 'backgroundColor': '#2980b9', 'color': 'white', 'border': 'none', 'cursor': 'pointer', 'marginLeft': '10px'})
                ]),
                html.Div(id='profile-content')
            ])
        ]),

        # TAB 2: DEAN'S DASHBOARD (business questions)
        dcc.Tab(label="Dean's Dashboard", children=[
            html.Div(style={'padding': '20px'}, children=[
                html.H2("Strategic Overview", style={'color': '#2c3e50', 'marginBottom': '20px'}),
                
                # Row 1
                html.Div(style={'backgroundColor': 'white', 'padding': '15px', 'borderRadius': '5px', 'boxShadow': '0 2px 5px rgba(0,0,0,0.1)', 'marginBottom': '30px'}, children=[
                    html.H3("1. Where do our students come from?", style={'color': '#34495e'}),
                    dcc.Graph(figure=fig_bq1)
                ]),

                # Row 2
                html.Div(style={'backgroundColor': 'white', 'padding': '15px', 'borderRadius': '5px', 'boxShadow': '0 2px 5px rgba(0,0,0,0.1)', 'marginBottom': '30px'}, children=[
                    html.H3("2. Course Performance Analysis", style={'color': '#34495e'}),
                    dcc.Graph(figure=fig_bq2)
                ]),

                # Row 3
                html.Div(style={'backgroundColor': 'white', 'padding': '15px', 'borderRadius': '5px', 'boxShadow': '0 2px 5px rgba(0,0,0,0.1)', 'marginBottom': '30px'}, children=[
                    html.H3("3. Faculty Composition", style={'color': '#34495e'}),
                    dcc.Graph(figure=fig_bq3, style={'height': '800px'})  
                ]),

                # Row 4
                html.Div(style={'backgroundColor': 'white', 'padding': '15px', 'borderRadius': '5px', 'boxShadow': '0 2px 5px rgba(0,0,0,0.1)', 'marginBottom': '30px'}, children=[
                    html.H3("4. Active Workforce Size", style={'color': '#34495e'}),
                    dcc.Graph(figure=fig_bq4)
                ]),

                # Row 5
                html.Div(style={'backgroundColor': 'white', 'padding': '15px', 'borderRadius': '5px', 'boxShadow': '0 2px 5px rgba(0,0,0,0.1)'}, children=[
                    html.H3("5. Holistic Faculty Performance (For Promotion Review)", style={'color': '#34495e'}),
                    html.P("Top Researchers (2023+) with Teaching Metrics.", style={'fontStyle': 'italic', 'color': '#7f8c8d'}),
                    dash_table.DataTable(
                        data=df_bq5.to_dict('records'),
                        columns=[
                            {'name': 'Faculty Name', 'id': 'full_name'},
                            {'name': 'Rank', 'id': 'designation'},
                            {'name': 'Recent Pubs', 'id': 'recent_pubs'},
                            {'name': 'H-Index', 'id': 'h_index'},
                            {'name': 'Citations', 'id': 'total_citations'},
                            {'name': 'Avg GWA of Students', 'id': 'avg_grade'},
                            {'name': 'Pass Rate of Students (%)', 'id': 'pass_rate'} 
                        ],
                        style_header={'backgroundColor': '#2c3e50', 'color': 'white', 'fontWeight': 'bold'},
                        style_cell={'textAlign': 'left', 'padding': '10px'},
                        style_data_conditional=[
                            {'if': {'row_index': 0}, 'backgroundColor': '#f1c40f', 'fontWeight': 'bold'},
                            {'if': {'row_index': 1}, 'backgroundColor': '#bdc3c7'},
                            {'if': {'row_index': 2}, 'backgroundColor': '#e67e22', 'color': 'white'},
                            # Highlight High Pass Rates in Green
                            {
                                'if': {'filter_query': '{pass_rate} >= 90', 'column_id': 'pass_rate'},
                                'color': '#27ae60', 'fontWeight': 'bold'
                            }
                        ]
                    )
                ])
            ])
        ])
    ])
])

# 5. CALLBACKS
@app.callback(
    Output('profile-content', 'children'),
    Input('btn-search', 'n_clicks'),
    State('input-emp-id', 'value')
)
def update_profile(n_clicks, emp_id):
    if not emp_id:
        return html.Div("Please enter an Employee ID.", style={'color': 'red'})

    try:
        # Run Queries
        with dw_engine.connect() as conn:
            # A. Main Summary
            df_summary = pd.read_sql(text(SQL_PERSON_SUMMARY.format(emp_id=emp_id)), conn)
            
            # B. Latest Pubs
            df_pubs = pd.read_sql(text(SQL_LATEST_PUBS.format(emp_id=emp_id)), conn)
            
            # C. Latest Courses
            df_courses = pd.read_sql(text(SQL_LATEST_COURSES.format(emp_id=emp_id)), conn)

        if df_summary.empty:
            return html.Div(f"No summary found for Employee ID: {emp_id}", style={'color': 'red'})

        # Extract Summary Row
        row = df_summary.iloc[0]

        # Build Components
        # HEADER & SCORECARDS
        header = html.Div(style={'marginBottom': '20px', 'borderBottom': '1px solid #ddd', 'paddingBottom': '10px'}, children=[
            html.H2(f"{row['full_name']}", style={'color': '#2c3e50', 'marginBottom': '5px'}),
            html.H4(f"{row['designation']} | {row['department']}", style={'color': '#7f8c8d', 'marginTop': '0'}),
            html.P(f"Email: {row['email_address']}", style={'fontStyle': 'italic'})
        ])

        research_card = html.Div(style={'flex': '1', 'backgroundColor': '#e8f6f3', 'padding': '15px', 'borderRadius': '5px', 'marginRight': '10px'}, children=[
            html.H3("Research", style={'color': '#16a085', 'borderBottom': '2px solid #16a085'}),
            html.P(f"Total Pubs: {row['total_publications']}"),
            html.P(f"Citations: {row['total_citations']}"),
            html.P(f"H-Index: {row['h_index']}"),
            html.P(f"Avg Impact: {row['avg_impact_factor']}")
        ])

        teaching_card = html.Div(style={'flex': '1', 'backgroundColor': '#fef9e7', 'padding': '15px', 'borderRadius': '5px', 'marginRight': '10px'}, children=[
            html.H3("Teaching", style={'color': '#f1c40f', 'borderBottom': '2px solid #f1c40f'}),
            html.P(f"Students Taught: {row['total_students_taught']}"),
            html.P(f"Pass Rate: {row['overall_pass_rate']}%"),
            html.P(f"Avg Grade Given: {row['avg_grade_given']}")
        ])

        if row['was_former_student']:
            alumni_style = {'flex': '1', 'backgroundColor': '#fadbd8', 'padding': '15px', 'borderRadius': '5px'}
            alumni_content = [
                html.H3("Alumni Status", style={'color': '#c0392b', 'borderBottom': '2px solid #c0392b'}),
                html.P("Former Student in UPD"),
                html.P(f"Student GWA: {row['student_gwa']}"),
                html.P(f"Last Enrolled: {row['year_last_enrolled']}")
            ]
        else:
            alumni_style = {'flex': '1', 'backgroundColor': '#f2f3f4', 'padding': '15px', 'borderRadius': '5px', 'opacity': '0.6'}
            alumni_content = [html.H3("Alumni Status", style={'color': '#7f8c8d'}), html.P("Not a former student")]
        
        alumni_card = html.Div(style=alumni_style, children=alumni_content)
        
        # Helper to generate simple HTML table from DF
        def generate_mini_table(df, title, columns):
            if df.empty:
                return html.Div([html.H4(title, style={'color': '#34495e'}), html.P("No records found.", style={'fontStyle':'italic', 'color':'#95a5a6'})], style={'flex': '1', 'padding': '10px'})
            
            return html.Div(style={'flex': '1', 'padding': '10px'}, children=[
                html.H4(title, style={'color': '#34495e', 'borderBottom': '1px solid #bdc3c7', 'paddingBottom': '5px'}),
                dash_table.DataTable(
                    data=df.to_dict('records'),
                    columns=[{'name': i, 'id': i} for i in columns],
                    style_cell={'textAlign': 'left', 'fontSize': '14px', 'padding': '5px'},
                    style_header={'backgroundColor': '#ecf0f1', 'fontWeight': 'bold'},
                    style_as_list_view=True
                )
            ])

        # Prepare DataFrames for display
        pub_display = df_pubs[['publication_title', 'year', 'publisher']].rename(columns={'publication_title': 'Title', 'year': 'Year', 'publisher': 'Venue'})
        course_display = df_courses[['course_code', 'academic_year', 'semester_name']].rename(columns={'course_code': 'Course', 'academic_year': 'A.Y.', 'semester_name': 'Sem'})

        details_section = html.Div(style={'display': 'flex', 'marginTop': '30px', 'backgroundColor': 'white', 'padding': '15px', 'borderRadius': '5px', 'boxShadow': '0 2px 5px rgba(0,0,0,0.1)'}, children=[
            generate_mini_table(pub_display, "Latest 3 Publications", ['Title', 'Year', 'Venue']),
            html.Div(style={'width': '20px'}), # Spacer
            generate_mini_table(course_display, "Latest 3 Courses Taught", ['Course', 'A.Y.', 'Sem'])
        ])

        # Combine Layout
        return html.Div([
            header,
            html.Div(style={'display': 'flex', 'justifyContent': 'space-between'}, children=[research_card, teaching_card, alumni_card]),
            details_section
        ])

    except Exception as e:
        return html.Div(f"Error loading profile: {str(e)}", style={'color': 'red'})

# 6. RUN SERVER
if __name__ == '__main__':
    app.run(debug=True)