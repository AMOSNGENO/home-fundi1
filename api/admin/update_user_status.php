<?php
require_once __DIR__ . '/../helpers.php';

try {
    $admin = require_role('admin');
    $data = input();
    require_fields($data, ['user_id', 'account_status']);
    if (!in_array($data['account_status'], ['active', 'suspended', 'pending'], true)) {
        fail('Invalid account status.', 400);
    }
    if ((int)$data['user_id'] === (int)$admin['id'] && $data['account_status'] === 'suspended') {
        fail('You cannot suspend your own admin account.', 400);
    }
    $stmt = db()->prepare('UPDATE users SET account_status = ?, api_token = IF(? = "suspended", NULL, api_token), token_expires_at = IF(? = "suspended", NULL, token_expires_at) WHERE id = ?');
    $stmt->execute([$data['account_status'], $data['account_status'], $data['account_status'], $data['user_id']]);
    if ($stmt->rowCount() === 0) fail('User not found.', 404);
    respond('success', 'User account status updated.');
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
