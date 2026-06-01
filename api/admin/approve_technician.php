<?php
require_once __DIR__ . '/../helpers.php';

try {
    require_role('admin');
    $data = input();
    require_fields($data, ['user_id']);
    $approved = !empty($data['approved']) ? 1 : 0;
    $stmt = db()->prepare("UPDATE users SET is_approved = ? WHERE id = ? AND role = 'technician'");
    $stmt->execute([$approved, $data['user_id']]);
    if ($stmt->rowCount() === 0) fail('Technician not found.', 404);
    notify_user((int)$data['user_id'], 'Technician approval updated', $approved ? 'Your technician account was approved.' : 'Your technician registration was rejected.');
    respond('success', 'Technician approval updated.');
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
