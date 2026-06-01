<?php
require_once __DIR__ . '/../helpers.php';

try {
    $user = current_user();
    $user['token'] = $user['api_token'];
    unset($user['api_token']);
    respond('success', 'Session is valid.', ['user' => $user]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
