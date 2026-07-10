-- Publications_DB


-- DROP EXISTING TABLES
DROP TABLE IF EXISTS publication_identifiers CASCADE;
DROP TABLE IF EXISTS publication_authors CASCADE;
DROP TABLE IF EXISTS affiliations CASCADE;
DROP TABLE IF EXISTS publications CASCADE;
DROP TABLE IF EXISTS sources CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS persons CASCADE;
DROP TABLE IF EXISTS identifiers CASCADE;
DROP TABLE IF EXISTS publication_types CASCADE;
DROP TABLE IF EXISTS countries CASCADE;
DROP TABLE IF EXISTS statuses CASCADE;


CREATE TABLE statuses (
    id SERIAL PRIMARY KEY,
    category VARCHAR(50) NOT NULL,    -- e.g., 'PUBLICATION', 'AUTHOR'
    status_code VARCHAR(20) NOT NULL, -- e.g., 'PUB', 'DFT'
    name VARCHAR(50) NOT NULL,        -- e.g., 'Published', 'Draft'
    description TEXT
);

CREATE TABLE countries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(10) NOT NULL         
);

CREATE TABLE publication_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL         -- e.g., 'Journal Article', 'Book'
);

CREATE TABLE identifiers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,        -- e.g., 'DOI', 'ISBN', 'ISSN'
    subtype VARCHAR(50)               -- e.g., 'Print', 'Electronic'
);

CREATE TABLE persons (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),          
    last_name VARCHAR(50) NOT NULL,
    suffix VARCHAR(10),              
    email VARCHAR(100) NOT NULL,      
    institution_affiliation VARCHAR(255),
    orcid_id VARCHAR(30)
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL,        -- e.g., 'Encoder', 'Admin'
    status_id INT NOT NULL REFERENCES statuses(id)
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    person_id INT NOT NULL REFERENCES persons(id),
    employee_no VARCHAR(30),          
    status_id INT NOT NULL REFERENCES statuses(id),
	
    created_by INT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by INT REFERENCES users(id),
    updated_at TIMESTAMP,
    approved_by INT REFERENCES users(id),
    approved_at TIMESTAMP
);

CREATE TABLE authors (
    id SERIAL PRIMARY KEY,
    person_id INT NOT NULL REFERENCES persons(id),
    h_index INT DEFAULT 0,
    citation_count INT DEFAULT 0,
    status_id INT NOT NULL REFERENCES statuses(id),

    created_by INT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by INT REFERENCES users(id),
    updated_at TIMESTAMP,
    approved_by INT REFERENCES users(id),
    approved_at TIMESTAMP
);

CREATE TABLE sources (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,      -- The Journal/Conference Name
    publisher VARCHAR(255),
    country_id INT REFERENCES countries(id),
    h_index INT,
    index_coverage VARCHAR(100),      -- e.g., 'Scopus', 'WOS'
    status_id INT NOT NULL REFERENCES statuses(id),

    created_by INT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by INT REFERENCES users(id),
    updated_at TIMESTAMP,
    approved_by INT REFERENCES users(id),
    approved_at TIMESTAMP
);

CREATE TABLE publications (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    publication_type_id INT NOT NULL REFERENCES publication_types(id),
    source_id INT REFERENCES sources(id),
    volume VARCHAR(20),
    issue VARCHAR(20),
    page VARCHAR(20),
    month_published SMALLINT,
    day_published SMALLINT,
    year_published INT NOT NULL,      
    document VARCHAR(255),            
    status_id INT NOT NULL REFERENCES statuses(id),
    metadata JSONB,                   
   
    created_by INT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by INT REFERENCES users(id),
    updated_at TIMESTAMP,
    approved_by INT REFERENCES users(id),
    approved_at TIMESTAMP
);

CREATE TABLE affiliations (
    id SERIAL PRIMARY KEY,
    author_id INT NOT NULL REFERENCES authors(id),
    name VARCHAR(255) NOT NULL,       -- The Dept/College Name
    status_id INT NOT NULL REFERENCES statuses(id),

    created_by INT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by INT REFERENCES users(id),
    updated_at TIMESTAMP,
    approved_by INT REFERENCES users(id),
    approved_at TIMESTAMP
);

CREATE TABLE publication_authors (
    publication_id INT NOT NULL REFERENCES publications(id),
    author_id INT NOT NULL REFERENCES authors(id),
    status_id INT NOT NULL REFERENCES statuses(id),
    metadata JSONB,                   -- Stores 'rank', 'is_corresponding', etc.
    
    created_by INT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_by INT REFERENCES users(id),
    approved_at TIMESTAMP,
    PRIMARY KEY (publication_id, author_id)
);

