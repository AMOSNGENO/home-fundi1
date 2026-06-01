<?php
require_once __DIR__ . '/helpers.php';

try {
    $user = require_role('technician');
    $data = input();
    require_fields($data, ['request_id']);
    $stmt = db()->prepare("UPDATE repair_requests SET technician_id = ?, status = 'accepted' WHERE id = ? AND status = 'pending' AND technician_id IS NULL");
    $stmt->execute([$user['id'], $data['request_id']]);
    if ($stmt->rowCount() === 0) fail('Job is no longer available.', 400);
    $customer = db()->prepare('SELECT customer_id FROM repair_requests WHERE id = ?');
    $customer->execute([$data['request_id']]);
    notify_user((int)$customer->fetchColumn(), 'Technician assigned', 'A technician accepted your repair request.');
    respond('success', 'Job accepted.');
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
