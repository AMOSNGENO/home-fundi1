<?php
require_once __DIR__ . '/../helpers.php';

try {
    require_role('admin');
    $data = input();
    require_fields($data, ['request_id', 'technician_id']);
    $check = db()->prepare("SELECT id FROM users WHERE id = ? AND role = 'technician' AND is_approved = 1");
    $check->execute([$data['technician_id']]);
    if (!$check->fetch()) fail('Approved technician not found.', 404);
    $stmt = db()->prepare("UPDATE repair_requests SET technician_id = ?, status = 'accepted' WHERE id = ? AND status IN ('pending', 'accepted')");
    $stmt->execute([$data['technician_id'], $data['request_id']]);
    if ($stmt->rowCount() === 0) fail('Request not found or cannot be assigned.', 404);
    $request = db()->prepare('SELECT customer_id FROM repair_requests WHERE id = ?');
    $request->execute([$data['request_id']]);
    $customerId = $request->fetchColumn();
    notify_user((int)$data['technician_id'], 'Job assigned', 'An admin assigned a repair request to you.');
    if ($customerId) {
        notify_user((int)$customerId, 'Technician assigned', 'A technician has been assigned to your repair request.');
    }
    respond('success', 'Technician assigned.');
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
