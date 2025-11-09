CREATE DATABASE HealthCareLinkApp;
-- connect to the database
\c HealthCareLinkApp;

-- Users Table for signup
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    fullname VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phonenumber VARCHAR(20),
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    
);

ALTER TABLE users ADD COLUMN profile_image TEXT;

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

-- Insert Sample Clinics
INSERT INTO clinics (name, address, phonenumber, email, latitude, longitude, services, operating_hours)
VALUES
('Kenyatta National Hospital', 'Hospital Rd, Upper Hill, Nairobi', '+254 20 2726300', 'knhadmin@knh.or.ke', -1.3018, 36.8073,
 ARRAY['Emergency', 'Surgery', 'Pediatrics'],
 '{"monday":"08:00-17:00","tuesday":"08:00-17:00","wednesday":"08:00-17:00","thursday":"08:00-17:00","friday":"08:00-17:00","saturday":"09:00-13:00","sunday":"Closed"}'),

('Aga Khan University Hospital', '3rd Parklands Ave, Nairobi', '+254 20 3662000', 'akuh.nairobi@aku.edu', -1.2684, 36.8148,
 ARRAY['Emergency', 'Cardiology', 'Oncology'],
 '{"monday":"08:00-17:00","tuesday":"08:00-17:00","wednesday":"08:00-17:00","thursday":"08:00-17:00","friday":"08:00-15:00","saturday":"09:00-13:00","sunday":"Closed"}'),

('Nairobi Hospital', 'Argwings Kodhek Rd, Nairobi', '+254 20 2845000', 'hosp@nbihosp.org', -1.2907, 36.7907,
 ARRAY['Emergency', 'Maternity', 'Surgery'],
 '{"monday":"08:00-18:00","tuesday":"08:00-18:00","wednesday":"08:00-18:00","thursday":"08:00-18:00","friday":"08:00-18:00","saturday":"09:00-14:00","sunday":"Closed"}'),

('Gertrudes Children Hospital', 'Muthaiga Rd, Nairobi', '+254 20 7206000', 'info@gerties.org', -1.2490, 36.8284,
 ARRAY['Pediatrics', 'Emergency', 'Vaccination'],
 '{"monday":"08:00-17:00","tuesday":"08:00-17:00","wednesday":"08:00-17:00","thursday":"08:00-17:00","friday":"08:00-17:00","saturday":"09:00-12:00","sunday":"Closed"}');

