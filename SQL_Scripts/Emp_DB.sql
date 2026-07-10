-- Employees_DB

-- DROP TABLES

DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS persons CASCADE;
DROP TABLE IF EXISTS units CASCADE;
DROP TABLE IF EXISTS designation_parentheticals CASCADE;
DROP TABLE IF EXISTS designations CASCADE;
DROP TABLE IF EXISTS employee_sub_statuses CASCADE;
DROP TABLE IF EXISTS employee_statuses CASCADE;
DROP TABLE IF EXISTS employee_classifications CASCADE;


-- Classification (Faculty, Admin, REPS)
CREATE TABLE employee_classifications (
    emp_class_id SERIAL PRIMARY KEY,
    class_code VARCHAR(10) UNIQUE NOT NULL,
    class_name VARCHAR(50) NOT NULL
);

-- Status (Permanent, Temporary)
CREATE TABLE employee_statuses (
    emp_status_id SERIAL PRIMARY KEY,
    status_code VARCHAR(10) UNIQUE NOT NULL,
    status_name VARCHAR(50) NOT NULL
);

-- Sub-Status (Full Time, Part Time)
CREATE TABLE employee_sub_statuses (
    emp_sub_status_id SERIAL PRIMARY KEY,
    sub_status_code VARCHAR(10) UNIQUE NOT NULL,
    sub_status_name VARCHAR(50) NOT NULL
);

-- Designations (Professor, Admin Aide, etc.)
CREATE TABLE designations (
    designation_id SERIAL PRIMARY KEY,
    designation_code VARCHAR(20) UNIQUE NOT NULL,
    designation_name VARCHAR(100) NOT NULL
);

-- Parentheticals (On Leave, Visiting)
CREATE TABLE designation_parentheticals (
    parenthetical_id SERIAL PRIMARY KEY,
    parenthetical_code VARCHAR(10) UNIQUE NOT NULL,
    parenthetical_name VARCHAR(50) NOT NULL
);

-- Units (Hierarchical: UP -> College -> Dept)
CREATE TABLE units (
    unit_id SERIAL PRIMARY KEY,
    unit_code VARCHAR(20) UNIQUE NOT NULL,
    unit_name VARCHAR(255) NOT NULL,
    parent_unit_id INT,
    CONSTRAINT fk_parent_unit FOREIGN KEY (parent_unit_id) REFERENCES units(unit_id)
);

-- Persons
CREATE TABLE persons (
    person_id SERIAL PRIMARY KEY,
    student_number BIGINT UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    sex_assigned VARCHAR(10),
    birthday DATE,
    birthplace VARCHAR(100),
    civil_status VARCHAR(30),
    citizenship VARCHAR(50),
    tin VARCHAR(20) UNIQUE,
    sss_no VARCHAR(20) UNIQUE,
    email_primary VARCHAR(100),
    mobile_primary VARCHAR(20),
    region VARCHAR(50),
    province VARCHAR(50),
    city_municipality VARCHAR(50)
);

-- Employees
CREATE TABLE employees (
    emp_id BIGSERIAL PRIMARY KEY,
    person_id INT NOT NULL,
    emp_number VARCHAR(25) UNIQUE NOT NULL,
    emp_up_email_add VARCHAR(255) UNIQUE NOT NULL,
    
    -- Foreign Keys
    emp_class_id INT,
    emp_status_id INT,
    emp_sub_status_id INT,
    emp_primary_designation_id INT,
    emp_primary_designation_parenthetical_id INT,
    emp_primary_home_unit_id INT,

    -- Constraints
    CONSTRAINT fk_employees_person FOREIGN KEY (person_id) REFERENCES persons(person_id),
    CONSTRAINT fk_employees_class FOREIGN KEY (emp_class_id) REFERENCES employee_classifications(emp_class_id),
    CONSTRAINT fk_employees_status FOREIGN KEY (emp_status_id) REFERENCES employee_statuses(emp_status_id),
    CONSTRAINT fk_employees_sub_status FOREIGN KEY (emp_sub_status_id) REFERENCES employee_sub_statuses(emp_sub_status_id),
    CONSTRAINT fk_employees_designation FOREIGN KEY (emp_primary_designation_id) REFERENCES designations(designation_id),
    CONSTRAINT fk_employees_parenthetical FOREIGN KEY (emp_primary_designation_parenthetical_id) REFERENCES designation_parentheticals(parenthetical_id),
    CONSTRAINT fk_employees_unit FOREIGN KEY (emp_primary_home_unit_id) REFERENCES units(unit_id)
);



