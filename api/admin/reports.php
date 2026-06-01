<?php
require_once __DIR__ . '/../helpers.php';

try {
    require_role('admin');
    $completed = db()->query("SELECT COUNT(*) FROM repair_requests WHERE status = 'completed'")->fetchColumn();
    $revenue = db()->query("SELECT COALESCE(SUM(actual_cost), 0) FROM repair_requests WHERE status = 'completed'")->fetchColumn();
    $rating = db()->query('SELECT COALESCE(AVG(rating), 0) FROM ratings')->fetchColumn();
    $byStatus = db()->query('SELECT status, COUNT(*) total FROM repair_requests GROUP BY status')->fetchAll();
    respond('success', 'Reports generated.', [
        'completed_jobs' => (int)$completed,
        'revenue' => (float)$revenue,
        'average_rating' => round((float)$rating, 2),
        'requests_by_status' => $byStatus,
    ]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
