<?php
require_once __DIR__ . '/helpers.php';

try {
    require_role(['customer', 'technician', 'admin', 'vendor']);
    $stmt = db()->query('SELECT * FROM appliances ORDER BY name');
    respond('success', 'Appliances loaded.', ['appliances' => $stmt->fetchAll()]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
