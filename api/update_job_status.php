<?php
require_once __DIR__ . '/helpers.php';

try {
    $user = require_role('technician');
    $data = input();
    require_fields($data, ['request_id', 'status']);
    if (!in_array($data['status'], ['in_progress', 'completed'], true)) fail('Invalid status transition.', 400);
    $completed = $data['status'] === 'completed' ? ', completed_at = NOW(), actual_cost = COALESCE(actual_cost, estimated_cost, 0)' : '';
    $stmt = db()->prepare("UPDATE repair_requests SET status = ? $completed WHERE id = ? AND technician_id = ? AND status IN ('accepted', 'in_progress')");
    $stmt->execute([$data['status'], $data['request_id'], $user['id']]);
    if ($stmt->rowCount() === 0) fail('Job not found or cannot be updated.', 404);
    $request = db()->prepare('SELECT customer_id FROM repair_requests WHERE id = ?');
    $request->execute([$data['request_id']]);
    $customerId = $request->fetchColumn();
    if ($customerId) {
        notify_user((int)$customerId, 'Service status updated', 'Your repair request is now ' . str_replace('_', ' ', $data['status']) . '.');
    }
    respond('success', 'Job status updated.');
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
