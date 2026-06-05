<?php
require_once __DIR__ . '/helpers.php';

try {
    $user = require_role('technician');
    $data = input();
    if (isset($data['email']) && trim((string)$data['email']) !== '') {
        $email = trim((string)$data['email']);
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            fail('Enter a valid email address.', 400);
        }
        $exists = db()->prepare('SELECT id FROM users WHERE email = ? AND id <> ? LIMIT 1');
        $exists->execute([$email, $user['id']]);
        if ($exists->fetch()) {
            fail('That email is already used by another account.', 400);
        }
    }
    if (isset($data['phone']) && trim((string)$data['phone']) !== '') {
        $exists = db()->prepare('SELECT id FROM users WHERE phone = ? AND id <> ? LIMIT 1');
        $exists->execute([trim((string)$data['phone']), $user['id']]);
        if ($exists->fetch()) {
            fail('That phone number is already used by another account.', 400);
        }
    }
    $profileImage = save_base64_upload($data['profile_image_data'] ?? null, $data['profile_image_name'] ?? null, 'technicians');
    $stmt = db()->prepare('UPDATE users SET email = COALESCE(?, email), phone = COALESCE(?, phone), address = COALESCE(?, address), skills = COALESCE(?, skills), is_available = COALESCE(?, is_available), profile_image = COALESCE(?, profile_image) WHERE id = ?');
    $stmt->execute([
        isset($data['email']) && trim((string)$data['email']) !== '' ? trim((string)$data['email']) : null,
        isset($data['phone']) && trim((string)$data['phone']) !== '' ? trim((string)$data['phone']) : null,
        $data['address'] ?? null,
        $data['skills'] ?? null,
        $data['is_available'] ?? null,
        $profileImage ?? $data['profile_image'] ?? null,
        $user['id'],
    ]);
    $fresh = db()->prepare('SELECT id, name, email, phone, address, role, account_status, is_approved, is_available, skills, profile_image, token_expires_at FROM users WHERE id = ?');
    $fresh->execute([$user['id']]);
    respond('success', 'Technician profile updated.', ['user' => $fresh->fetch()]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