-- INSERT DATA

-- Units (Hierarchical: UP -> Colleges -> Departments)
INSERT INTO units (unit_code, unit_name, parent_unit_id) VALUES ('UP', 'University of the Philippines', NULL);

-- Colleges
INSERT INTO units (unit_code, unit_name, parent_unit_id) VALUES 
('COE', 'College of Engineering', (SELECT unit_id FROM units WHERE unit_code = 'UP')),
('CS', 'College of Science', (SELECT unit_id FROM units WHERE unit_code = 'UP'));

-- Departments & Offices
INSERT INTO units (unit_code, unit_name, parent_unit_id) VALUES 
('DCS', 'Department of Computer Science', (SELECT unit_id FROM units WHERE unit_code = 'COE')),
('DIE', 'Department of Industrial Engineering', (SELECT unit_id FROM units WHERE unit_code = 'COE')),
('IM', 'Institute of Mathematics', (SELECT unit_id FROM units WHERE unit_code = 'CS')),
('IC', 'Institute of Chemistry', (SELECT unit_id FROM units WHERE unit_code = 'CS')),
('HRDO', 'Human Resources Development Office', (SELECT unit_id FROM units WHERE unit_code = 'UP'));

-- Classifications
INSERT INTO employee_classifications (class_code, class_name) VALUES 
('FAC', 'Faculty'), ('ADM', 'Administrative'), ('REPS', 'REPS');

-- Statuses
INSERT INTO employee_statuses (status_code, status_name) VALUES 
('PERM', 'Permanent'), ('TEMP', 'Temporary'), ('CONT', 'Contractual');

-- Sub-Statuses
INSERT INTO employee_sub_statuses (sub_status_code, sub_status_name) VALUES 
('FT', 'Full Time'), ('PT', 'Part Time');

-- Designations
INSERT INTO designations (designation_code, designation_name) VALUES 
('PROF1', 'Professor 1'), 
('ASSOC1', 'Associate Professor 1'), 
('ASST1', 'Assistant Professor 1'), 
('INST1', 'Instructor 1'), 
('TA', 'Teaching Associate'), 
('UR', 'University Researcher'), 
('AA6', 'Administrative Aide VI');

-- Parentheticals
INSERT INTO designation_parentheticals (parenthetical_code, parenthetical_name) VALUES 
('NONE', 'None'), ('OL', 'On Leave'), ('VIS', 'Visiting');


-- 2. INSERT PERSONS

-- FACULTY (From CRS_DB)
INSERT INTO persons (student_number, full_name, sex_assigned, birthday, email_primary, mobile_primary) VALUES 
-- DCS Faculty
(NULL, 'Ty, Kristine Del Rosario', 'Female', '1985-05-15', 'kdty@up.edu.ph', '09171234567'),
(NULL, 'Navarro, Gloria Ocampo', 'Female', '1980-08-20', 'gonavarro@up.edu.ph', '09172223333'),
(NULL, 'Dalisay, John Mark Sy', 'Male', '1988-03-10', 'jsdalisay@up.edu.ph', '09174445555'),
(NULL, 'Castillo, Kristine Rivera', 'Female', '1982-11-05', 'krcastillo@up.edu.ph', '09175556666'),
(NULL, 'Andrada, Joshua Sanchez', 'Male', '1990-01-30', 'jsandrada@up.edu.ph', '09177778888'),
(NULL, 'Mercado, John Mark Sanchez', 'Male', '1989-09-12', 'jsmercado@up.edu.ph', '09179990000'),
(NULL, 'Castillo, Daniel Manalo', 'Male', '1986-07-25', 'dmcastillo@up.edu.ph', '09171112222'),

-- DIE Faculty
(NULL, 'Castro, Rosario Dalisay', 'Female', '1979-02-14', 'rdcastro@up.edu.ph', '09173334444'),
(NULL, 'De Los Santos, Ana Domingo', 'Female', '1983-06-30', 'addelossantos@up.edu.ph', '09175557777'),
(NULL, 'Lim, Jose Ocampo', 'Male', '1987-12-05', 'jolim@up.edu.ph', '09178889999'),
(NULL, 'Tiu, Miguel Ramirez', 'Male', '1991-04-18', 'mrtiu@up.edu.ph', '09170001111'),
(NULL, 'Mendoza, Manuel Dela Cruz', 'Male', '1984-10-22', 'mdmendoza@up.edu.ph', '09172224444'),
(NULL, 'Hernandez, Manuel Sanchez', 'Male', '1989-01-15', 'mshernandez@up.edu.ph', '09173336666'),

