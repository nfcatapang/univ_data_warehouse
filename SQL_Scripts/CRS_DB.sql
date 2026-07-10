-- CRS_DB

-- Clean up existing tables
DROP TABLE IF EXISTS Enrollments CASCADE;
DROP TABLE IF EXISTS Class_Assignments CASCADE;
DROP TABLE IF EXISTS Course_Offerings CASCADE;
DROP TABLE IF EXISTS Students CASCADE;
DROP TABLE IF EXISTS Faculty CASCADE;
DROP TABLE IF EXISTS Courses CASCADE;
DROP TABLE IF EXISTS Degree_Programs CASCADE;
DROP TABLE IF EXISTS Departments CASCADE;
DROP TABLE IF EXISTS Semesters CASCADE;
DROP TABLE IF EXISTS Colleges CASCADE;


-- Colleges
CREATE TABLE Colleges (
    College_ID SERIAL PRIMARY KEY,
    College_Code VARCHAR(10) UNIQUE NOT NULL, 
    College_Name VARCHAR(100) NOT NULL        
);

-- Semesters
CREATE TABLE Semesters (
    Semester_ID SERIAL PRIMARY KEY,
    Academic_Year VARCHAR(10) NOT NULL, 
    Term VARCHAR(20) NOT NULL           
);

-- Departments
CREATE TABLE Departments (
    Department_ID SERIAL PRIMARY KEY,
    Department_Code VARCHAR(10) UNIQUE NOT NULL,
    Department_Name VARCHAR(100) NOT NULL,
    College_ID INT NOT NULL REFERENCES Colleges(College_ID)
);

-- Degree Programs
CREATE TABLE Degree_Programs (
    Program_ID SERIAL PRIMARY KEY,
    Program_Code VARCHAR(20) UNIQUE NOT NULL,
    Program_Name VARCHAR(100) NOT NULL,
    Department_ID INT NOT NULL REFERENCES Departments(Department_ID)
);

-- Courses
CREATE TABLE Courses (
    Course_ID SERIAL PRIMARY KEY,
    Course_Code VARCHAR(20) UNIQUE NOT NULL,
    Course_Title VARCHAR(255) NOT NULL,
    Units NUMERIC(3,1) NOT NULL DEFAULT 3.0,
    Department_ID INT NOT NULL REFERENCES Departments(Department_ID)
);

-- Faculty
CREATE TABLE Faculty (
    Faculty_ID SERIAL PRIMARY KEY,
    Faculty_Name VARCHAR(100) NOT NULL,
    Faculty_Email VARCHAR(100) NOT NULL UNIQUE,
    Department_ID INT NOT NULL REFERENCES Departments(Department_ID)
);

-- Students
CREATE TABLE Students (
    Student_ID SERIAL PRIMARY KEY,
    Student_Number BIGINT UNIQUE NOT NULL,
    Full_Name VARCHAR(100) NOT NULL,
    Program_ID INT NOT NULL REFERENCES Degree_Programs(Program_ID),
    
    -- Demographics
    Sex_Assigned VARCHAR(10) NOT NULL,
    Birthday DATE NOT NULL,
    Birthplace VARCHAR(100) NOT NULL,
    Citizenship VARCHAR(50) NOT NULL,
    Civil_Status VARCHAR(30) NOT NULL DEFAULT 'Single',
    Religion VARCHAR(50) NOT NULL,
    
    -- Family Background / Flags
    First_in_Family_UP BOOLEAN NOT NULL DEFAULT FALSE,
    First_in_Family_College BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Accessibility & Needs
    Handedness VARCHAR(10),
    Has_Disability BOOLEAN DEFAULT FALSE,
    Disability_Type VARCHAR(50),
    Disability_Desc VARCHAR(100),
    Has_Special_Needs BOOLEAN DEFAULT FALSE,
    Special_Needs_Type VARCHAR(50),
    
    -- Preferences
    Has_Preferred_Pronoun BOOLEAN DEFAULT FALSE,
    Preferred_Pronoun VARCHAR(30),
    Has_Lived_Name BOOLEAN DEFAULT FALSE,
    Lived_Name VARCHAR(50),
    
    -- Contact Info
    Mobile_Primary VARCHAR(20) NOT NULL,
    Mobile_Secondary VARCHAR(20),
    Landline VARCHAR(20),
    Email_Primary VARCHAR(100) NOT NULL,
    
    -- Address
    Housing_Type VARCHAR(30),
    Region VARCHAR(50) NOT NULL,
    Province VARCHAR(50) NOT NULL,
    City_Municipality VARCHAR(50) NOT NULL,
    Street_Address VARCHAR(100),
    
    -- Parent Info
    Father_Name VARCHAR(100),
    Father_Status VARCHAR(20),
    Father_Address VARCHAR(100),
    Mother_Name VARCHAR(100),
    Mother_Status VARCHAR(20),
    Mother_Address VARCHAR(100),
    
    -- Other
    Employment VARCHAR(30),
    
    -- Emergency Contact
    Emergency_Name VARCHAR(100),
    Emergency_Relationship VARCHAR(30),
    Emergency_Mobile VARCHAR(20),
    Emergency_Landline VARCHAR(20),
    Emergency_Email VARCHAR(100),
    
    -- Beneficiary
    Beneficiary_Name VARCHAR(100),
    Beneficiary_Relationship VARCHAR(30),
    Beneficiary_Mobile VARCHAR(20),
    Beneficiary_Landline VARCHAR(20),
    Beneficiary_Email VARCHAR(100)
);

-- Course Offerings
CREATE TABLE Course_Offerings (
    Class_ID SERIAL PRIMARY KEY,
    Course_ID INT NOT NULL REFERENCES Courses(Course_ID),
    Semester_ID INT NOT NULL REFERENCES Semesters(Semester_ID),
    Section VARCHAR(10) NOT NULL
);

-- Class Assignments
CREATE TABLE Class_Assignments (
    Class_ID INT NOT NULL REFERENCES Course_Offerings(Class_ID),
    Faculty_ID INT NOT NULL REFERENCES Faculty(Faculty_ID),
    PRIMARY KEY (Class_ID, Faculty_ID)
);

-- Enrollments
CREATE TABLE Enrollments (
    Enrollment_ID SERIAL PRIMARY KEY,
    Student_ID INT NOT NULL REFERENCES Students(Student_ID),
    Class_ID INT NOT NULL REFERENCES Course_Offerings(Class_ID),
    Grade NUMERIC(3,2), 
    Date_of_Completion DATE,
    Remarks VARCHAR(100)
);

-- INSERT DATA

-- 1. Insert Colleges
INSERT INTO Colleges (College_Code, College_Name) VALUES ('COE', 'College of Engineering') ON CONFLICT DO NOTHING;
INSERT INTO Colleges (College_Code, College_Name) VALUES ('CS', 'College of Science') ON CONFLICT DO NOTHING;

-- 2. Insert Departments
INSERT INTO Departments (Department_Code, Department_Name, College_ID) VALUES ('DCS', 'Department of Computer Science', (SELECT College_ID FROM Colleges WHERE College_Code = 'COE')) ON CONFLICT DO NOTHING;
INSERT INTO Departments (Department_Code, Department_Name, College_ID) VALUES ('DIE', 'Department of Industrial Engineering', (SELECT College_ID FROM Colleges WHERE College_Code = 'COE')) ON CONFLICT DO NOTHING;
INSERT INTO Departments (Department_Code, Department_Name, College_ID) VALUES ('IM', 'Institute of Mathematics', (SELECT College_ID FROM Colleges WHERE College_Code = 'CS')) ON CONFLICT DO NOTHING;
INSERT INTO Departments (Department_Code, Department_Name, College_ID) VALUES ('IC', 'Institute of Chemistry', (SELECT College_ID FROM Colleges WHERE College_Code = 'CS')) ON CONFLICT DO NOTHING;

-- 3. Insert Semesters
INSERT INTO Semesters (Academic_Year, Term) VALUES ('2024-2025', 'First Semester') ON CONFLICT DO NOTHING;
INSERT INTO Semesters (Academic_Year, Term) VALUES ('2024-2025', 'Second Semester') ON CONFLICT DO NOTHING;

