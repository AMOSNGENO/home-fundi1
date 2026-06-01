<?php
require_once __DIR__ . '/helpers.php';

try {
    $user = require_role('technician');
    $technicianId = (int)($_GET['technician_id'] ?? 0);
    if ($technicianId !== (int)$user['id']) fail('Cannot view another technician jobs.', 403);
    respond('success', 'Jobs loaded.', ['jobs' => request_rows('WHERE rr.technician_id = ?', [$technicianId])]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
