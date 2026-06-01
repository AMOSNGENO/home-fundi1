<?php
require_once __DIR__ . '/../helpers.php';

try {
    require_role('admin');
    $role = $_GET['role'] ?? null;
    if ($role) {
        $stmt = db()->prepare('SELECT id, name, email, phone, address, role, account_status, is_approved, is_available, skills, profile_image, token_expires_at, created_at FROM users WHERE role = ? ORDER BY created_at DESC');
        $stmt->execute([$role]);
    } else {
        $stmt = db()->query('SELECT id, name, email, phone, address, role, account_status, is_approved, is_available, skills, profile_image, token_expires_at, created_at FROM users ORDER BY created_at DESC');
    }
    respond('success', 'Users loaded.', ['users' => $stmt->fetchAll()]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
