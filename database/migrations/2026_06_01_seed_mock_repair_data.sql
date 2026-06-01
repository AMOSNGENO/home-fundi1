USE home_fundi;

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
)
SELECT
    (SELECT id FROM users WHERE email = 'customer@test.com'),
    NULL,
    (SELECT id FROM appliances WHERE name = 'Dishwasher'),
    'Dishwasher is not draining and leaves water at the bottom after each wash.',
    DATE_ADD(CURDATE(), INTERVAL 1 DAY),
    'Morning',
    'Kilimani, Nairobi',
    -1.2921000,
    36.8219000,
    'pending',
    2500.00,
    NULL,
    DATE_SUB(NOW(), INTERVAL 2 HOUR),
    NULL
WHERE NOT EXISTS (
    SELECT 1
    FROM repair_requests rr
    JOIN appliances a ON a.id = rr.appliance_id
    WHERE a.name = 'Dishwasher'
      AND rr.description = 'Dishwasher is not draining and leaves water at the bottom after each wash.'
);

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
)
SELECT
    (SELECT id FROM users WHERE email = 'customer@test.com'),
    (SELECT id FROM users WHERE email = 'tech@test.com'),
    (SELECT id FROM appliances WHERE name = 'Washing Machine'),
    'Washer shakes loudly during spin cycle and sometimes stops before draining.',
    CURDATE(),
    'Afternoon',
    'Westlands, Nairobi',
    -1.2676000,
    36.8108000,
    'accepted',
    3500.00,
    NULL,
    DATE_SUB(NOW(), INTERVAL 1 DAY),
    NULL
WHERE NOT EXISTS (
    SELECT 1
    FROM repair_requests rr
    JOIN appliances a ON a.id = rr.appliance_id
    WHERE a.name = 'Washing Machine'
      AND rr.description = 'Washer shakes loudly during spin cycle and sometimes stops before draining.'
);

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
)
SELECT
    (SELECT id FROM users WHERE email = 'customer@test.com'),
    (SELECT id FROM users WHERE email = 'tech@test.com'),
    (SELECT id FROM appliances WHERE name = 'Refrigerator'),
    'Fridge is running but not cooling the lower compartment.',
    DATE_SUB(CURDATE(), INTERVAL 1 DAY),
    'Evening',
    'South B, Nairobi',
    -1.3197000,
    36.8441000,
    'in_progress',
    4500.00,
    NULL,
    DATE_SUB(NOW(), INTERVAL 2 DAY),
    NULL
WHERE NOT EXISTS (
    SELECT 1
    FROM repair_requests rr
    JOIN appliances a ON a.id = rr.appliance_id
    WHERE a.name = 'Refrigerator'
      AND rr.description = 'Fridge is running but not cooling the lower compartment.'
);

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
)
SELECT
    (SELECT id FROM users WHERE email = 'customer@test.com'),
    (SELECT id FROM users WHERE email = 'tech@test.com'),
    (SELECT id FROM appliances WHERE name = 'Microwave'),
    'Microwave turns on but does not heat food.',
    DATE_SUB(CURDATE(), INTERVAL 5 DAY),
    'Morning',
    'Lavington, Nairobi',
    -1.2803000,
    36.7698000,
    'completed',
    2000.00,
    1800.00,
    DATE_SUB(NOW(), INTERVAL 7 DAY),
    DATE_SUB(NOW(), INTERVAL 5 DAY)
WHERE NOT EXISTS (
    SELECT 1
    FROM repair_requests rr
    JOIN appliances a ON a.id = rr.appliance_id
    WHERE a.name = 'Microwave'
      AND rr.description = 'Microwave turns on but does not heat food.'
);

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
)
SELECT
    (SELECT id FROM users WHERE email = 'customer@test.com'),
    NULL,
    (SELECT id FROM appliances WHERE name = 'Television'),
    'TV screen flickers and sound cuts out after a few minutes.',
    DATE_SUB(CURDATE(), INTERVAL 2 DAY),
    'Any time',
    'Embakasi, Nairobi',
    -1.3172000,
    36.9003000,
    'cancelled',
    3000.00,
    NULL,
    DATE_SUB(NOW(), INTERVAL 4 DAY),
    NULL
WHERE NOT EXISTS (
    SELECT 1
    FROM repair_requests rr
    JOIN appliances a ON a.id = rr.appliance_id
    WHERE a.name = 'Television'
      AND rr.description = 'TV screen flickers and sound cuts out after a few minutes.'
);

INSERT INTO ratings (repair_request_id, customer_id, technician_id, rating, review, created_at)
SELECT
    rr.id,
    (SELECT id FROM users WHERE email = 'customer@test.com'),
    (SELECT id FROM users WHERE email = 'tech@test.com'),
    5,
    'Quick diagnosis and the microwave has worked well since the repair.',
    DATE_SUB(NOW(), INTERVAL 4 DAY)
FROM repair_requests rr
JOIN appliances a ON a.id = rr.appliance_id
WHERE a.name = 'Microwave'
  AND rr.status = 'completed'
  AND NOT EXISTS (SELECT 1 FROM ratings r WHERE r.repair_request_id = rr.id)
LIMIT 1;

INSERT INTO notifications (user_id, title, message, is_read, created_at)
SELECT
    (SELECT id FROM users WHERE email = 'customer@test.com'),
    'Request accepted',
    'Your washing machine repair request has been accepted by Test Technician.',
    FALSE,
    DATE_SUB(NOW(), INTERVAL 18 HOUR)
WHERE NOT EXISTS (
    SELECT 1 FROM notifications
    WHERE title = 'Request accepted'
      AND message = 'Your washing machine repair request has been accepted by Test Technician.'
);

INSERT INTO notifications (user_id, title, message, is_read, created_at)
SELECT
    (SELECT id FROM users WHERE email = 'tech@test.com'),
    'New job available',
    'A dishwasher repair request is waiting for a technician.',
    FALSE,
    DATE_SUB(NOW(), INTERVAL 2 HOUR)
WHERE NOT EXISTS (
    SELECT 1 FROM notifications
    WHERE title = 'New job available'
      AND message = 'A dishwasher repair request is waiting for a technician.'
);

INSERT INTO notifications (user_id, title, message, is_read, created_at)
SELECT
    (SELECT id FROM users WHERE email = 'admin@test.com'),
    'Mock data ready',
    'Sample repair requests, ratings and notifications were added for testing.',
    TRUE,
    DATE_SUB(NOW(), INTERVAL 1 HOUR)
WHERE NOT EXISTS (
    SELECT 1 FROM notifications
    WHERE title = 'Mock data ready'
      AND message = 'Sample repair requests, ratings and notifications were added for testing.'
);
