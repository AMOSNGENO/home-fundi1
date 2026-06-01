<?php
require_once __DIR__ . '/helpers.php';

try {
    $user = current_user();
    db()->prepare('UPDATE users SET api_token = NULL, token_expires_at = NULL WHERE id = ?')->execute([$user['id']]);
    respond('success', 'Logout successful.');
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