-- 4. Insert Degree Programs
INSERT INTO Degree_Programs (Program_Code, Program_Name, Department_ID) VALUES ('MEng AI', 'Master of Engineering in Artificial Intelligence', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')) ON CONFLICT DO NOTHING;
INSERT INTO Degree_Programs (Program_Code, Program_Name, Department_ID) VALUES ('BS Math', 'Bachelor of Science in Mathematics', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM')) ON CONFLICT DO NOTHING;
INSERT INTO Degree_Programs (Program_Code, Program_Name, Department_ID) VALUES ('BS Chem', 'Bachelor of Science in Chemistry', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC')) ON CONFLICT DO NOTHING;

-- 5. Insert Courses
INSERT INTO Courses (Course_Code, Course_Title, Units, Department_ID) VALUES ('AI 201', 'Artificial Intelligence', 3.0, (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')) ON CONFLICT DO NOTHING;
INSERT INTO Courses (Course_Code, Course_Title, Units, Department_ID) VALUES ('AI 211', 'Computational Linear Algebra for AI', 3.0, (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')) ON CONFLICT DO NOTHING;
INSERT INTO Courses (Course_Code, Course_Title, Units, Department_ID) VALUES ('IE 211', 'Quantitative Methods in Industrial Engineering', 3.0, (SELECT Department_ID FROM Departments WHERE Department_Code = 'DIE')) ON CONFLICT DO NOTHING;
INSERT INTO Courses (Course_Code, Course_Title, Units, Department_ID) VALUES ('AI 212', 'Probability and Statistics for AI', 3.0, (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')) ON CONFLICT DO NOTHING;
INSERT INTO Courses (Course_Code, Course_Title, Units, Department_ID) VALUES ('AI 221', 'Classical Machine Learning', 3.0, (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')) ON CONFLICT DO NOTHING;
INSERT INTO Courses (Course_Code, Course_Title, Units, Department_ID) VALUES ('IE 230', 'Statistical Design and Analysis for Engineers', 3.0, (SELECT Department_ID FROM Departments WHERE Department_Code = 'DIE')) ON CONFLICT DO NOTHING;
INSERT INTO Courses (Course_Code, Course_Title, Units, Department_ID) VALUES ('Math 10', 'Mathematics, Culture and Society', 3.0, (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM')) ON CONFLICT DO NOTHING;
INSERT INTO Courses (Course_Code, Course_Title, Units, Department_ID) VALUES ('Math 102', 'Intermediate Calculus', 5.0, (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM')) ON CONFLICT DO NOTHING;
INSERT INTO Courses (Course_Code, Course_Title, Units, Department_ID) VALUES ('Chem 16', 'General Chemistry I', 5.0, (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC')) ON CONFLICT DO NOTHING;
INSERT INTO Courses (Course_Code, Course_Title, Units, Department_ID) VALUES ('Chem 121', 'Computer Methods in Chemistry', 3.0, (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC')) ON CONFLICT DO NOTHING;

-- 6. Insert Faculty
-- DCS Faculty
INSERT INTO Faculty (Faculty_Name, Faculty_Email, Department_ID) VALUES 
('TY, KRISTINE DEL ROSARIO', 'kdty@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')),
('NAVARRO, GLORIA OCAMPO', 'gonavarro@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')),
('DALISAY, JOHN MARK SY', 'jsdalisay@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')),
('CASTILLO, KRISTINE RIVERA', 'krcastillo@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')),
('ANDRADA, JOSHUA SANCHEZ', 'jsandrada@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')),
('MERCADO, JOHN MARK SANCHEZ', 'jsmercado@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')),
('CASTILLO, DANIEL MANALO', 'dmcastillo@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS'));

-- DIE Faculty
INSERT INTO Faculty (Faculty_Name, Faculty_Email, Department_ID) VALUES 
('CASTRO, ROSARIO DALISAY', 'rdcastro@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DIE')),
('DE LOS SANTOS, ANA DOMINGO', 'addelossantos@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DIE')),
('LIM, JOSE OCAMPO', 'jolim@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DIE')),
('TIU, MIGUEL RAMIREZ', 'mrtiu@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DIE')),
('MENDOZA, MANUEL DELA CRUZ', 'mdmendoza@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DIE')),
('HERNANDEZ, MANUEL SANCHEZ', 'mshernandez@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DIE'));

-- IM Faculty
INSERT INTO Faculty (Faculty_Name, Faculty_Email, Department_ID) VALUES 
('VALDEZ, JOHN CO', 'jcvaldez@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM')),
('BAUTISTA, PRINCESS MERCADO', 'pmbautista@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM')),
('CATAPANG, GABRIEL GOMEZ', 'ggcatapang@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM')),
('MERCADO, LUIS MENDOZA', 'lmmercado@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM')),
('TY, PATRICK MERCADO', 'pmty@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM')),
('CO, ROBERT TORRES', 'rtco@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM'));

-- IM Faculty + Student
INSERT INTO Faculty (Faculty_Name, Faculty_Email, Department_ID) VALUES 
('TAN, EMMANUEL CRUZ', 'ectan@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM'));

-- IC Faculty
INSERT INTO Faculty (Faculty_Name, Faculty_Email, Department_ID) VALUES 
('RIVERA, ANTONIO RAMOS', 'arrivera@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC')),
('CASTRO, MICHELLE DELA ROSA', 'mdcastro@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC')),
('SAN JOSE, GABRIELA SANCHEZ', 'gssanjose@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC')),
('RIVERA, RYAN AQUINO', 'rarivera@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC')),
('DE GUZMAN, GRACE GARCIA', 'ggdeguzman@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC')),
('SANTOS, MARK ANTHONY NAVARRO', 'mnsantos@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC'));


-- 7. Create Course Offerings & Assignments
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201'), (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester'), 'HAAB');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'HAAB' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'NAVARRO, GLORIA OCAMPO')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201'), (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester'), 'TQQZ');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'TQQZ' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'CASTILLO, DANIEL MANALO')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211'), (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester'), 'WQQZ');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'WQQZ' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'CASTILLO, DANIEL MANALO')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211'), (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester'), 'HZZQ');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'HZZQ' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'MERCADO, JOHN MARK SANCHEZ')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211'), (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester'), 'TWWX');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'TWWX' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'MENDOZA, MANUEL DELA CRUZ')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211'), (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester'), 'MWWX');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'MWWX' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'HERNANDEZ, MANUEL SANCHEZ')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212'), (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester'), 'TAAB');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'TAAB' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'DALISAY, JOHN MARK SY')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212'), (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester'), 'MAAB');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'MAAB' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'MERCADO, JOHN MARK SANCHEZ')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221'), (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester'), 'TWWX');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'TWWX' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'NAVARRO, GLORIA OCAMPO')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221'), (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester'), 'WWWX');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'WWWX' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'NAVARRO, GLORIA OCAMPO')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230'), (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester'), 'WWWX');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'WWWX' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'TIU, MIGUEL RAMIREZ')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230'), (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester'), 'MZZQ');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'MZZQ' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'DE LOS SANTOS, ANA DOMINGO')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10'), (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester'), 'TWWX');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'TWWX' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'MERCADO, LUIS MENDOZA')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10'), (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester'), 'MQQZ');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'MQQZ' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'TAN, EMMANUEL CRUZ')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102'), (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester'), 'WQQZ');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'WQQZ' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'BAUTISTA, PRINCESS MERCADO')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102'), (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester'), 'HZZQ');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'HZZQ' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'CATAPANG, GABRIEL GOMEZ')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16'), (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester'), 'HWWX');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'HWWX' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'RIVERA, ANTONIO RAMOS')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16'), (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester'), 'HQQZ');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'HQQZ' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'SAN JOSE, GABRIELA SANCHEZ')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121'), (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester'), 'WAAB');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'WAAB' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'RIVERA, ANTONIO RAMOS')
                );
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section) VALUES ((SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121'), (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester'), 'HWWX');
INSERT INTO Class_Assignments (Class_ID, Faculty_ID) VALUES (
                    (SELECT Class_ID FROM Course_Offerings 
                     WHERE Section = 'HWWX' 
                     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Name = 'RIVERA, ANTONIO RAMOS')
                );

