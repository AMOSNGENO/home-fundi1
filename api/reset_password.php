<?php
require_once __DIR__ . '/helpers.php';

try {
    $data = input();
    require_fields($data, ['email', 'token', 'password']);

    $email = strtolower(trim((string)$data['email']));
    $plainToken = trim((string)$data['token']);
    $password = (string)$data['password'];

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        fail('Enter a valid email address.', 400);
    }
    if (strlen($password) < 6) {
        fail('Password must be at least 6 characters.', 400);
    }

    $stmt = db()->prepare(
        'SELECT prt.id token_id, prt.token_hash, prt.expires_at, u.id user_id
         FROM password_reset_tokens prt
         JOIN users u ON u.id = prt.user_id
         WHERE u.email = ?
         ORDER BY prt.created_at DESC
         LIMIT 1'
    );
    $stmt->execute([$email]);
    $reset = $stmt->fetch();

    if (!$reset || strtotime((string)$reset['expires_at']) < time()) {
        fail('The password reset token is invalid or expired.', 400);
    }
    if (!hash_equals((string)$reset['token_hash'], hash('sha256', $plainToken))) {
        fail('The password reset token is invalid or expired.', 400);
    }

    db()->prepare('UPDATE users SET password = ?, api_token = NULL, token_expires_at = NULL WHERE id = ?')
        ->execute([password_hash($password, PASSWORD_DEFAULT), $reset['user_id']]);
    db()->prepare('DELETE FROM password_reset_tokens WHERE user_id = ?')->execute([$reset['user_id']]);

    respond('success', 'Password reset successful. You can log in with your new password.');
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