-- IM Faculty
(NULL, 'Valdez, John Co', 'Male', '1981-09-09', 'jcvaldez@up.edu.ph', '09174447777'),
(NULL, 'Bautista, Princess Mercado', 'Female', '1978-11-28', 'pmbautista@up.edu.ph', '09175558888'),
(NULL, 'Catapang, Gabriel Gomez', 'Male', '1992-03-15', 'ggcatapang@up.edu.ph', '09176669999'),
(NULL, 'Mercado, Luis Mendoza', 'Male', '1985-05-20', 'lmmercado@up.edu.ph', '09177770000'),
(NULL, 'Ty, Patrick Mercado', 'Male', '1979-08-08', 'pmty@up.edu.ph', '09178881111'),
(NULL, 'Co, Robert Torres', 'Male', '1988-12-12', 'rtco@up.edu.ph', '09179992222'),

-- IC Faculty
(NULL, 'Rivera, Antonio Ramos', 'Male', '1984-04-04', 'arrivera@up.edu.ph', '09170003333'),
(NULL, 'Castro, Michelle Dela Rosa', 'Female', '1986-06-16', 'mdcastro@up.edu.ph', '09171114444'),
(NULL, 'San Jose, Gabriela Sanchez', 'Female', '1990-10-10', 'gssanjose@up.edu.ph', '09172225555'),
(NULL, 'Rivera, Ryan Aquino', 'Male', '1982-01-21', 'rarivera@up.edu.ph', '09173336666'),
(NULL, 'De Guzman, Grace Garcia', 'Female', '1987-07-07', 'ggdeguzman@up.edu.ph', '09174447777'),
(NULL, 'Santos, Mark Anthony Navarro', 'Male', '1989-02-14', 'mnsantos@up.edu.ph', '09175558888'),

-- STUDENT-EMPLOYEES
(202400000, 'Tan, Emmanuel, Cruz', 'Male', '2000-01-05', 'ectan@up.edu.ph', '09835954656'),
(202400001, 'Navarro, Prince, Navarro', 'Male', '2003-01-03', 'pnnavarro@up.edu.ph', '09967154631'),
(202400003, 'Dalisay, Luis, Lim', 'Female', '1998-10-11', 'lldalisay@up.edu.ph', '09774615090'),

-- PURE ADMIN (Not in CRS)
(NULL, 'Dela Cruz, Juana Santos', 'Female', '1990-02-14', 'jsdelacruz@up.edu.ph', '09181234567');


-- INSERT EMPLOYEES
-- -------------------------------------------------------------

-- FACULTY APPOINTMENTS
-- DCS
INSERT INTO employees (person_id, emp_number, emp_up_email_add, emp_class_id, emp_status_id, emp_sub_status_id, emp_primary_designation_id, emp_primary_designation_parenthetical_id, emp_primary_home_unit_id) 
SELECT person_id, '100' || person_id, email_primary, 1, 1, 1, (SELECT designation_id FROM designations WHERE designation_code='PROF1'), 1, (SELECT unit_id FROM units WHERE unit_code='DCS')
FROM persons WHERE full_name IN ('Ty, Kristine Del Rosario', 'Navarro, Gloria Ocampo', 'Dalisay, John Mark Sy', 'Castillo, Kristine Rivera', 'Andrada, Joshua Sanchez', 'Mercado, John Mark Sanchez', 'Castillo, Daniel Manalo');

-- DIE
INSERT INTO employees (person_id, emp_number, emp_up_email_add, emp_class_id, emp_status_id, emp_sub_status_id, emp_primary_designation_id, emp_primary_designation_parenthetical_id, emp_primary_home_unit_id) 
SELECT person_id, '200' || person_id, email_primary, 1, 1, 1, (SELECT designation_id FROM designations WHERE designation_code='ASSOC1'), 1, (SELECT unit_id FROM units WHERE unit_code='DIE')
FROM persons WHERE full_name IN ('Castro, Rosario Dalisay', 'De Los Santos, Ana Domingo', 'Lim, Jose Ocampo', 'Tiu, Miguel Ramirez', 'Mendoza, Manuel Dela Cruz', 'Hernandez, Manuel Sanchez');