-- 8. Generate Students & Enrollments (Rich Data)
INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400000, 'Tan, Emmanuel, Cruz', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '2000-01-05',
            'Naga City, Camarines Sur', 'Filipino', 'Born Again Christian', 'Married', 'Left',
            TRUE, TRUE,
            'ectan@up.edu.ph', '09835954656', 'Region V', 'Camarines Sur', 'Naga City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400000), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400000), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400000), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400000), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400000), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400000), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-18', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400001, 'Navarro, Prince, Navarro', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '2003-01-03',
            'Manila, NCR', 'Filipino', 'Roman Catholic', 'Single', 'Right',
            FALSE, TRUE,
            'pnnavarro@up.edu.ph', '09967154631', 'NCR', 'NCR', 'Manila'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400001), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400001), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400001), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400001), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400001), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400001), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-16', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400002, 'Chua, Mark Anthony, Sy', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '2002-05-23',
            'Antipolo, Rizal', 'Filipino', 'None', 'Single', 'Left',
            TRUE, FALSE,
            'mschua@up.edu.ph', '09178970873', 'Region IV-A', 'Rizal', 'Antipolo'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400002), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400002), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400002), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400002), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-15', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400003, 'Dalisay, Luis, Lim', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '1998-10-11',
            'Santa Rosa, Laguna', 'Filipino', 'Christian', 'Single', 'Right',
            TRUE, FALSE,
            'lldalisay@up.edu.ph', '09774615090', 'Region IV-A', 'Laguna', 'Santa Rosa'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400003), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400003), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400003), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400003), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400004, 'Navarro, Angelo, Domingo', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '2000-04-18',
            'Calamba, Laguna', 'Filipino', 'Roman Catholic', 'Single', 'Left',
            TRUE, TRUE,
            'adnavarro@up.edu.ph', '09138831599', 'Region IV-A', 'Laguna', 'Calamba'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400004), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400004), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400004), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-20', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400004), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-15', 'Failed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400005, 'Espiritu, John, Morales', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '1999-09-18',
            'Antipolo, Rizal', 'Filipino', 'Islam', 'Married', 'Right',
            TRUE, FALSE,
            'jmespiritu@up.edu.ph', '09252498862', 'Region IV-A', 'Rizal', 'Antipolo'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400005), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-22', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400005), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400005), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400005), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400006, 'Castro, Ryan, Yap', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '2003-11-24',
            'Manila, NCR', 'American', 'Christian', 'Single', 'Right',
            TRUE, TRUE,
            'rycastro@up.edu.ph', '09402079602', 'NCR', 'NCR', 'Manila'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400006), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400006), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-21', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400006), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400006), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400006), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.25, '2024-12-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400007, 'Dalisay, Maria, Torres', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '2000-04-22',
            'San Fernando, Pampanga', 'Filipino', 'Roman Catholic', 'Single', 'Right',
            FALSE, TRUE,
            'mtdalisay@up.edu.ph', '09748710108', 'Region III', 'Pampanga', 'San Fernando'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400007), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400007), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400007), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400007), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-19', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400007), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-16', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400007), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-20', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400008, 'Diaz, Kristine, Sanchez', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '2003-02-06',
            'Santa Rosa, Laguna', 'Filipino', 'Iglesia ni Cristo', 'Single', 'Left',
            FALSE, FALSE,
            'ksdiaz@up.edu.ph', '09787533031', 'Region IV-A', 'Laguna', 'Santa Rosa'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400008), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400008), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400008), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.25, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400008), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400008), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-16', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400009, 'Tan, Anna, Yap', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '2000-11-17',
            'Davao City, Davao del Sur', 'Filipino', 'Islam', 'Single', 'Right',
            FALSE, FALSE,
            'aytan@up.edu.ph', '09408112469', 'Region XI', 'Davao del Sur', 'Davao City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400009), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400009), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400009), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400009), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400009), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400009), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400010, 'Aquino, Lourdes, Mercado', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '2002-06-20',
            'San Fernando, Pampanga', 'Filipino', 'Christian', 'Single', 'Left',
            TRUE, TRUE,
            'lmaquino@up.edu.ph', '09880979014', 'Region III', 'Pampanga', 'San Fernando'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400010), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-20', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400010), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400010), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400010), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.25, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400010), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400010), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-18', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400011, 'Chan, John Mark, Bolasoc', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '2002-11-15',
            'Santa Rosa, Laguna', 'Filipino', 'Roman Catholic', 'Married', 'Left',
            FALSE, TRUE,
            'jbchan@up.edu.ph', '09194831099', 'Region IV-A', 'Laguna', 'Santa Rosa'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400011), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400011), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400011), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400011), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-16', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400012, 'Ramos, James, Bolasoc', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '1998-11-06',
            'Batangas City, Batangas', 'Filipino', 'Roman Catholic', 'Single', 'Right',
            FALSE, FALSE,
            'jbramos@up.edu.ph', '09332558232', 'Region IV-A', 'Batangas', 'Batangas City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400012), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-21', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400012), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400012), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400012), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400012), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400013, 'Torres, Nicole, Ramos', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '2000-06-15',
            'Pasig, NCR', 'American', 'None', 'Single', 'Left',
            TRUE, FALSE,
            'nrtorres@up.edu.ph', '09910330193', 'NCR', 'NCR', 'Pasig'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400013), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400013), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400013), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400013), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400013), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-18', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400014, 'Fernandez, Isabel, Espiritu', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '2003-01-04',
            'Quezon City, NCR', 'Filipino', 'Christian', 'Single', 'Right',
            TRUE, TRUE,
            'iefernandez@up.edu.ph', '09429879902', 'NCR', 'NCR', 'Quezon City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400014), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400014), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400014), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-19', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400014), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400014), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-18', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400015, 'Espiritu, Ryan, De Guzman', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2002-11-04',
            'Makati, NCR', 'American', 'None', 'Married', 'Right',
            TRUE, FALSE,
            'rdespiritu@up.edu.ph', '09314190538', 'NCR', 'NCR', 'Makati'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400015), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.25, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400015), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400015), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400015), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400015), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-17', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400016, 'Domingo, Mary, Chan', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '2002-04-03',
            'Makati, NCR', 'Filipino', 'Christian', 'Single', 'Left',
            FALSE, FALSE,
            'mcdomingo@up.edu.ph', '09217564174', 'NCR', 'NCR', 'Makati'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400016), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400016), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400016), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400016), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400016), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-21', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400016), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-17', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400017, 'Bolasoc, Joseph, Ty', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '2000-08-18',
            'Santa Rosa, Laguna', 'Filipino', 'Iglesia ni Cristo', 'Single', 'Right',
            TRUE, TRUE,
            'jtbolasoc@up.edu.ph', '09247185532', 'Region IV-A', 'Laguna', 'Santa Rosa'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400017), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400017), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400017), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400017), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400017), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-21', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400017), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-20', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400018, 'Del Rosario, Jennifer, Salazar', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '2003-06-19',
            'Batangas City, Batangas', 'Filipino', 'Christian', 'Single', 'Right',
            FALSE, TRUE,
            'jsdelrosario@up.edu.ph', '09540108297', 'Region IV-A', 'Batangas', 'Batangas City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400018), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400018), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400018), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400018), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-21', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400018), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400018), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-18', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400019, 'Domingo, Manuel, Sy', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '2003-09-18',
            'Calamba, Laguna', 'Filipino', 'Islam', 'Single', 'Right',
            FALSE, FALSE,
            'msdomingo@up.edu.ph', '09774837406', 'Region IV-A', 'Laguna', 'Calamba'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400019), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400019), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400019), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400019), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-21', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400019), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400019), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-20', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400020, 'Perez, Sofia, Yu', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2002-09-24',
            'San Fernando, Pampanga', 'Filipino', 'Iglesia ni Cristo', 'Married', 'Left',
            FALSE, FALSE,
            'syperez@up.edu.ph', '09543462875', 'Region III', 'Pampanga', 'San Fernando'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400020), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400020), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400020), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400020), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400020), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400020), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-21', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400021, 'Ocampo, Maria Clara, Flores', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '2001-05-19',
            'Calamba, Laguna', 'Filipino', 'Roman Catholic', 'Married', 'Right',
            FALSE, FALSE,
            'mfocampo@up.edu.ph', '09483742694', 'Region IV-A', 'Laguna', 'Calamba'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400021), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400021), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400021), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400021), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400021), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400021), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.25, '2024-12-21', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400022, 'Ty, Catherine, Salazar', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '2002-08-20',
            'Cebu City, Cebu', 'Dual Citizen', 'Iglesia ni Cristo', 'Single', 'Left',
            FALSE, TRUE,
            'csty@up.edu.ph', '09593903462', 'Region VII', 'Cebu', 'Cebu City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400022), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400022), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400022), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.25, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400022), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-19', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400023, 'Mercado, Bea, De Leon', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '1999-03-23',
            'Cebu City, Cebu', 'Filipino', 'Born Again Christian', 'Single', 'Left',
            TRUE, FALSE,
            'bdmercado@up.edu.ph', '09601240744', 'Region VII', 'Cebu', 'Cebu City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400023), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400023), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400023), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400023), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-20', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400024, 'Santos, Andrea, Ty', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '2003-08-05',
            'Pasig, NCR', 'Filipino', 'Islam', 'Single', 'Right',
            FALSE, TRUE,
            'atsantos@up.edu.ph', '09148990470', 'NCR', 'NCR', 'Pasig'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400024), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400024), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400024), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-21', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400024), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400024), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-22', 'Failed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400025, 'Sy, Mark, Torres', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2003-02-20',
            'Antipolo, Rizal', 'Filipino', 'Christian', 'Married', 'Left',
            FALSE, TRUE,
            'mtsy@up.edu.ph', '09761717633', 'Region IV-A', 'Rizal', 'Antipolo'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400025), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400025), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400025), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400025), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400025), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-19', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400026, 'Dela Cruz, Rosario, Torres', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '1998-10-10',
            'Davao City, Davao del Sur', 'American', 'Christian', 'Married', 'Left',
            FALSE, FALSE,
            'rtdelacruz@up.edu.ph', '09615880920', 'Region XI', 'Davao del Sur', 'Davao City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400026), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400026), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400026), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400026), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400026), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400026), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-17', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400027, 'Mercado, Emmanuel, Gonzales', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '1998-06-09',
            'Cebu City, Cebu', 'American', 'None', 'Single', 'Right',
            TRUE, FALSE,
            'egmercado@up.edu.ph', '09781069793', 'Region VII', 'Cebu', 'Cebu City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400027), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400027), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400027), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400027), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.25, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400027), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-17', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400028, 'Domingo, Michael, Ong', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '2000-10-09',
            'Makati, NCR', 'Filipino', 'Roman Catholic', 'Single', 'Right',
            TRUE, TRUE,
            'modomingo@up.edu.ph', '09493659650', 'NCR', 'NCR', 'Makati'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400028), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400028), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400028), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400028), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400028), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-15', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400029, 'Castillo, Jennifer, Torres', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '2000-06-01',
            'Cebu City, Cebu', 'American', 'Islam', 'Single', 'Right',
            FALSE, FALSE,
            'jtcastillo@up.edu.ph', '09731706854', 'Region VII', 'Cebu', 'Cebu City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400029), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400029), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400029), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400029), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400029), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400029), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-16', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400030, 'Co, Emmanuel, Catapang', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '2001-10-04',
            'Quezon City, NCR', 'Filipino', 'Iglesia ni Cristo', 'Single', 'Right',
            FALSE, FALSE,
            'ecco@up.edu.ph', '09312507529', 'NCR', 'NCR', 'Quezon City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400030), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400030), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400030), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400030), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400030), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400030), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400031, 'Manalo, David, Espiritu', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '1998-08-04',
            'Manila, NCR', 'Filipino', 'Roman Catholic', 'Single', 'Left',
            FALSE, FALSE,
            'demanalo@up.edu.ph', '09493183814', 'NCR', 'NCR', 'Manila'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400031), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-22', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400031), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400031), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400031), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-18', 'Failed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400032, 'Macaraeg, Jose, Hernandez', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '1999-12-12',
            'Manila, NCR', 'American', 'Iglesia ni Cristo', 'Married', 'Right',
            TRUE, FALSE,
            'jhmacaraeg@up.edu.ph', '09297157029', 'NCR', 'NCR', 'Manila'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400032), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-22', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400032), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400032), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400032), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400032), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400032), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-20', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400033, 'Diaz, Rafael, Fernandez', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '2001-04-12',
            'Quezon City, NCR', 'Filipino', 'Christian', 'Single', 'Left',
            FALSE, TRUE,
            'rfdiaz@up.edu.ph', '09609031414', 'NCR', 'NCR', 'Quezon City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400033), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400033), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400033), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400033), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400033), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400033), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-15', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400034, 'Hernandez, Ryan, De Los Santos', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '1999-01-03',
            'Baguio City, Benguet', 'Dual Citizen', 'Roman Catholic', 'Single', 'Right',
            TRUE, TRUE,
            'rdhernandez@up.edu.ph', '09191932083', 'CAR', 'Benguet', 'Baguio City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400034), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400034), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400034), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400034), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400034), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-20', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400035, 'Tan, David, Gonzales', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '2001-01-28',
            'Santa Rosa, Laguna', 'Dual Citizen', 'Roman Catholic', 'Married', 'Right',
            TRUE, TRUE,
            'dgtan@up.edu.ph', '09911114804', 'Region IV-A', 'Laguna', 'Santa Rosa'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400035), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400035), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400035), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400035), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400035), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-19', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400036, 'Tiu, Maria, Tan', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '2003-01-22',
            'Naga City, Camarines Sur', 'Filipino', 'Roman Catholic', 'Single', 'Right',
            TRUE, TRUE,
            'mttiu@up.edu.ph', '09562381543', 'Region V', 'Camarines Sur', 'Naga City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400036), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400036), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400036), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400036), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400037, 'Ong, Rafael, Gonzales', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '1999-07-14',
            'San Fernando, Pampanga', 'Filipino', 'Roman Catholic', 'Single', 'Right',
            TRUE, TRUE,
            'rgong@up.edu.ph', '09963623150', 'Region III', 'Pampanga', 'San Fernando'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400037), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400037), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400037), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400037), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-21', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400038, 'Bautista, Gloria, Salazar', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2001-03-06',
            'Pasig, NCR', 'Filipino', 'Christian', 'Single', 'Right',
            TRUE, FALSE,
            'gsbautista@up.edu.ph', '09731005958', 'NCR', 'NCR', 'Pasig'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400038), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400038), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400038), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.25, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400038), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400038), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-16', 'Failed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400039, 'De Guzman, Jennifer, Villanueva', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '1998-11-09',
            'Quezon City, NCR', 'Filipino', 'Iglesia ni Cristo', 'Single', 'Right',
            FALSE, FALSE,
            'jvdeguzman@up.edu.ph', '09724917540', 'NCR', 'NCR', 'Quezon City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400039), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400039), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400039), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400039), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400039), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-19', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400039), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-16', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400040, 'Fernandez, Christian, Tomas', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2003-06-18',
            'Pasig, NCR', 'Filipino', 'Roman Catholic', 'Single', 'Left',
            FALSE, TRUE,
            'ctfernandez@up.edu.ph', '09780125419', 'NCR', 'NCR', 'Pasig'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400040), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400040), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400040), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400040), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400040), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-16', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400041, 'Lopez, Nicole, Manalo', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '1998-03-08',
            'Davao City, Davao del Sur', 'Filipino', 'Christian', 'Married', 'Right',
            FALSE, TRUE,
            'nmlopez@up.edu.ph', '09429351454', 'Region XI', 'Davao del Sur', 'Davao City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400041), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400041), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400041), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400041), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400041), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400041), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-18', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400042, 'Manalo, Angelo, Rivera', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '2002-04-24',
            'Manila, NCR', 'American', 'Roman Catholic', 'Single', 'Right',
            TRUE, FALSE,
            'armanalo@up.edu.ph', '09944534276', 'NCR', 'NCR', 'Manila'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400042), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400042), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400042), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400042), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400042), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-19', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400043, 'Villanueva, Mark, Andrada', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '2001-03-14',
            'Iloilo City, Iloilo', 'Dual Citizen', 'Roman Catholic', 'Single', 'Right',
            FALSE, FALSE,
            'mavillanueva@up.edu.ph', '09507333743', 'Region VI', 'Iloilo', 'Iloilo City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400043), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400043), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400043), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-17', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400043), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400043), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400043), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-21', 'Failed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400044, 'Tan, Manuel, Morales', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '2003-12-15',
            'San Fernando, Pampanga', 'Filipino', 'Iglesia ni Cristo', 'Married', 'Right',
            FALSE, FALSE,
            'mmtan@up.edu.ph', '09597059855', 'Region III', 'Pampanga', 'San Fernando'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400044), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400044), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400044), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400044), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400044), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-21', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400044), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-15', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400045, 'Del Rosario, Gabriel, Morales', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '1998-02-12',
            'San Fernando, Pampanga', 'Filipino', 'Christian', 'Single', 'Right',
            FALSE, TRUE,
            'gmdelrosario@up.edu.ph', '09756611155', 'Region III', 'Pampanga', 'San Fernando'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400045), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400045), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400045), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400045), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400045), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400045), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400046, 'Gonzales, Andrea, Gomez', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '2001-02-02',
            'Naga City, Camarines Sur', 'Filipino', 'Iglesia ni Cristo', 'Single', 'Right',
            FALSE, TRUE,
            'aggonzales@up.edu.ph', '09361333503', 'Region V', 'Camarines Sur', 'Naga City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400046), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400046), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400046), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400046), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400046), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400046), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-20', 'Failed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400047, 'Sanchez, Richard, Sy', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '1999-09-11',
            'Baguio City, Benguet', 'Filipino', 'Islam', 'Married', 'Left',
            TRUE, FALSE,
            'rssanchez@up.edu.ph', '09208140825', 'CAR', 'Benguet', 'Baguio City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400047), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400047), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400047), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400047), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400048, 'De Los Santos, Emmanuel, De Guzman', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '1999-04-13',
            'Cebu City, Cebu', 'Filipino', 'Born Again Christian', 'Single', 'Right',
            TRUE, FALSE,
            'eddelossantos@up.edu.ph', '09479422674', 'Region VII', 'Cebu', 'Cebu City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400048), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400048), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400048), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400048), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400048), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-16', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400049, 'Castillo, Rafael, Dalisay', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '2000-02-21',
            'Naga City, Camarines Sur', 'Filipino', 'Christian', 'Married', 'Left',
            FALSE, FALSE,
            'rdcastillo@up.edu.ph', '09728333897', 'Region V', 'Camarines Sur', 'Naga City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400049), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-18', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400049), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400049), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400049), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400049), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-21', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400049), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-19', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400050, 'De Guzman, Patrick, Santos', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '2001-01-04',
            'Batangas City, Batangas', 'Filipino', 'Roman Catholic', 'Married', 'Right',
            FALSE, TRUE,
            'psdeguzman@up.edu.ph', '09732512132', 'Region IV-A', 'Batangas', 'Batangas City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400050), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400050), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400050), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400050), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400050), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400050), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-18', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400051, 'Ty, Rosario, Yu', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '1999-10-25',
            'Calamba, Laguna', 'Filipino', 'Roman Catholic', 'Single', 'Left',
            TRUE, TRUE,
            'ryty@up.edu.ph', '09566759979', 'Region IV-A', 'Laguna', 'Calamba'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400051), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400051), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400051), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400051), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-18', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400052, 'Tan, Nicole, Gonzales', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2000-08-22',
            'Antipolo, Rizal', 'Filipino', 'None', 'Single', 'Left',
            TRUE, TRUE,
            'ngtan@up.edu.ph', '09247446608', 'Region IV-A', 'Rizal', 'Antipolo'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400052), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400052), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400052), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400052), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-20', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400053, 'Tomas, Camille, Tiu', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '2000-01-13',
            'Makati, NCR', 'Filipino', 'Christian', 'Married', 'Right',
            FALSE, TRUE,
            'cttomas@up.edu.ph', '09325175502', 'NCR', 'NCR', 'Makati'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400053), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400053), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400053), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400053), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400053), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400054, 'Tan, Gabriel, Yap', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '1998-05-12',
            'Batangas City, Batangas', 'Filipino', 'Roman Catholic', 'Single', 'Left',
            TRUE, TRUE,
            'gytan@up.edu.ph', '09230505135', 'Region IV-A', 'Batangas', 'Batangas City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400054), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400054), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400054), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400054), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400054), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400054), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-17', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400055, 'Gomez, Gloria, Tiu', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '2002-01-14',
            'Naga City, Camarines Sur', 'Filipino', 'Iglesia ni Cristo', 'Single', 'Left',
            TRUE, TRUE,
            'gtgomez@up.edu.ph', '09479837050', 'Region V', 'Camarines Sur', 'Naga City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400055), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400055), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400055), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400055), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400055), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-19', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400056, 'Tan, Lourdes, Castillo', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2000-10-03',
            'Makati, NCR', 'Filipino', 'Roman Catholic', 'Single', 'Right',
            FALSE, FALSE,
            'lctan@up.edu.ph', '09389457722', 'NCR', 'NCR', 'Makati'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400056), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400056), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-22', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400056), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400056), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-20', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400057, 'Castillo, Eduardo, Bolasoc', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2002-08-06',
            'San Fernando, Pampanga', 'Filipino', 'None', 'Single', 'Right',
            FALSE, TRUE,
            'ebcastillo@up.edu.ph', '09621164959', 'Region III', 'Pampanga', 'San Fernando'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400057), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400057), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400057), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400057), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400057), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400058, 'Castillo, Miguel, San Jose', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '2003-11-26',
            'Manila, NCR', 'American', 'Iglesia ni Cristo', 'Single', 'Right',
            TRUE, FALSE,
            'mscastillo@up.edu.ph', '09397648294', 'NCR', 'NCR', 'Manila'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400058), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400058), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400058), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400058), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-19', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400058), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400059, 'Manalo, Gabriel, Bautista', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '2000-07-19',
            'Baguio City, Benguet', 'Filipino', 'Roman Catholic', 'Single', 'Right',
            TRUE, TRUE,
            'gbmanalo@up.edu.ph', '09818503930', 'CAR', 'Benguet', 'Baguio City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400059), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400059), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400059), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400059), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400059), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400059), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400060, 'Co, Kristine, Chua', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '1998-06-12',
            'Baguio City, Benguet', 'Filipino', 'Roman Catholic', 'Single', 'Left',
            TRUE, TRUE,
            'kcco@up.edu.ph', '09117643010', 'CAR', 'Benguet', 'Baguio City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400060), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400060), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400060), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400060), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-15', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400061, 'Espiritu, Joseph, Macaraeg', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '1998-01-28',
            'Manila, NCR', 'Filipino', 'None', 'Single', 'Left',
            TRUE, FALSE,
            'jmespiritu1@up.edu.ph', '09917716481', 'NCR', 'NCR', 'Manila'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400061), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400061), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.25, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400061), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400061), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-15', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400062, 'Bolasoc, Camille, Chan', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2000-05-15',
            'Iloilo City, Iloilo', 'Filipino', 'Christian', 'Single', 'Left',
            TRUE, FALSE,
            'ccbolasoc@up.edu.ph', '09905339489', 'Region VI', 'Iloilo', 'Iloilo City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400062), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-19', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400062), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400062), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400062), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-15', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400063, 'Diaz, Prince, Ty', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '2003-12-22',
            'Naga City, Camarines Sur', 'Dual Citizen', 'Roman Catholic', 'Single', 'Right',
            TRUE, FALSE,
            'ptdiaz@up.edu.ph', '09748078365', 'Region V', 'Camarines Sur', 'Naga City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400063), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400063), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400063), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400063), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400063), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-15', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400064, 'Espiritu, Jasmine, Andrada', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '2001-01-04',
            'Antipolo, Rizal', 'Filipino', 'Christian', 'Single', 'Right',
            TRUE, TRUE,
            'jaespiritu@up.edu.ph', '09145749200', 'Region IV-A', 'Rizal', 'Antipolo'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400064), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400064), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400064), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400064), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400064), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-16', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400064), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-20', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400065, 'Espiritu, John Paul, Ramos', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '2003-11-21',
            'Naga City, Camarines Sur', 'Filipino', 'Islam', 'Single', 'Left',
            FALSE, TRUE,
            'jrespiritu@up.edu.ph', '09209702679', 'Region V', 'Camarines Sur', 'Naga City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400065), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-20', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400065), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400065), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-18', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400065), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400065), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400065), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-21', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400066, 'Navarro, Christian, Ramos', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '1999-10-27',
            'Davao City, Davao del Sur', 'Filipino', 'Christian', 'Single', 'Right',
            TRUE, FALSE,
            'crnavarro@up.edu.ph', '09999136695', 'Region XI', 'Davao del Sur', 'Davao City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400066), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400066), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400066), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400066), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-18', 'Failed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400067, 'Espiritu, David, Ramirez', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '2002-12-05',
            'Calamba, Laguna', 'Filipino', 'Roman Catholic', 'Single', 'Left',
            TRUE, FALSE,
            'drespiritu@up.edu.ph', '09219204358', 'Region IV-A', 'Laguna', 'Calamba'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400067), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400067), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400067), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400067), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400067), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400067), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-18', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400068, 'Mendoza, Daniel, Mercado', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2000-07-19',
            'Batangas City, Batangas', 'Filipino', 'Roman Catholic', 'Single', 'Right',
            FALSE, TRUE,
            'dmmendoza@up.edu.ph', '09316256211', 'Region IV-A', 'Batangas', 'Batangas City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400068), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400068), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400068), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400068), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400068), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-22', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400068), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-18', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400069, 'Bautista, David, Catapang', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '1998-11-25',
            'Baguio City, Benguet', 'Filipino', 'Roman Catholic', 'Single', 'Left',
            FALSE, TRUE,
            'dcbautista@up.edu.ph', '09270499645', 'CAR', 'Benguet', 'Baguio City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400069), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-20', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400069), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400069), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400069), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400069), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-19', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400070, 'De Leon, Paulo, Castillo', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '2002-06-06',
            'Manila, NCR', 'Dual Citizen', 'Roman Catholic', 'Married', 'Left',
            TRUE, FALSE,
            'pcdeleon@up.edu.ph', '09989959739', 'NCR', 'NCR', 'Manila'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400070), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-16', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400070), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400070), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400070), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-20', 'Failed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400071, 'Go, Michelle, Calderon', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '1998-03-13',
            'Calamba, Laguna', 'Filipino', 'Roman Catholic', 'Single', 'Right',
            TRUE, FALSE,
            'mcgo@up.edu.ph', '09803425147', 'Region IV-A', 'Laguna', 'Calamba'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400071), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400071), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400071), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400071), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400071), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-20', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400072, 'Reyes, Maria Clara, Fernandez', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2000-12-03',
            'Davao City, Davao del Sur', 'Filipino', 'Islam', 'Single', 'Left',
            TRUE, TRUE,
            'mfreyes@up.edu.ph', '09351224870', 'Region XI', 'Davao del Sur', 'Davao City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400072), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-16', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400072), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400072), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400072), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400072), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-20', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400073, 'Macaraeg, James, De Los Santos', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2003-11-23',
            'Cebu City, Cebu', 'Filipino', 'Roman Catholic', 'Single', 'Left',
            FALSE, FALSE,
            'jdmacaraeg@up.edu.ph', '09149057875', 'Region VII', 'Cebu', 'Cebu City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400073), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400073), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400073), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400073), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-15', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400074, 'Yap, Camille, Manalo', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '2000-03-18',
            'Baguio City, Benguet', 'Filipino', 'None', 'Single', 'Right',
            FALSE, FALSE,
            'cmyap@up.edu.ph', '09636566175', 'CAR', 'Benguet', 'Baguio City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400074), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400074), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400074), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400074), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400075, 'Gomez, Jasmine, Tiu', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2001-11-23',
            'Davao City, Davao del Sur', 'Filipino', 'None', 'Married', 'Right',
            TRUE, TRUE,
            'jtgomez@up.edu.ph', '09486102843', 'Region XI', 'Davao del Sur', 'Davao City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400075), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400075), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400075), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400075), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400075), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400075), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-20', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400076, 'Diaz, Anna, Hernandez', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '2000-09-15',
            'Quezon City, NCR', 'American', 'Islam', 'Single', 'Left',
            FALSE, FALSE,
            'ahdiaz@up.edu.ph', '09991540254', 'NCR', 'NCR', 'Quezon City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400076), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400076), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400076), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400076), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-18', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400077, 'Lim, Paulo, Garcia', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '2002-05-04',
            'Pasig, NCR', 'Filipino', 'Roman Catholic', 'Single', 'Right',
            TRUE, FALSE,
            'pglim@up.edu.ph', '09877300490', 'NCR', 'NCR', 'Pasig'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400077), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400077), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400077), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400077), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400077), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-19', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400078, 'Valdez, Isabel, Santos', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '1998-08-10',
            'Baguio City, Benguet', 'Filipino', 'None', 'Single', 'Left',
            TRUE, FALSE,
            'isvaldez@up.edu.ph', '09245933005', 'CAR', 'Benguet', 'Baguio City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400078), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400078), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400078), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400078), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400078), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-21', 'Failed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400079, 'Cruz, Miguel, Fernandez', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '1998-04-22',
            'Makati, NCR', 'Filipino', 'Roman Catholic', 'Married', 'Right',
            FALSE, TRUE,
            'mfcruz@up.edu.ph', '09270900034', 'NCR', 'NCR', 'Makati'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400079), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400079), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400079), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400079), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-16', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400080, 'Castro, Maria Clara, Flores', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '2000-07-08',
            'Manila, NCR', 'Filipino', 'None', 'Single', 'Left',
            TRUE, TRUE,
            'mfcastro@up.edu.ph', '09881703052', 'NCR', 'NCR', 'Manila'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400080), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-22', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400080), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400080), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400080), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400080), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-21', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400081, 'Calderon, Nicole, Espiritu', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '1998-08-28',
            'Santa Rosa, Laguna', 'American', 'Roman Catholic', 'Single', 'Right',
            FALSE, TRUE,
            'necalderon@up.edu.ph', '09488855033', 'Region IV-A', 'Laguna', 'Santa Rosa'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400081), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400081), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400081), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-20', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400081), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-21', 'Failed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400082, 'Santos, Victoria, Gomez', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '1999-04-27',
            'Makati, NCR', 'American', 'Roman Catholic', 'Married', 'Right',
            TRUE, TRUE,
            'vgsantos@up.edu.ph', '09535294217', 'NCR', 'NCR', 'Makati'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400082), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400082), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400082), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400082), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-19', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400083, 'Yap, Mary Joy, Tomas', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '2002-02-20',
            'Pasig, NCR', 'Dual Citizen', 'Born Again Christian', 'Single', 'Right',
            TRUE, TRUE,
            'mtyap@up.edu.ph', '09802443816', 'NCR', 'NCR', 'Pasig'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400083), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-16', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400083), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400083), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400083), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-16', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400084, 'De Los Santos, Mary, Ong', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '2003-09-10',
            'San Fernando, Pampanga', 'Filipino', 'Roman Catholic', 'Single', 'Right',
            FALSE, TRUE,
            'modelossantos@up.edu.ph', '09816225129', 'Region III', 'Pampanga', 'San Fernando'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400084), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400084), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400084), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400084), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400084), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-17', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400085, 'De Guzman, Nicole, Castillo', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '2001-09-21',
            'Baguio City, Benguet', 'Filipino', 'Christian', 'Married', 'Right',
            TRUE, TRUE,
            'ncdeguzman@up.edu.ph', '09364731343', 'CAR', 'Benguet', 'Baguio City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400085), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400085), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400085), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400085), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                3.0, '2025-05-15', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400086, 'Sanchez, Grace, Rivera', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '1999-10-17',
            'Baguio City, Benguet', 'Filipino', 'Iglesia ni Cristo', 'Single', 'Right',
            TRUE, TRUE,
            'grsanchez@up.edu.ph', '09270554794', 'CAR', 'Benguet', 'Baguio City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400086), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-15', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400086), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.25, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400086), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400086), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-18', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400087, 'Hernandez, Michael, Aquino', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '2003-10-08',
            'Calamba, Laguna', 'Filipino', 'Roman Catholic', 'Single', 'Right',
            FALSE, TRUE,
            'mahernandez@up.edu.ph', '09648600226', 'Region IV-A', 'Laguna', 'Calamba'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400087), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                5.0, '2024-12-17', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400087), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400087), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400087), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400087), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-16', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400088, 'Dela Cruz, Lourdes, Castro', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '1998-03-08',
            'Quezon City, NCR', 'Dual Citizen', 'Islam', 'Married', 'Left',
            FALSE, TRUE,
            'lcdelacruz@up.edu.ph', '09863663497', 'NCR', 'NCR', 'Quezon City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400088), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400088), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400088), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400088), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400088), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.25, '2024-12-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400089, 'Morales, Jasmine, Yap', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '2001-09-11',
            'Santa Rosa, Laguna', 'Filipino', 'None', 'Single', 'Right',
            FALSE, TRUE,
            'jymorales@up.edu.ph', '09667029964', 'Region IV-A', 'Laguna', 'Santa Rosa'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400089), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-19', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400089), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400089), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-17', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400089), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-17', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400090, 'Catapang, Gabriel, Mendoza', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '1999-09-09',
            'Manila, NCR', 'Filipino', 'None', 'Single', 'Left',
            FALSE, FALSE,
            'gmcatapang@up.edu.ph', '09516873821', 'NCR', 'NCR', 'Manila'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400090), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400090), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400090), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400090), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-16', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400091, 'Mendoza, Daniel, Rodriguez', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '2001-07-23',
            'Baguio City, Benguet', 'Filipino', 'Roman Catholic', 'Married', 'Right',
            TRUE, TRUE,
            'drmendoza@up.edu.ph', '09562071714', 'CAR', 'Benguet', 'Baguio City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400091), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400091), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.25, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400091), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400091), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-19', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400091), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-22', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400092, 'Ramirez, Melissa, Santos', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '2001-02-02',
            'Batangas City, Batangas', 'Filipino', 'Iglesia ni Cristo', 'Married', 'Left',
            FALSE, FALSE,
            'msramirez@up.edu.ph', '09418955391', 'Region IV-A', 'Batangas', 'Batangas City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400092), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.25, '2024-12-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400092), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400092), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400092), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-15', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400093, 'Macaraeg, Camille, Chan', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '2003-01-03',
            'Iloilo City, Iloilo', 'Filipino', 'Christian', 'Married', 'Right',
            TRUE, FALSE,
            'ccmacaraeg@up.edu.ph', '09408793295', 'Region VI', 'Iloilo', 'Iloilo City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400093), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400093), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.75, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400093), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400093), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400093), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.5, '2024-12-19', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400094, 'Morales, Jennifer, Ramirez', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '2003-05-20',
            'Makati, NCR', 'Dual Citizen', 'Islam', 'Married', 'Right',
            FALSE, TRUE,
            'jrmorales@up.edu.ph', '09231096353', 'NCR', 'NCR', 'Makati'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400094), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.5, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400094), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-21', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400094), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-16', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400094), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400094), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-15', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400095, 'Ramirez, Gabriela, Ty', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '2003-04-22',
            'San Fernando, Pampanga', 'Filipino', 'Christian', 'Married', 'Right',
            TRUE, FALSE,
            'gtramirez@up.edu.ph', '09352577072', 'Region III', 'Pampanga', 'San Fernando'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400095), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400095), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-15', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400095), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.75, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400095), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400095), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.0, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400095), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-18', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400096, 'Catapang, Mary, Mendoza', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '1999-10-23',
            'Batangas City, Batangas', 'Filipino', 'None', 'Single', 'Right',
            TRUE, TRUE,
            'mmcatapang@up.edu.ph', '09939883894', 'Region IV-A', 'Batangas', 'Batangas City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400096), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 121')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400096), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TAAB' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 212')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.0, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400096), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400096), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                3.0, '2024-12-17', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400097, 'Aquino, Mark, Tomas', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '1998-06-10',
            'Pasig, NCR', 'Dual Citizen', 'Born Again Christian', 'Single', 'Left',
            TRUE, FALSE,
            'mtaquino@up.edu.ph', '09489081367', 'NCR', 'NCR', 'Pasig'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400097), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400097), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.25, '2024-12-18', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400097), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.75, '2024-12-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400097), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                1.5, '2024-12-17', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400097), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.0, '2025-05-21', 'Passed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400098, 'Tomas, Jennifer, Flores', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '2000-01-28',
            'Calamba, Laguna', 'Filipino', 'Christian', 'Married', 'Right',
            TRUE, FALSE,
            'jftomas@up.edu.ph', '09231594124', 'Region IV-A', 'Laguna', 'Calamba'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400098), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.25, '2025-05-16', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400098), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 102')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400098), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 201')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-21', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400098), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-22', 'Failed'
            );

