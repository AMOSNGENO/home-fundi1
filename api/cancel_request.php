<?php
require_once __DIR__ . '/helpers.php';

try {
    $user = require_role('customer');
    $data = input();
    require_fields($data, ['request_id']);
    $stmt = db()->prepare("UPDATE repair_requests SET status = 'cancelled' WHERE id = ? AND customer_id = ? AND status = 'pending'");
    $stmt->execute([$data['request_id'], $user['id']]);
    if ($stmt->rowCount() === 0) fail('Only pending requests can be cancelled.', 400);
    respond('success', 'Request cancelled.');
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