CREATE TABLE publication_identifiers (
    publication_id INT NOT NULL REFERENCES publications(id),
    identifier_id INT NOT NULL REFERENCES identifiers(id),
    value VARCHAR(255) NOT NULL,      -- The actual DOI/ISBN string
    status_id INT NOT NULL REFERENCES statuses(id),

    created_by INT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by INT REFERENCES users(id),
    updated_at TIMESTAMP,
    approved_by INT REFERENCES users(id),
    approved_at TIMESTAMP,
    PRIMARY KEY (publication_id, identifier_id)
);


-- INSERT DATA

INSERT INTO statuses (category, status_code, name, description) VALUES
('GENERIC', 'ACT', 'Active', 'Record is active and visible'),
('GENERIC', 'INA', 'Inactive', 'Record is archived or deleted'),
('PUBLICATION', 'PUB', 'Published', 'Final version of record available'),
('PUBLICATION', 'SUB', 'Submitted', 'Under peer review'),
('PUBLICATION', 'DFT', 'Draft', 'Work in progress');

INSERT INTO countries (name, code) VALUES
('Philippines', 'PH'), ('United States', 'US'), ('United Kingdom', 'UK'), ('Singapore', 'SG');

INSERT INTO publication_types (name) VALUES
('Journal Article'), ('Conference Proceeding'), ('Book Chapter'), ('Patent');

INSERT INTO identifiers (name, subtype) VALUES
('DOI', 'Digital Object Identifier'), ('ISBN', 'Print'), ('ISSN', 'Electronic');

INSERT INTO users (username, email, role, status_id) VALUES
('admin', 'admin@up.edu.ph', 'SuperAdmin', 1),
('encoder1', 'staff@up.edu.ph', 'Encoder', 1);


-- Faculty
INSERT INTO persons (first_name, middle_name, last_name, email, institution_affiliation) VALUES
('Kristine', 'Del Rosario', 'Ty', 'kdty@up.edu.ph', 'Dept of Computer Science, UP Diliman'),
('John', 'Co', 'Valdez', 'jcvaldez@up.edu.ph', 'Institute of Mathematics, UP Diliman'),
('Antonio', 'Ramos', 'Rivera', 'arrivera@up.edu.ph', 'Institute of Chemistry, UP Diliman'),
('Rosario', 'Dalisay', 'Castro', 'rdcastro@up.edu.ph', 'Dept of Industrial Engineering, UP Diliman');

-- Students
INSERT INTO persons (first_name, middle_name, last_name, email, institution_affiliation) VALUES
('Prince', 'Navarro', 'Navarro', 'pnnavarro@up.edu.ph', 'Dept of Computer Science, UP Diliman');

-- External
INSERT INTO persons (first_name, middle_name, last_name, email, institution_affiliation) VALUES
('John', 'H.', 'Smith', 'jsmith@mit.edu', 'MIT'),
('Alice', 'L.', 'Wong', 'awong@nus.edu.sg', 'National University of Singapore');


INSERT INTO employees (person_id, employee_no, status_id, created_by) VALUES
((SELECT id FROM persons WHERE email='kdty@up.edu.ph'), '1001', 1, 1),
((SELECT id FROM persons WHERE email='jcvaldez@up.edu.ph'), '3001', 1, 1),
((SELECT id FROM persons WHERE email='arrivera@up.edu.ph'), '4001', 1, 1),
((SELECT id FROM persons WHERE email='rdcastro@up.edu.ph'), '2001', 1, 1);


-- AUTHORS

-- Faculty
INSERT INTO authors (person_id, h_index, citation_count, status_id, created_by) VALUES
((SELECT id FROM persons WHERE email='kdty@up.edu.ph'), 12, 450, 1, 1),
((SELECT id FROM persons WHERE email='jcvaldez@up.edu.ph'), 8, 210, 1, 1),
((SELECT id FROM persons WHERE email='arrivera@up.edu.ph'), 15, 800, 1, 1),
((SELECT id FROM persons WHERE email='rdcastro@up.edu.ph'), 5, 80, 1, 1);

-- Student
INSERT INTO authors (person_id, h_index, citation_count, status_id, created_by) VALUES
((SELECT id FROM persons WHERE email='pnnavarro@up.edu.ph'), 1, 5, 1, 1);

-- External
INSERT INTO authors (person_id, h_index, citation_count, status_id, created_by) VALUES
((SELECT id FROM persons WHERE email='jsmith@mit.edu'), 45, 5000, 1, 1),
((SELECT id FROM persons WHERE email='awong@nus.edu.sg'), 22, 1200, 1, 1);