INSERT INTO Students (
            Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday,
            Birthplace, Citizenship, Religion, Civil_Status, Handedness,
            First_in_Family_UP, First_in_Family_College,
            Email_Primary, Mobile_Primary, Region, Province, City_Municipality
        ) VALUES (
            202400099, 'Lim, Mary, Gomez', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '2003-04-14',
            'Baguio City, Benguet', 'Dual Citizen', 'Roman Catholic', 'Single', 'Left',
            FALSE, FALSE,
            'mglim@up.edu.ph', '09791276887', 'CAR', 'Benguet', 'Baguio City'
        );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400099), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'HZZQ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                2.0, '2025-05-22', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400099), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'TWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'First Semester')), 
                2.75, '2024-12-20', 'Passed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400099), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'MQQZ' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                5.0, '2025-05-15', 'Failed'
            );
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks) VALUES (
                (SELECT Student_ID FROM Students WHERE Student_Number = 202400099), 
                (SELECT Class_ID FROM Course_Offerings 
                 WHERE Section = 'WWWX' 
                 AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
                 AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Term = 'Second Semester')), 
                1.5, '2025-05-20', 'Passed'
            );

-- UPDATES -----------------------------------------------------------------------------------------------------
-- Additional Data: HOMEGROWN FACULTY (Faculty + Student Records)

