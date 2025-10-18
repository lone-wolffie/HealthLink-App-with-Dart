CREATE DATABASE HealthCareLinkApp;
\c HealthCareLinkApp;

-- Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    fullname VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phonenumber VARCHAR(20),
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    
);

-- Symptoms Table
CREATE TABLE symptoms (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    severity VARCHAR(20) CHECK (severity IN ('Mild', 'Moderate', 'Severe')),
    date_recorded TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Clinics Table
CREATE TABLE clinics (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    phonenumber VARCHAR(20),
    email VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    services TEXT[],
    operating_hours JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Health Alerts Table
CREATE TABLE health_alerts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    severity VARCHAR(20) CHECK (severity IN ('low', 'medium', 'high')),
    location VARCHAR(255),
    alert_type VARCHAR(50),
    icon VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    published_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Wellness Habits Table
CREATE TABLE wellness_habits (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    habit_type VARCHAR(100) NOT NULL,
    description TEXT,
    frequency VARCHAR(50),
    date_logged DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_symptoms_user_id ON symptoms(user_id);
CREATE INDEX idx_symptoms_date ON symptoms(date_recorded);
CREATE INDEX idx_clinics_location ON clinics(latitude, longitude);
CREATE INDEX idx_alerts_active ON health_alerts(is_active);

-- Insert Sample Clinics
INSERT INTO clinics (name, address, phonenumber, latitude, longitude, services, operating_hours)
VALUES
('Kenyatta National Hospital', 'Hospital Rd, Upper Hill, Nairobi', '+254 20 2726300', -1.3018, 36.8073,
 ARRAY['Emergency', 'Surgery', 'Pediatrics'],
 '{"monday":"08:00-17:00","tuesday":"08:00-17:00","wednesday":"08:00-17:00","thursday":"08:00-17:00","friday":"08:00-17:00","saturday":"09:00-13:00","sunday":"Closed"}'),

('Aga Khan University Hospital', '3rd Parklands Ave, Nairobi', '+254 20 3662000', -1.2684, 36.8148,
 ARRAY['Emergency', 'Cardiology', 'Oncology'],
 '{"monday":"08:00-17:00","tuesday":"08:00-17:00","wednesday":"08:00-17:00","thursday":"08:00-17:00","friday":"08:00-15:00","saturday":"09:00-13:00","sunday":"Closed"}'),

('Nairobi Hospital', 'Argwings Kodhek Rd, Nairobi', '+254 20 2845000', -1.2907, 36.7907,
 ARRAY['Emergency', 'Maternity', 'Surgery'],
 '{"monday":"08:00-18:00","tuesday":"08:00-18:00","wednesday":"08:00-18:00","thursday":"08:00-18:00","friday":"08:00-18:00","saturday":"09:00-14:00","sunday":"Closed"}'),

('Gertrudes Children Hospital', 'Muthaiga Rd, Nairobi', '+254 20 2722817', -1.2490, 36.8284,
 ARRAY['Pediatrics', 'Emergency', 'Vaccination'],
 '{"monday":"08:00-17:00","tuesday":"08:00-17:00","wednesday":"08:00-17:00","thursday":"08:00-17:00","friday":"08:00-17:00","saturday":"09:00-12:00","sunday":"Closed"}');


-- Insert Sample Health Alerts
INSERT INTO health_alerts (title, message, severity, location, alert_type, icon) VALUES
('Flu Season Alert', 'Flu cases are rising in Nairobi. Get your flu shot and practice good hygiene.', 'high', 'Nairobi', 'disease_outbreak', 'virus'),
('Free Health Screening', 'Kenyatta National Hospital is offering free diabetes screening this weekend.', 'medium', 'Nairobi', 'health_service', 'hospital'),
('Water Quality Warning', 'Boil water before drinking in Kibera area due to contamination concerns.', 'high', 'Kibera, Nairobi', 'safety_alert', 'water'),
('Mental Health Webinar', 'Join us for a free webinar on stress management and mental wellness.', 'low', 'Online', 'health_education', 'brain');





















-- CREATE TABLE signup (
--     id SERIAL PRIMARY KEY,
--     full_name VARCHAR(255) NOT NULL,
--     email_address VARCHAR(255) NOT NULL UNIQUE,
--     phone_number VARCHAR(20) NOT NULL UNIQUE,
--     username VARCHAR(50) NOT NULL UNIQUE,
--     password VARCHAR(255) NOT NULL 
-- );

-- CREATE TABLE users (
--   id SERIAL PRIMARY KEY,
--   full_name VARCHAR(100) NOT NULL,
--   email_address VARCHAR(150) UNIQUE NOT NULL,
--   password VARCHAR(255) NOT NULL,
--   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- CREATE TABLE symptoms (
--   id SERIAL PRIMARY KEY,
--   user_id INT REFERENCES users(id) ON DELETE CASCADE,
--   symptom TEXT NOT NULL,
--   severity VARCHAR(50),
--   notes TEXT,
--   date_recorded TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- CREATE TABLE health_tips (
--   id SERIAL PRIMARY KEY,
--   title TEXT NOT NULL,
--   description TEXT NOT NULL
-- );

-- CREATE TABLE clinics (
--   id SERIAL PRIMARY KEY,
--   name TEXT NOT NULL,
--   address TEXT,
--   lat TEXT,
--   lng TEXT,
--   contact TEXT
-- );


