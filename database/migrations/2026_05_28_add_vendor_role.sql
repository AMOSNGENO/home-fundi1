ALTER TABLE users
    MODIFY role ENUM('customer', 'technician', 'admin', 'vendor') DEFAULT 'customer';

INSERT INTO users (name, email, password, phone, address, role, is_approved, api_token)
SELECT 'Test Vendor',
       'vendor@test.com',
       SHA2('password123', 256),
       '+254700000004',
       'Nairobi',
       'vendor',
       TRUE,
       'seed_vendor_token'
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE email = 'vendor@test.com'
);