-- Insert into Faculty Table
INSERT INTO Faculty (Faculty_Name, Faculty_Email, Department_ID) VALUES 
-- DCS (Computer Science)
('ALCANTARA, JOSE MARIA', 'jmalcantara@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')),
('BELTRAN, MARIA THERESA', 'mtbeltran@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')),
('CORPUZ, RAMON LUIS', 'rlcorpuz@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')),
('DAVID, KARLA MAE', 'kmdavid@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')),
('ESTACIO, PAOLO RICO', 'prestatio@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DCS')),
-- DIE (Industrial Engineering)
('FERRER, LUIS GABRIEL', 'lgferrer@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DIE')),
('GARCIA, ANA PATRICIA', 'apgarcia@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DIE')),
('HERRERA, MIGUEL ANTONIO', 'maherrera@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DIE')),
('IGNACIO, SOFIA ISABEL', 'siignacio@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DIE')),
('JAVIER, ROBERTO CARLOS', 'rcjavier@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'DIE')),
-- IM (Mathematics)
('LACSON, EMMANUEL JOHN', 'ejlacson@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM')),
('MANANSALA, KRISTINE JOY', 'kjmanansala@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM')),
('NOLASCO, RAPHAEL FRANCIS', 'rfnolasco@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM')),
('ORTEGA, BIANCA MARIE', 'bmortega@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM')),
('PASCUAL, CARLO MIGUEL', 'cmpascual@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IM')),
-- IC (Chemistry)
('QUINTOS, REGINA PAULA', 'rpquintos@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC')),
('RAMOS, VICTOR MANUEL', 'vmramos@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC')),
('SALAZAR, KATRINA BIANCA', 'kbsalazar@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC')),
('TAN, JONATHAN DAVID', 'jdtan2@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC')),
('UY, ALYSSA NICOLE', 'anuy@up.edu.ph', (SELECT Department_ID FROM Departments WHERE Department_Code = 'IC'));

