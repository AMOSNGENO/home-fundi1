<?php
require_once __DIR__ . '/../helpers.php';

try {
    require_role('admin');
    $one = fn(string $sql) => db()->query($sql)->fetchColumn();
    respond('success', 'Dashboard stats loaded.', [
        'total_users' => (int)$one('SELECT COUNT(*) FROM users'),
        'total_technicians' => (int)$one("SELECT COUNT(*) FROM users WHERE role = 'technician'"),
        'total_requests' => (int)$one('SELECT COUNT(*) FROM repair_requests'),
        'completed_jobs' => (int)$one("SELECT COUNT(*) FROM repair_requests WHERE status = 'completed'"),
        'revenue' => (float)$one("SELECT COALESCE(SUM(actual_cost), 0) FROM repair_requests WHERE status = 'completed'"),
    ]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