-- AFFILIATIONS
INSERT INTO affiliations (author_id, name, status_id, created_by) VALUES
((SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='kdty@up.edu.ph')), 'Department of Computer Science', 1, 1),
((SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='arrivera@up.edu.ph')), 'Institute of Chemistry', 1, 1);


-- SOURCES
INSERT INTO sources (title, publisher, country_id, h_index, index_coverage, status_id, created_by) VALUES
('IEEE Transactions on Pattern Analysis', 'IEEE', (SELECT id FROM countries WHERE code='US'), 250, 'ISI/Scopus', 1, 1),
('Journal of Chemical Education', 'ACS Publications', (SELECT id FROM countries WHERE code='US'), 85, 'ISI', 1, 1),
('Asian Journal of Mathematics', 'International Press', (SELECT id FROM countries WHERE code='SG'), 35, 'Scopus', 1, 1),
('International Conference on Industrial Engineering', 'Elsevier', (SELECT id FROM countries WHERE code='UK'), 18, 'Scopus', 1, 1);


-- PUBLICATIONS

-- Paper 1
INSERT INTO publications (title, publication_type_id, source_id, year_published, status_id, created_by) VALUES
('Deep Learning Architectures for Natural Language Processing in Filipino Dialects', 
 (SELECT id FROM publication_types WHERE name='Journal Article'), -- Correct
 (SELECT id FROM sources WHERE title='IEEE Transactions on Pattern Analysis'),
 2024, 3, 1);

-- Paper 2 
INSERT INTO publications (title, publication_type_id, source_id, year_published, status_id, created_by) VALUES
('Green Synthesis of Nanoparticles using Local Plant Extracts', 
 (SELECT id FROM publication_types WHERE name='Journal Article'), -- Fixed
 (SELECT id FROM sources WHERE title='Journal of Chemical Education'),
 2023, 3, 1);

-- Paper 3 
INSERT INTO publications (title, publication_type_id, source_id, year_published, status_id, created_by) VALUES
('Stochastic Modeling of Traffic Flow in Metro Manila', 
 (SELECT id FROM publication_types WHERE name='Journal Article'), -- Fixed
 (SELECT id FROM sources WHERE title='Asian Journal of Mathematics'),
 2024, 3, 1);

-- Paper 4 
INSERT INTO publications (title, publication_type_id, source_id, year_published, status_id, created_by) VALUES
('Computational Analysis of Molecular Structures using Graph Neural Networks', 
 (SELECT id FROM publication_types WHERE name='Journal Article'), -- Fixed
 (SELECT id FROM sources WHERE title='IEEE Transactions on Pattern Analysis'),
 2023, 3, 1);


-- PUBLICATION AUTHORS
-- Paper 1
INSERT INTO publication_authors (publication_id, author_id, status_id, created_by, metadata) VALUES
(1, (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='kdty@up.edu.ph')), 1, 1, '{"rank": 1, "role": "Primary Investigator", "is_corresponding": true}'),
(1, (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='pnnavarro@up.edu.ph')), 1, 1, '{"rank": 2, "role": "Researcher", "is_corresponding": false}');

-- Paper 2
INSERT INTO publication_authors (publication_id, author_id, status_id, created_by, metadata) VALUES
(2, (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='arrivera@up.edu.ph')), 1, 1, '{"rank": 1, "role": "Author", "is_corresponding": true}');

-- Paper 3
INSERT INTO publication_authors (publication_id, author_id, status_id, created_by, metadata) VALUES
(3, (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='jcvaldez@up.edu.ph')), 1, 1, '{"rank": 1, "role": "Author", "is_corresponding": true}'),
(3, (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='jsmith@mit.edu')), 1, 1, '{"rank": 2, "role": "Co-Author", "is_corresponding": false}');

-- Paper 4
INSERT INTO publication_authors (publication_id, author_id, status_id, created_by, metadata) VALUES
(4, (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='kdty@up.edu.ph')), 1, 1, '{"rank": 1, "role": "Primary Investigator", "is_corresponding": true}'),
(4, (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='arrivera@up.edu.ph')), 1, 1, '{"rank": 2, "role": "Co-Investigator", "is_corresponding": false}');


-- PUBLICATION IDENTIFIERS
INSERT INTO publication_identifiers (publication_id, identifier_id, value, status_id, created_by) VALUES
(1, (SELECT id FROM identifiers WHERE name='DOI'), '10.1109/TPAMI.2024.12345', 1, 1),
(2, (SELECT id FROM identifiers WHERE name='DOI'), '10.1021/ed.2023.67890', 1, 1),
(3, (SELECT id FROM identifiers WHERE name='DOI'), '10.1142/AJM.2024.11223', 1, 1),
(4, (SELECT id FROM identifiers WHERE name='DOI'), '10.1109/TPAMI.2023.54321', 1, 1);