-- Insert Same People into Students Table (To Simulate Alumni/Grad Student Status)
INSERT INTO Students (
    Student_Number, Full_Name, Program_ID, Sex_Assigned, Birthday, Birthplace, Citizenship, Religion, Email_Primary, Mobile_Primary, Region, Province, City_Municipality
) VALUES 
-- DCS (Enrolled in MEng AI)
(201500001, 'Alcantara, Jose, Maria', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '1990-01-15', 'Quezon City', 'Filipino', 'Catholic', 'jmalcantara@up.edu.ph', '09170000001', 'NCR', 'Metro Manila', 'Quezon City'),
(201500002, 'Beltran, Maria, Theresa', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '1991-03-22', 'Makati', 'Filipino', 'Catholic', 'mtbeltran@up.edu.ph', '09170000002', 'NCR', 'Metro Manila', 'Makati'),
(201500003, 'Corpuz, Ramon, Luis', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '1989-11-05', 'Manila', 'Filipino', 'Catholic', 'rlcorpuz@up.edu.ph', '09170000003', 'NCR', 'Metro Manila', 'Manila'),
(201500004, 'David, Karla, Mae', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '1992-07-19', 'Pasig', 'Filipino', 'Christian', 'kmdavid@up.edu.ph', '09170000004', 'NCR', 'Metro Manila', 'Pasig'),
(201500005, 'Estacio, Paolo, Rico', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '1990-09-30', 'Taguig', 'Filipino', 'Catholic', 'prestatio@up.edu.ph', '09170000005', 'NCR', 'Metro Manila', 'Taguig'),
-- DIE (Enrolled in MEng AI as elective or similar)
(201400001, 'Ferrer, Luis, Gabriel', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '1988-05-12', 'Quezon City', 'Filipino', 'Catholic', 'lgferrer@up.edu.ph', '09170000006', 'NCR', 'Metro Manila', 'Quezon City'),
(201400002, 'Garcia, Ana, Patricia', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '1989-02-14', 'Cebu City', 'Filipino', 'Catholic', 'apgarcia@up.edu.ph', '09170000007', 'VII', 'Cebu', 'Cebu City'),
(201400003, 'Herrera, Miguel, Antonio', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '1987-12-25', 'Davao City', 'Filipino', 'Christian', 'maherrera@up.edu.ph', '09170000008', 'XI', 'Davao del Sur', 'Davao City'),
(201400004, 'Ignacio, Sofia, Isabel', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Female', '1990-08-08', 'Iloilo', 'Filipino', 'Catholic', 'siignacio@up.edu.ph', '09170000009', 'VI', 'Iloilo', 'Iloilo City'),
(201400005, 'Javier, Roberto, Carlos', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'MEng AI'), 'Male', '1989-04-18', 'Baguio', 'Filipino', 'Catholic', 'rcjavier@up.edu.ph', '09170000010', 'CAR', 'Benguet', 'Baguio City'),
-- IM (BS Math Alumni)
(201600001, 'Lacson, Emmanuel, John', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '1993-01-20', 'Quezon City', 'Filipino', 'Catholic', 'ejlacson@up.edu.ph', '09170000011', 'NCR', 'Metro Manila', 'Quezon City'),
(201600002, 'Manansala, Kristine, Joy', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '1994-06-15', 'Makati', 'Filipino', 'Catholic', 'kjmanansala@up.edu.ph', '09170000012', 'NCR', 'Metro Manila', 'Makati'),
(201600003, 'Nolasco, Raphael, Francis', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '1993-11-11', 'Manila', 'Filipino', 'Christian', 'rfnolasco@up.edu.ph', '09170000013', 'NCR', 'Metro Manila', 'Manila'),
(201600004, 'Ortega, Bianca, Marie', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Female', '1995-02-28', 'Pasig', 'Filipino', 'Catholic', 'bmortega@up.edu.ph', '09170000014', 'NCR', 'Metro Manila', 'Pasig'),
(201600005, 'Pascual, Carlo, Miguel', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Math'), 'Male', '1994-09-09', 'Taguig', 'Filipino', 'Catholic', 'cmpascual@up.edu.ph', '09170000015', 'NCR', 'Metro Manila', 'Taguig'),
-- IC (BS Chem Alumni)
(201600006, 'Quintos, Regina, Paula', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '1993-05-05', 'Quezon City', 'Filipino', 'Catholic', 'rpquintos@up.edu.ph', '09170000016', 'NCR', 'Metro Manila', 'Quezon City'),
(201600007, 'Ramos, Victor, Manuel', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '1992-12-12', 'Makati', 'Filipino', 'Catholic', 'vmramos@up.edu.ph', '09170000017', 'NCR', 'Metro Manila', 'Makati'),
(201600008, 'Salazar, Katrina, Bianca', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '1994-03-30', 'Manila', 'Filipino', 'Christian', 'kbsalazar@up.edu.ph', '09170000018', 'NCR', 'Metro Manila', 'Manila'),
(201600009, 'Tan, Jonathan, David', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Male', '1993-08-21', 'Pasig', 'Filipino', 'Catholic', 'jdtan2@up.edu.ph', '09170000019', 'NCR', 'Metro Manila', 'Pasig'),
(201600010, 'Uy, Alyssa, Nicole', (SELECT Program_ID FROM Degree_Programs WHERE Program_Code = 'BS Chem'), 'Female', '1995-10-10', 'Taguig', 'Filipino', 'Catholic', 'anuy@up.edu.ph', '09170000020', 'NCR', 'Metro Manila', 'Taguig');

-- Create Past Semesters (For Alumni Records)
INSERT INTO Semesters (Academic_Year, Term) VALUES 
('2014-2015', 'First Semester'),
('2014-2015', 'Second Semester'),
('2015-2016', 'First Semester'),
('2015-2016', 'Second Semester'),
('2016-2017', 'First Semester'),
('2016-2017', 'Second Semester');

-- Create Past Course Offerings
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section)
SELECT 
    (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10'), 
    (SELECT Semester_ID FROM Semesters WHERE Academic_Year = '2015-2016' AND Term = 'First Semester'),
    'HSTA';

INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section)
SELECT 
    (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211'),
    (SELECT Semester_ID FROM Semesters WHERE Academic_Year = '2016-2017' AND Term = 'First Semester'),
    'HSTB';

-- Give the Faculty (who were students) some grades in the past
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
SELECT 
    s.Student_ID,
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'HSTA'),
    1.25,
    '2015-12-18',
    'Passed'
FROM Students s
WHERE s.Student_Number IN (201500001, 201500002, 201500003, 201500004, 201500005);

INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
SELECT 
    s.Student_ID,
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'HSTB'),
    1.50, 
    '2016-12-18',
    'Passed'
FROM Students s
WHERE s.Student_Number IN (201600001, 201600002, 201600003);


-- Assign Faculty to teach a current class
INSERT INTO Class_Assignments (Faculty_ID, Class_ID)
VALUES (
    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Email = 'jmalcantara@up.edu.ph'),
    (SELECT Class_ID FROM Course_Offerings 
     WHERE Section = 'TWWX' 
     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221')
     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Academic_Year = '2024-2025' AND Term = 'First Semester'))
);

