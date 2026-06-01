<?php
require_once __DIR__ . '/../helpers.php';

try {
    $admin = require_role('admin');
    $data = input();
    require_fields($data, ['user_id']);
    if ((int)$data['user_id'] === (int)$admin['id']) fail('Admin cannot delete own account.', 400);
    $stmt = db()->prepare('DELETE FROM users WHERE id = ?');
    $stmt->execute([$data['user_id']]);
    if ($stmt->rowCount() === 0) fail('User not found.', 404);
    respond('success', 'User deleted.');
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