-- IM
INSERT INTO employees (person_id, emp_number, emp_up_email_add, emp_class_id, emp_status_id, emp_sub_status_id, emp_primary_designation_id, emp_primary_designation_parenthetical_id, emp_primary_home_unit_id) 
SELECT person_id, '300' || person_id, email_primary, 1, 1, 1, (SELECT designation_id FROM designations WHERE designation_code='ASST1'), 1, (SELECT unit_id FROM units WHERE unit_code='IM')
FROM persons WHERE full_name IN ('Valdez, John Co', 'Bautista, Princess Mercado', 'Catapang, Gabriel Gomez', 'Mercado, Luis Mendoza', 'Ty, Patrick Mercado', 'Co, Robert Torres');

-- IC
INSERT INTO employees (person_id, emp_number, emp_up_email_add, emp_class_id, emp_status_id, emp_sub_status_id, emp_primary_designation_id, emp_primary_designation_parenthetical_id, emp_primary_home_unit_id) 
SELECT person_id, '400' || person_id, email_primary, 1, 1, 1, (SELECT designation_id FROM designations WHERE designation_code='INST1'), 1, (SELECT unit_id FROM units WHERE unit_code='IC')
FROM persons WHERE full_name IN ('Rivera, Antonio Ramos', 'Castro, Michelle Dela Rosa', 'San Jose, Gabriela Sanchez', 'Rivera, Ryan Aquino', 'De Guzman, Grace Garcia', 'Santos, Mark Anthony Navarro');


-- STUDENT-EMPLOYEE OVERLAPS

-- Emmanuel Tan (Teaching Associate in IM)
INSERT INTO employees (person_id, emp_number, emp_up_email_add, emp_class_id, emp_status_id, emp_sub_status_id, emp_primary_designation_id, emp_primary_designation_parenthetical_id, emp_primary_home_unit_id) 
SELECT person_id, '50001', email_primary, 1, 2, 2, 
(SELECT designation_id FROM designations WHERE designation_code='TA'), 1, 
(SELECT unit_id FROM units WHERE unit_code='IM')
FROM persons WHERE student_number = 202400000;

-- Prince Navarro (Research Assistant in DCS)
INSERT INTO employees (person_id, emp_number, emp_up_email_add, emp_class_id, emp_status_id, emp_sub_status_id, emp_primary_designation_id, emp_primary_designation_parenthetical_id, emp_primary_home_unit_id) 
SELECT person_id, '50002', email_primary, 3, 3, 2, 
(SELECT designation_id FROM designations WHERE designation_code='UR'), 1, 
(SELECT unit_id FROM units WHERE unit_code='DCS')
FROM persons WHERE student_number = 202400001;

-- Luis Dalisay (Student Assistant in HRDO)
INSERT INTO employees (person_id, emp_number, emp_up_email_add, emp_class_id, emp_status_id, emp_sub_status_id, emp_primary_designation_id, emp_primary_designation_parenthetical_id, emp_primary_home_unit_id) 
SELECT person_id, '50003', email_primary, 2, 3, 2, 
(SELECT designation_id FROM designations WHERE designation_code='AA6'), 1, 
(SELECT unit_id FROM units WHERE unit_code='HRDO')
FROM persons WHERE student_number = 202400003;


-- PURE ADMIN
-- Juana Dela Cruz (HR Staff)
INSERT INTO employees (person_id, emp_number, emp_up_email_add, emp_class_id, emp_status_id, emp_sub_status_id, emp_primary_designation_id, emp_primary_designation_parenthetical_id, emp_primary_home_unit_id) 
SELECT person_id, '60001', email_primary, 2, 1, 1, 
(SELECT designation_id FROM designations WHERE designation_code='AA6'), 1, 
(SELECT unit_id FROM units WHERE unit_code='HRDO')
FROM persons WHERE full_name = 'Dela Cruz, Juana Santos';


-- UPDATES ----------------------------------------------------------------------------