INSERT INTO Class_Assignments (Faculty_ID, Class_ID)
VALUES (
    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Email = 'lgferrer@up.edu.ph'),
    (SELECT Class_ID FROM Course_Offerings 
     WHERE Section = 'TWWX' 
     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211')
     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Academic_Year = '2024-2025' AND Term = 'First Semester'))
);

INSERT INTO Class_Assignments (Faculty_ID, Class_ID)
VALUES (
    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Email = 'ejlacson@up.edu.ph'),
    (SELECT Class_ID FROM Course_Offerings 
     WHERE Section = 'TWWX' 
     AND Course_ID = (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10')
     AND Semester_ID = (SELECT Semester_ID FROM Semesters WHERE Academic_Year = '2024-2025' AND Term = 'First Semester'))
);

-- Updates -------------------------------------------------------------
-- Add grades for DIE (2014) and IC (2016) Batches
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section)
SELECT 
    (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 211'), 
    (SELECT Semester_ID FROM Semesters WHERE Academic_Year = '2014-2015' AND Term = 'Second Semester'),
    'HSTC'
ON CONFLICT DO NOTHING;

INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section)
SELECT 
    (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16'), 
    (SELECT Semester_ID FROM Semesters WHERE Academic_Year = '2016-2017' AND Term = 'First Semester'),
    'HSTD'
ON CONFLICT DO NOTHING;

INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
SELECT 
    s.Student_ID,
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'HSTC'),
    1.75, 
    '2015-05-20',
    'Passed'
