<?php
require_once __DIR__ . '/helpers.php';

try {
    $data = input();
    require_fields($data, ['email']);

    $email = strtolower(trim((string)$data['email']));
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        fail('Enter a valid email address.', 400);
    }

    $stmt = db()->prepare('SELECT id, name, email FROM users WHERE email = ? LIMIT 1');
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    $responseData = [];
    $message = 'If that email is registered, password reset instructions have been prepared.';

    if ($user) {
        $plainToken = bin2hex(random_bytes(32));
        $tokenHash = hash('sha256', $plainToken);
        $expiresAt = (new DateTimeImmutable('+' . PASSWORD_RESET_TOKEN_MINUTES . ' minutes'))->format('Y-m-d H:i:s');

        db()->prepare('DELETE FROM password_reset_tokens WHERE user_id = ? OR expires_at < NOW()')->execute([$user['id']]);
        db()->prepare('INSERT INTO password_reset_tokens (user_id, token_hash, expires_at) VALUES (?, ?, ?)')
            ->execute([$user['id'], $tokenHash, $expiresAt]);

        $resetUrl = reset_url($email, $plainToken);
        if (PASSWORD_RESET_FROM_EMAIL !== '') {
            $subject = 'Home Fundi password reset';
            $body = "Hello {$user['name']},\n\nUse this link to reset your Home Fundi password:\n{$resetUrl}\n\nThis link expires in " . PASSWORD_RESET_TOKEN_MINUTES . " minutes.";
            @mail($email, $subject, $body, 'From: ' . PASSWORD_RESET_FROM_EMAIL);
        }

        if (PASSWORD_RESET_DEV_MODE) {
            $responseData = [
                'reset_token' => $plainToken,
                'reset_url' => $resetUrl,
                'expires_at' => $expiresAt,
            ];
            $message = 'Password reset token created. Use it within ' . PASSWORD_RESET_TOKEN_MINUTES . ' minutes.';
        }
    }

    respond('success', $message, $responseData);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}

function reset_url(string $email, string $token): string {
    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? '127.0.0.1';
    $apiPath = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '/api')), '/');
    $basePath = preg_replace('#/api$#', '', $apiPath) ?: '';
    return $scheme . '://' . $host . $basePath . '/reset-password?email=' . rawurlencode($email) . '&token=' . rawurlencode($token);
}
