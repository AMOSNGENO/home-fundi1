<?php
require_once __DIR__ . '/helpers.php';

try {
    $data = input();
    require_fields($data, ['name', 'email', 'password', 'phone', 'role']);
    if (!in_array($data['role'], ['customer', 'technician'], true)) {
        fail('Registration role must be customer or technician.', 400);
    }
    $token = bin2hex(random_bytes(32));
    $expiresAt = (new DateTimeImmutable('+7 days'))->format('Y-m-d H:i:s');
    $approved = $data['role'] === 'customer' ? 1 : 0;
    $stmt = db()->prepare('INSERT INTO users (name, email, password, phone, address, role, is_approved, skills, api_token, token_expires_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
    $stmt->execute([
        $data['name'],
        $data['email'],
        password_hash($data['password'], PASSWORD_DEFAULT),
        $data['phone'],
        $data['address'] ?? null,
        $data['role'],
        $approved,
        $data['skills'] ?? null,
        $token,
        $expiresAt,
    ]);
    $id = (int)db()->lastInsertId();
    $stmt = db()->prepare('SELECT id, name, email, phone, address, role, account_status, is_approved, is_available, skills, profile_image, token_expires_at FROM users WHERE id = ?');
    $stmt->execute([$id]);
    $user = $stmt->fetch();
    $user['token'] = $token;
    respond('success', 'Registration successful.', ['user' => $user], 201);
} catch (PDOException $e) {
    fail($e->getCode() === '23000' ? 'Email already exists.' : 'Database error.', 400);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