FROM Students s
WHERE s.Student_Number BETWEEN 201400001 AND 201400005;

INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
SELECT 
    s.Student_ID,
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'HSTD'),
    1.25, 
    '2016-12-15',
    'Passed'
FROM Students s
WHERE s.Student_Number BETWEEN 201600006 AND 201600010;



-- Updates ------------------------------------------------------


-- Populate Alcantara's Class (AI 221)
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
SELECT 
    s.Student_ID,
    (SELECT ca.Class_ID FROM Class_Assignments ca 
     JOIN Faculty f ON ca.Faculty_ID = f.Faculty_ID 
     WHERE f.Faculty_Email = 'jmalcantara@up.edu.ph' LIMIT 1),

    (1.0 + (s.Student_ID % 4) * 0.25), 
    '2024-12-20',
    'Passed'
FROM Students s
WHERE s.Student_ID BETWEEN 1 AND 10 
ON CONFLICT DO NOTHING;

-- Populate Ferrer's Class (IE 211)
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
SELECT 
    s.Student_ID,
    (SELECT ca.Class_ID FROM Class_Assignments ca 
     JOIN Faculty f ON ca.Faculty_ID = f.Faculty_ID 
     WHERE f.Faculty_Email = 'lgferrer@up.edu.ph' LIMIT 1),
    (1.25 + (s.Student_ID % 5) * 0.25), 
    '2024-12-20',
    'Passed'
FROM Students s
WHERE s.Student_ID BETWEEN 11 AND 20
ON CONFLICT DO NOTHING;

-- Populate Lacson's Class (Math 10)
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
SELECT 
    s.Student_ID,
    (SELECT ca.Class_ID FROM Class_Assignments ca 
     JOIN Faculty f ON ca.Faculty_ID = f.Faculty_ID 
     WHERE f.Faculty_Email = 'ejlacson@up.edu.ph' LIMIT 1),
    2.0,
    '2024-12-20',
    'Passed'
FROM Students s
WHERE s.Student_ID BETWEEN 21 AND 35
ON CONFLICT DO NOTHING;

-- Add 2 failing students to Lacson's class
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
VALUES 
(
    (SELECT Student_ID FROM Students WHERE Student_ID = 36),
    (SELECT ca.Class_ID FROM Class_Assignments ca JOIN Faculty f ON ca.Faculty_ID = f.Faculty_ID WHERE f.Faculty_Email = 'ejlacson@up.edu.ph' LIMIT 1),
    5.0, '2024-12-20', 'Failed'
),
(
    (SELECT Student_ID FROM Students WHERE Student_ID = 37),
    (SELECT ca.Class_ID FROM Class_Assignments ca JOIN Faculty f ON ca.Faculty_ID = f.Faculty_ID WHERE f.Faculty_Email = 'ejlacson@up.edu.ph' LIMIT 1),
    5.0, '2024-12-20', 'Failed'
);

-- Updates ---------------------------------------------------------
-- add courses
INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section)
SELECT 
    (SELECT Course_ID FROM Courses WHERE Course_Code = 'IE 230'), 
    (SELECT Semester_ID FROM Semesters WHERE Academic_Year = '2024-2025' AND Term = 'First Semester'),
    'LEAD-A'
WHERE NOT EXISTS (SELECT 1 FROM Course_Offerings WHERE Section = 'LEAD-A');

INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section)
SELECT 
    (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 211'), 
    (SELECT Semester_ID FROM Semesters WHERE Academic_Year = '2024-2025' AND Term = 'First Semester'),
    'LEAD-B'
WHERE NOT EXISTS (SELECT 1 FROM Course_Offerings WHERE Section = 'LEAD-B');

INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section)
SELECT 
    (SELECT Course_ID FROM Courses WHERE Course_Code = 'AI 221'), 
    (SELECT Semester_ID FROM Semesters WHERE Academic_Year = '2024-2025' AND Term = 'Second Semester'),
    'LEAD-C'
WHERE NOT EXISTS (SELECT 1 FROM Course_Offerings WHERE Section = 'LEAD-C');

INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section)
SELECT 
    (SELECT Course_ID FROM Courses WHERE Course_Code = 'Math 10'), 
    (SELECT Semester_ID FROM Semesters WHERE Academic_Year = '2024-2025' AND Term = 'Second Semester'),
    'LEAD-D'
WHERE NOT EXISTS (SELECT 1 FROM Course_Offerings WHERE Section = 'LEAD-D');

INSERT INTO Course_Offerings (Course_ID, Semester_ID, Section)
SELECT 
    (SELECT Course_ID FROM Courses WHERE Course_Code = 'Chem 16'), 
    (SELECT Semester_ID FROM Semesters WHERE Academic_Year = '2024-2025' AND Term = 'First Semester'),
    'LEAD-E'
WHERE NOT EXISTS (SELECT 1 FROM Course_Offerings WHERE Section = 'LEAD-E');

INSERT INTO Class_Assignments (Faculty_ID, Class_ID)
VALUES (
    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Email = 'kdty@up.edu.ph'),
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'LEAD-A')
) ON CONFLICT DO NOTHING;

INSERT INTO Class_Assignments (Faculty_ID, Class_ID)
VALUES (
    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Email = 'jcvaldez@up.edu.ph'),
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'LEAD-B')
) ON CONFLICT DO NOTHING;

INSERT INTO Class_Assignments (Faculty_ID, Class_ID)
VALUES (
    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Email = 'mtbeltran@up.edu.ph'),
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'LEAD-C')
) ON CONFLICT DO NOTHING;

INSERT INTO Class_Assignments (Faculty_ID, Class_ID)
VALUES (
    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Email = 'kjmanansala@up.edu.ph'),
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'LEAD-D')
) ON CONFLICT DO NOTHING;

INSERT INTO Class_Assignments (Faculty_ID, Class_ID)
VALUES (
    (SELECT Faculty_ID FROM Faculty WHERE Faculty_Email = 'rpquintos@up.edu.ph'),
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'LEAD-E')
) ON CONFLICT DO NOTHING;



-- ENROLL STUDENTS (Populate Grades)
INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
SELECT s.Student_ID,
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'LEAD-A'),
    2.0 + (s.Student_ID % 3) * 0.25,
    '2024-12-20', 'Passed'
FROM Students s WHERE s.Student_ID BETWEEN 50 AND 59
ON CONFLICT DO NOTHING;

INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
SELECT s.Student_ID,
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'LEAD-B'),
    1.0 + (s.Student_ID % 2) * 0.25,
    '2024-12-20', 'Passed'
FROM Students s WHERE s.Student_ID BETWEEN 60 AND 69
ON CONFLICT DO NOTHING;

INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
SELECT s.Student_ID,
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'LEAD-C'),
    1.5, '2025-05-20', 'Passed'
FROM Students s WHERE s.Student_ID BETWEEN 75 AND 84
ON CONFLICT DO NOTHING;

INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
SELECT s.Student_ID,
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'LEAD-D'),
    2.5, '2025-05-20', 'Passed'
FROM Students s WHERE s.Student_ID BETWEEN 85 AND 94
ON CONFLICT DO NOTHING;

INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
VALUES 
((SELECT Student_ID FROM Students WHERE Student_ID=95), (SELECT Class_ID FROM Course_Offerings WHERE Section = 'LEAD-D'), 5.0, '2025-05-20', 'Failed'),
((SELECT Student_ID FROM Students WHERE Student_ID=96), (SELECT Class_ID FROM Course_Offerings WHERE Section = 'LEAD-D'), 5.0, '2025-05-20', 'Failed');

INSERT INTO Enrollments (Student_ID, Class_ID, Grade, Date_of_Completion, Remarks)
SELECT s.Student_ID,
    (SELECT Class_ID FROM Course_Offerings WHERE Section = 'LEAD-E'),
    1.25, '2024-12-20', 'Passed'
FROM Students s WHERE s.Student_ID BETWEEN 97 AND 106
ON CONFLICT DO NOTHING;