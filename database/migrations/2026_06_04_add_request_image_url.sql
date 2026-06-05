SET @add_request_image_url = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE repair_requests ADD COLUMN request_image_url VARCHAR(255) NULL AFTER actual_cost',
        'SELECT "request_image_url column already exists"'
    )
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'repair_requests'
      AND COLUMN_NAME = 'request_image_url'
);
PREPARE stmt FROM @add_request_image_url;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
