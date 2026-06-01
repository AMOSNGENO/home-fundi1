USE home_fundi;

SET @add_latitude = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE repair_requests ADD COLUMN latitude DECIMAL(10,7) NULL AFTER address',
        'SELECT "latitude column already exists"'
    )
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'repair_requests'
      AND COLUMN_NAME = 'latitude'
);
PREPARE stmt FROM @add_latitude;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_longitude = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE repair_requests ADD COLUMN longitude DECIMAL(10,7) NULL AFTER latitude',
        'SELECT "longitude column already exists"'
    )
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'repair_requests'
      AND COLUMN_NAME = 'longitude'
);
PREPARE stmt FROM @add_longitude;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