-- Insert into Persons Table
INSERT INTO persons (student_number, full_name, sex_assigned, birthday, email_primary, mobile_primary) VALUES
(201500001, 'Alcantara, Jose Maria', 'Male', '1990-01-15', 'jmalcantara@up.edu.ph', '09170000001'),
(201500002, 'Beltran, Maria Theresa', 'Female', '1991-03-22', 'mtbeltran@up.edu.ph', '09170000002'),
(201500003, 'Corpuz, Ramon Luis', 'Male', '1989-11-05', 'rlcorpuz@up.edu.ph', '09170000003'),
(201500004, 'David, Karla Mae', 'Female', '1992-07-19', 'kmdavid@up.edu.ph', '09170000004'),
(201500005, 'Estacio, Paolo Rico', 'Male', '1990-09-30', 'prestatio@up.edu.ph', '09170000005'),
(201400001, 'Ferrer, Luis Gabriel', 'Male', '1988-05-12', 'lgferrer@up.edu.ph', '09170000006'),
(201400002, 'Garcia, Ana Patricia', 'Female', '1989-02-14', 'apgarcia@up.edu.ph', '09170000007'),
(201400003, 'Herrera, Miguel Antonio', 'Male', '1987-12-25', 'maherrera@up.edu.ph', '09170000008'),
(201400004, 'Ignacio, Sofia Isabel', 'Female', '1990-08-08', 'siignacio@up.edu.ph', '09170000009'),
(201400005, 'Javier, Roberto Carlos', 'Male', '1989-04-18', 'rcjavier@up.edu.ph', '09170000010'),
(201600001, 'Lacson, Emmanuel John', 'Male', '1993-01-20', 'ejlacson@up.edu.ph', '09170000011'),
(201600002, 'Manansala, Kristine Joy', 'Female', '1994-06-15', 'kjmanansala@up.edu.ph', '09170000012'),
(201600003, 'Nolasco, Raphael Francis', 'Male', '1993-11-11', 'rfnolasco@up.edu.ph', '09170000013'),
(201600004, 'Ortega, Bianca Marie', 'Female', '1995-02-28', 'bmortega@up.edu.ph', '09170000014'),
(201600005, 'Pascual, Carlo Miguel', 'Male', '1994-09-09', 'cmpascual@up.edu.ph', '09170000015'),
(201600006, 'Quintos, Regina Paula', 'Female', '1993-05-05', 'rpquintos@up.edu.ph', '09170000016'),
(201600007, 'Ramos, Victor Manuel', 'Male', '1992-12-12', 'vmramos@up.edu.ph', '09170000017'),
(201600008, 'Salazar, Katrina Bianca', 'Female', '1994-03-30', 'kbsalazar@up.edu.ph', '09170000018'),
(201600009, 'Tan, Jonathan David', 'Male', '1993-08-21', 'jdtan2@up.edu.ph', '09170000019'),
(201600010, 'Uy, Alyssa Nicole', 'Female', '1995-10-10', 'anuy@up.edu.ph', '09170000020');

-- 4.2 Insert into Employees Table
INSERT INTO employees (person_id, emp_number, emp_up_email_add, emp_class_id, emp_status_id, emp_sub_status_id, emp_primary_designation_id, emp_primary_designation_parenthetical_id, emp_primary_home_unit_id)
SELECT person_id, '8000' || person_id, email_primary, 1, 1, 1, (SELECT designation_id FROM designations WHERE designation_code='ASST1'), 1, 
    CASE 
        WHEN email_primary LIKE '%alcantara%' OR email_primary LIKE '%beltran%' OR email_primary LIKE '%corpuz%' OR email_primary LIKE '%david%' OR email_primary LIKE '%estacio%' THEN (SELECT unit_id FROM units WHERE unit_code='DCS')
        WHEN email_primary LIKE '%ferrer%' OR email_primary LIKE '%garcia%' OR email_primary LIKE '%herrera%' OR email_primary LIKE '%ignacio%' OR email_primary LIKE '%javier%' THEN (SELECT unit_id FROM units WHERE unit_code='DIE')
        WHEN email_primary LIKE '%lacson%' OR email_primary LIKE '%manansala%' OR email_primary LIKE '%nolasco%' OR email_primary LIKE '%ortega%' OR email_primary LIKE '%pascual%' THEN (SELECT unit_id FROM units WHERE unit_code='IM')
        ELSE (SELECT unit_id FROM units WHERE unit_code='IC')
    END
FROM persons WHERE student_number BETWEEN 201400001 AND 201600010;