-- Health Tips Table
CREATE TABLE health_tips (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE health_tips 
ADD COLUMN category VARCHAR(100) DEFAULT 'General';

INSERT INTO health_tips (title, content, category) VALUES
('Stay Hydrated', 'Drink at least 6-8 glasses of clean water every day to support circulation, digestion, and healthy skin.', 'Nutrition'),
('Balanced Diet', 'Include fruits, vegetables, whole grains, and lean proteins in your daily meals to boost your immune system.', 'Nutrition'),
('Regular Exercise', 'Aim for at least 30 minutes of physical activity daily. Walking, jogging, or cycling are great options.', 'Physical Activity'),
('Adequate Sleep', 'Adults should get 7-9 hours of sleep every night to support mental and physical health.', 'Lifestyle'),
('Hand Hygiene', 'Wash your hands regularly with soap and running water for at least 20 seconds to prevent infections.', 'Hygiene'),
('Limit Sugar Intake', 'Reduce consumption of sugary beverages and snacks to maintain healthy blood sugar levels.', 'Nutrition'),
('Manage Stress', 'Practice relaxation techniques such as deep breathing, meditation, or listening to calming music.', 'Mental Health'),
('Stay Vaccinated', 'Keep your immunizations up to date to reduce the risk of preventable diseases.', 'Medical Care'),
('Avoid Smoking', 'Tobacco use harms nearly every organ in the body. Quitting improves health at any age.', 'Lifestyle'),
('Sun Protection', 'Wear sunscreen when outdoors to protect your skin from harmful UV rays and reduce skin cancer risk.', 'Lifestyle'),
('Healthy Breakfast', 'Start your day with a nutritious breakfast to maintain energy and concentration throughout the day.', 'Nutrition'),
('Stay Active at Work', 'Take short walking or stretching breaks every hour to prevent stiffness and improve circulation.', 'Physical Activity'),
('Drink Herbal Teas', 'Herbal teas like ginger, chamomile, and peppermint promote relaxation and good digestion.', 'Nutrition'),
('Eat More Fiber', 'Include whole grains, beans, fruits, and vegetables to improve digestion and prevent constipation.', 'Nutrition'),
('Moderate Salt Intake', 'Use less salt when cooking and avoid highly processed foods to support healthy blood pressure.', 'Nutrition'),
('Dental Care', 'Brush twice a day and floss daily to maintain good oral hygiene and prevent gum disease.', 'Hygiene'),
('Healthy Snacking', 'Choose nuts, fruits, or yogurt instead of sugary snacks for sustained energy.', 'Nutrition'),
('Stay Connected', 'Spend meaningful time with friends and family to support emotional well-being.', 'Mental Health'),
('Limit Screen Time', 'Reduce time spent on phones and screens, especially before bedtime, to improve sleep quality.', 'Lifestyle'),
('Proper Posture', 'Maintain good posture while sitting and standing to reduce back and neck strain.', 'Lifestyle'),
('Cook at Home More Often', 'Preparing meals at home allows better control of ingredients and supports healthier eating.', 'Nutrition'),
('Listen to Your Body', 'Rest when you feel tired and seek medical attention when symptoms persist.', 'General Wellness'),
('Practice Gratitude', 'Reflecting on positive experiences daily can reduce anxiety and improve mood.', 'Mental Health'),
('Stay Informed', 'Get health information from credible sources and consult professionals instead of self-diagnosing.', 'General Wellness'),
('Routine Checkups', 'Visit your healthcare provider regularly for screenings and preventative care.', 'Medical Care');

-- Symptoms checker Table
CREATE TABLE symptoms_checker (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id) ON DELETE CASCADE,
  symptom VARCHAR(255) NOT NULL,
  severity VARCHAR(20) CHECK (severity IN ('low', 'medium', 'high')),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Health Alerts/ Warnings Table
CREATE TABLE health_alerts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  severity VARCHAR(20) CHECK (severity IN ('low', 'medium', 'high')),
  location VARCHAR(255),
  alert_type VARCHAR(50),
  icon VARCHAR(50),
  is_active BOOLEAN DEFAULT true,
  published_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert Sample Health Alerts
INSERT INTO health_alerts (title, message, severity, location, alert_type, icon) VALUES
('Flu Season Alert', 'Flu cases are rising in Nairobi. Get your flu shot and practice good hygiene.', 'high', 'Nairobi', 'disease_outbreak', 'virus'),
('Free Health Screening', 'Kenyatta National Hospital is offering free diabetes screening this weekend.', 'medium', 'Nairobi', 'health_service', 'hospital'),
('Water Quality Warning', 'Boil water before drinking in Kibera area due to contamination concerns.', 'high', 'Kibera, Nairobi', 'safety_alert', 'water'),
('Mental Health Webinar', 'Join us for a free webinar on stress management and mental wellness.', 'low', 'Online', 'health_education', 'brain'),
('Heatwave Alert', 'High temperatures expected in Mombasa this week. Stay hydrated and avoid outdoor activities during peak hours.', 'medium', 'Mombasa', 'weather_alert', 'sun'),
('COVID-19 Vaccination Drive', 'Free COVID-19 vaccination drive this weekend at City Hall grounds.', 'high', 'Nairobi', 'vaccination_campaign', 'syringe'),
('Malaria Prevention Tips', 'Use mosquito nets and repellents as malaria cases increase in Kisumu region.', 'medium', 'Kisumu', 'health_advisory', 'mosquito'),
('Blood Donation Drive', 'Help save lives — donate blood at Aga Khan Hospital on Friday.', 'low', 'Nairobi', 'community_event', 'blood'),
('Air Pollution Warning', 'Air quality is poor in Industrial Area, Nairobi. Limit outdoor activities.', 'high', 'Industrial Area, Nairobi', 'environment_alert', 'smog'),
('Child Immunization Reminder', 'Ensure your child receives scheduled immunizations at your nearest health center.', 'medium', 'Nationwide', 'public_health', 'baby');

-- Create Indexes
-- Indexes for users table
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

-- Indexes for clinics table
CREATE INDEX idx_clinics_name ON clinics(name);
CREATE INDEX idx_clinics_location ON clinics(latitude, longitude); 
CREATE INDEX idx_clinics_services ON clinics USING GIN (services);  
CREATE INDEX idx_clinics_operating_hours ON clinics USING GIN (operating_hours); 

-- Index for health_tips table
CREATE INDEX idx_health_tips_title ON health_tips(title);

-- Indexes for symptoms_checker table
CREATE INDEX idx_symptoms_user_id ON symptoms_checker(user_id);
CREATE INDEX idx_symptoms_severity ON symptoms_checker(severity);

-- Indexes for health_alerts table
CREATE INDEX idx_alerts_severity ON health_alerts(severity);
CREATE INDEX idx_alerts_location ON health_alerts(location);
CREATE INDEX idx_alerts_type ON health_alerts(alert_type);
CREATE INDEX idx_alerts_is_active ON health_alerts(is_active);





















