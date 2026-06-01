<?php
require_once __DIR__ . '/helpers.php';

try {
    $user = require_role('technician');
    $data = input();
    $stmt = db()->prepare('UPDATE users SET phone = COALESCE(?, phone), address = COALESCE(?, address), skills = COALESCE(?, skills), is_available = COALESCE(?, is_available), profile_image = COALESCE(?, profile_image) WHERE id = ?');
    $stmt->execute([$data['phone'] ?? null, $data['address'] ?? null, $data['skills'] ?? null, $data['is_available'] ?? null, $data['profile_image'] ?? null, $user['id']]);
    respond('success', 'Technician profile updated.');
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
