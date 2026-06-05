CREATE DATABASE IF NOT EXISTS home_fundi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE home_fundi;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    role ENUM('customer', 'technician', 'admin', 'vendor') DEFAULT 'customer',
    account_status ENUM('active', 'suspended', 'pending') DEFAULT 'active',
    is_approved BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    skills TEXT,
    profile_image VARCHAR(255),
    api_token VARCHAR(128) UNIQUE,
    token_expires_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE login_attempts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    identifier VARCHAR(150) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_login_attempts_window (identifier, ip_address, attempted_at)
);

CREATE TABLE password_reset_tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    token_hash VARCHAR(64) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_password_reset_user (user_id),
    INDEX idx_password_reset_expires (expires_at)
);

CREATE TABLE appliances (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    description TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE repair_requests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    technician_id INT DEFAULT NULL,
    appliance_id INT NOT NULL,
    description TEXT,
    preferred_date DATE,
    preferred_time VARCHAR(50),
    address TEXT NOT NULL,
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    status ENUM('pending', 'accepted', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    estimated_cost DECIMAL(10,2),
    actual_cost DECIMAL(10,2),
    request_image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (technician_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (appliance_id) REFERENCES appliances(id)
);

CREATE TABLE ratings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    repair_request_id INT NOT NULL,
    customer_id INT NOT NULL,
    technician_id INT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_request_rating (repair_request_id),
    FOREIGN KEY (repair_request_id) REFERENCES repair_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (technician_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(100),
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE chat_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    repair_request_id INT NULL,
    sender_id INT NOT NULL,
    recipient_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (repair_request_id) REFERENCES repair_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_chat_request (repair_request_id),
    INDEX idx_chat_users (sender_id, recipient_id),
    INDEX idx_chat_recipient_read (recipient_id, is_read)
);

INSERT INTO users (name, email, password, phone, address, role, is_approved, api_token) VALUES
('Test Customer', 'customer@test.com', SHA2('password123', 256), '+254700000001', 'Nairobi', 'customer', TRUE, 'seed_customer_token'),
('Test Technician', 'tech@test.com', SHA2('password123', 256), '+254700000002', 'Nairobi', 'technician', TRUE, 'seed_tech_token'),
('System Admin', 'admin@test.com', SHA2('admin123', 256), '+254700000003', 'Tricom Technologies', 'admin', TRUE, 'seed_admin_token'),
('Test Vendor', 'vendor@test.com', SHA2('password123', 256), '+254700000004', 'Nairobi', 'vendor', TRUE, 'seed_vendor_token');

INSERT INTO appliances (name, category, description, image_url) VALUES
('Refrigerator', 'Kitchen', 'Fridge cooling, compressor, thermostat and gas issues', ''),
('Washing Machine', 'Laundry', 'Washer leaks, spin, drainage and motor issues', ''),
('Cooker/Oven', 'Kitchen', 'Gas and electric cooker repair', ''),
('Microwave', 'Kitchen', 'Heating and electrical faults', ''),
('Television', 'Electronics', 'Display, power and sound repairs', ''),
('Dishwasher', 'Kitchen', 'Drainage, water inlet, pump and control faults', ''),
('Freezer', 'Kitchen', 'Cooling, thermostat, compressor and seal issues', ''),
('Water Dispenser', 'Kitchen', 'Heating, cooling, leakage and pump faults', ''),
('Electric Kettle', 'Kitchen', 'Heating element, switch and power faults', ''),
('Blender', 'Kitchen', 'Motor, blade, jar and switch repairs', ''),
('Food Processor', 'Kitchen', 'Motor, gear, blade and bowl lock faults', ''),
('Toaster', 'Kitchen', 'Heating, lever, timer and wiring issues', ''),
('Coffee Maker', 'Kitchen', 'Brewing, heating, pump and leakage faults', ''),
('Rice Cooker', 'Kitchen', 'Heating plate, thermostat and switch faults', ''),
('Air Fryer', 'Kitchen', 'Heating element, fan and control board issues', ''),
('Iron', 'Laundry', 'Heating, thermostat, steam and cable faults', ''),
('Dryer', 'Laundry', 'Heating, drum, belt and sensor faults', ''),
('Vacuum Cleaner', 'Cleaning', 'Suction, motor, hose and filter issues', ''),
('Water Heater', 'Bathroom', 'Heating element, thermostat and leakage faults', ''),
('Shower Heater', 'Bathroom', 'Instant shower heating, wiring and pressure faults', ''),
('Air Conditioner', 'Climate', 'Cooling, gas refill, fan and compressor issues', ''),
('Fan', 'Climate', 'Motor, speed control, blade and oscillation faults', ''),
('Heater', 'Climate', 'Heating element, thermostat and power faults', ''),
('Sound System', 'Electronics', 'Power, speaker, amplifier and Bluetooth issues', ''),
('Home Theatre', 'Electronics', 'Audio, HDMI, power and speaker faults', ''),
('Generator', 'Power', 'Starting, fuel, alternator and wiring faults', ''),
('Inverter/UPS', 'Power', 'Battery, charging, output and board faults', ''),
('Solar Water Pump', 'Power', 'Pump, wiring, controller and panel faults', ''),
('Security Camera/CCTV', 'Security', 'Camera, DVR, wiring and network faults', ''),
('Electric Gate Motor', 'Security', 'Motor, remote, sensor and power faults', ''),
('Sewing Machine', 'General', 'Motor, belt, needle timing and pedal issues', '');

INSERT INTO repair_requests (
    customer_id,
    technician_id,
    appliance_id,
    description,
    preferred_date,
    preferred_time,
    address,
    latitude,
    longitude,
    status,
    estimated_cost,
    actual_cost,
    created_at,
    completed_at
) VALUES
((SELECT id FROM users WHERE email = 'customer@test.com'), NULL, (SELECT id FROM appliances WHERE name = 'Dishwasher'), 'Dishwasher is not draining and leaves water at the bottom after each wash.', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'Morning', 'Kilimani, Nairobi', -1.2921000, 36.8219000, 'pending', 2500.00, NULL, DATE_SUB(NOW(), INTERVAL 2 HOUR), NULL),
((SELECT id FROM users WHERE email = 'customer@test.com'), (SELECT id FROM users WHERE email = 'tech@test.com'), (SELECT id FROM appliances WHERE name = 'Washing Machine'), 'Washer shakes loudly during spin cycle and sometimes stops before draining.', CURDATE(), 'Afternoon', 'Westlands, Nairobi', -1.2676000, 36.8108000, 'accepted', 3500.00, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), NULL),
((SELECT id FROM users WHERE email = 'customer@test.com'), (SELECT id FROM users WHERE email = 'tech@test.com'), (SELECT id FROM appliances WHERE name = 'Refrigerator'), 'Fridge is running but not cooling the lower compartment.', DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Evening', 'South B, Nairobi', -1.3197000, 36.8441000, 'in_progress', 4500.00, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), NULL),
((SELECT id FROM users WHERE email = 'customer@test.com'), (SELECT id FROM users WHERE email = 'tech@test.com'), (SELECT id FROM appliances WHERE name = 'Microwave'), 'Microwave turns on but does not heat food.', DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Morning', 'Lavington, Nairobi', -1.2803000, 36.7698000, 'completed', 2000.00, 1800.00, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
((SELECT id FROM users WHERE email = 'customer@test.com'), NULL, (SELECT id FROM appliances WHERE name = 'Television'), 'TV screen flickers and sound cuts out after a few minutes.', DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Any time', 'Embakasi, Nairobi', -1.3172000, 36.9003000, 'cancelled', 3000.00, NULL, DATE_SUB(NOW(), INTERVAL 4 DAY), NULL);

INSERT INTO ratings (repair_request_id, customer_id, technician_id, rating, review, created_at) VALUES
((SELECT rr.id FROM repair_requests rr JOIN appliances a ON a.id = rr.appliance_id WHERE a.name = 'Microwave' AND rr.status = 'completed' LIMIT 1), (SELECT id FROM users WHERE email = 'customer@test.com'), (SELECT id FROM users WHERE email = 'tech@test.com'), 5, 'Quick diagnosis and the microwave has worked well since the repair.', DATE_SUB(NOW(), INTERVAL 4 DAY));

INSERT INTO notifications (user_id, title, message, is_read, created_at) VALUES
((SELECT id FROM users WHERE email = 'customer@test.com'), 'Request accepted', 'Your washing machine repair request has been accepted by Test Technician.', FALSE, DATE_SUB(NOW(), INTERVAL 18 HOUR)),
((SELECT id FROM users WHERE email = 'tech@test.com'), 'New job available', 'A dishwasher repair request is waiting for a technician.', FALSE, DATE_SUB(NOW(), INTERVAL 2 HOUR)),
((SELECT id FROM users WHERE email = 'admin@test.com'), 'Mock data ready', 'Sample repair requests, ratings and notifications were added for testing.', TRUE, DATE_SUB(NOW(), INTERVAL 1 HOUR));