-- UPDATES ---------------------------------------------------------------------
-- Insert into Persons
INSERT INTO persons (first_name, last_name, email, institution_affiliation) VALUES
('Jose Maria', 'Alcantara', 'jmalcantara@up.edu.ph', 'DCS, UP Diliman'),
('Maria Theresa', 'Beltran', 'mtbeltran@up.edu.ph', 'DCS, UP Diliman'),
('Ramon Luis', 'Corpuz', 'rlcorpuz@up.edu.ph', 'DCS, UP Diliman'),
('Luis Gabriel', 'Ferrer', 'lgferrer@up.edu.ph', 'DIE, UP Diliman'),
('Ana Patricia', 'Garcia', 'apgarcia@up.edu.ph', 'DIE, UP Diliman'),
('Emmanuel John', 'Lacson', 'ejlacson@up.edu.ph', 'IM, UP Diliman'),
('Kristine Joy', 'Manansala', 'kjmanansala@up.edu.ph', 'IM, UP Diliman'),
('Regina Paula', 'Quintos', 'rpquintos@up.edu.ph', 'IC, UP Diliman'),
('Victor Manuel', 'Ramos', 'vmramos@up.edu.ph', 'IC, UP Diliman'),
('Jonathan David', 'Tan', 'jdtan2@up.edu.ph', 'IC, UP Diliman');

-- Insert into Authors
INSERT INTO authors (person_id, h_index, citation_count, status_id, created_by) 
SELECT id, 5, 50, 1, 1 FROM persons WHERE email IN (
    'jmalcantara@up.edu.ph', 'mtbeltran@up.edu.ph', 'rlcorpuz@up.edu.ph', 'lgferrer@up.edu.ph', 
    'apgarcia@up.edu.ph', 'ejlacson@up.edu.ph', 'kjmanansala@up.edu.ph', 'rpquintos@up.edu.ph', 
    'vmramos@up.edu.ph', 'jdtan2@up.edu.ph'
);

-- Insert Publications
INSERT INTO publications (title, publication_type_id, source_id, year_published, status_id, created_by) VALUES
-- DCS Papers
('Optimizing Neural Networks for Low-Resource Hardware', 1, 1, 2023, 3, 1),
('Automated Code Generation using Transformers', 1, 1, 2024, 3, 1),
-- DIE Papers
('Supply Chain Resilience in Archipelagic Regions', 1, 4, 2023, 3, 1),
('Ergonomic Assessment of Remote Work Stations', 1, 4, 2022, 3, 1),
-- IM Papers
('Algebraic Structures in Cryptography', 1, 3, 2023, 3, 1),
('Non-Linear Dynamics of Tropical Cyclones', 1, 3, 2024, 3, 1),
-- IC Papers
('Synthesis of Biodegradable Polymers from Algae', 1, 2, 2023, 3, 1),
('Computational Modelling of Protein Folding', 1, 2, 2022, 3, 1);

-- Link Publications to Authors
INSERT INTO publication_authors (publication_id, author_id, status_id, created_by, metadata) VALUES

(
    (SELECT id FROM publications WHERE title = 'Optimizing Neural Networks for Low-Resource Hardware'), 
    (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='jmalcantara@up.edu.ph')), 
    1, 1, '{}'
),
(
    (SELECT id FROM publications WHERE title = 'Automated Code Generation using Transformers'), 
    (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='mtbeltran@up.edu.ph')), 
    1, 1, '{}'
),

(
    (SELECT id FROM publications WHERE title = 'Supply Chain Resilience in Archipelagic Regions'), 
    (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='lgferrer@up.edu.ph')), 
    1, 1, '{}'
),
(
    (SELECT id FROM publications WHERE title = 'Ergonomic Assessment of Remote Work Stations'), 
    (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='apgarcia@up.edu.ph')), 
    1, 1, '{}'
),

(
    (SELECT id FROM publications WHERE title = 'Algebraic Structures in Cryptography'), 
    (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='ejlacson@up.edu.ph')), 
    1, 1, '{}'
),
(
    (SELECT id FROM publications WHERE title = 'Non-Linear Dynamics of Tropical Cyclones'), 
    (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='kjmanansala@up.edu.ph')), 
    1, 1, '{}'
),

(
    (SELECT id FROM publications WHERE title = 'Synthesis of Biodegradable Polymers from Algae'), 
    (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='rpquintos@up.edu.ph')), 
    1, 1, '{}'
),
(
    (SELECT id FROM publications WHERE title = 'Computational Modelling of Protein Folding'), 
    (SELECT id FROM authors WHERE person_id=(SELECT id FROM persons WHERE email='vmramos@up.edu.ph')), 
    1, 1, '{}'
);