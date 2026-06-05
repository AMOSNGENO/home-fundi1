<?php
require_once __DIR__ . '/helpers.php';

try {
    $data = input();
    require_fields($data, ['password']);
    $identifier = trim((string)($data['login'] ?? $data['email'] ?? $data['phone'] ?? $data['username'] ?? ''));
    if ($identifier === '') {
        fail('Email, phone, or username is required.', 400);
    }
    $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $windowStart = (new DateTimeImmutable('-15 minutes'))->format('Y-m-d H:i:s');
    $attempts = db()->prepare('SELECT COUNT(*) FROM login_attempts WHERE identifier = ? AND ip_address = ? AND attempted_at >= ?');
    $attempts->execute([$identifier, $ip, $windowStart]);
    if ((int)$attempts->fetchColumn() >= 5) {
        fail('Too many login attempts. Try again later.', 429);
    }

    $stmt = db()->prepare('SELECT * FROM users WHERE email = ? OR phone = ? OR name = ? LIMIT 1');
    $stmt->execute([$identifier, $identifier, $identifier]);
    $user = $stmt->fetch();
    $valid = $user && password_verify($data['password'], $user['password']);
    $legacySeedValid = $user && hash_equals($user['password'], hash('sha256', $data['password']));
    if (!$valid && !$legacySeedValid) {
        db()->prepare('INSERT INTO login_attempts (identifier, ip_address) VALUES (?, ?)')->execute([$identifier, $ip]);
        fail('Invalid email or password.', 401);
    }
    if (($user['account_status'] ?? 'active') === 'suspended') {
        fail('Your account has been suspended. Contact support.', 403);
    }
    $token = bin2hex(random_bytes(32));
    $expiresAt = (new DateTimeImmutable('+7 days'))->format('Y-m-d H:i:s');
    $newHash = $legacySeedValid ? password_hash($data['password'], PASSWORD_DEFAULT) : $user['password'];
    db()->prepare('UPDATE users SET api_token = ?, token_expires_at = ?, password = ? WHERE id = ?')->execute([$token, $expiresAt, $newHash, $user['id']]);
    db()->prepare('DELETE FROM login_attempts WHERE identifier = ? AND ip_address = ?')->execute([$identifier, $ip]);
    $user['fullname'] = $user['name'];
    $user['token_expires_at'] = $expiresAt;
    unset($user['password'], $user['api_token']);

    echo json_encode([
        'success' => true,
        'token' => $token,
        'expires_at' => $expiresAt,
        'user' => $user,
    ]);
    exit;
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
