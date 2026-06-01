ALTER TABLE users
    ADD COLUMN account_status ENUM('active', 'suspended', 'pending') DEFAULT 'active' AFTER role,
    ADD COLUMN token_expires_at DATETIME NULL AFTER api_token;

CREATE TABLE IF NOT EXISTS login_attempts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    identifier VARCHAR(150) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_login_attempts_window (identifier, ip_address, attempted_at)
);
