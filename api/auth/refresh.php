<?php
require_once __DIR__ . '/../helpers.php';

try {
    $user = current_user();
    $token = bin2hex(random_bytes(32));
    $expiresAt = (new DateTimeImmutable('+7 days'))->format('Y-m-d H:i:s');
    db()->prepare('UPDATE users SET api_token = ?, token_expires_at = ? WHERE id = ?')->execute([$token, $expiresAt, $user['id']]);
    $user['token'] = $token;
    $user['token_expires_at'] = $expiresAt;
    unset($user['api_token']);
    respond('success', 'Session refreshed.', ['token' => $token, 'expires_at' => $expiresAt, 'user' => $user]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
