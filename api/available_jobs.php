<?php
require_once __DIR__ . '/helpers.php';

try {
    require_role('technician');
    respond('success', 'Available jobs loaded.', ['jobs' => request_rows("WHERE rr.status = 'pending' AND rr.technician_id IS NULL")]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
