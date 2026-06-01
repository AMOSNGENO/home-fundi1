<?php
require_once __DIR__ . '/helpers.php';

try {
    require_role('customer');
    $stmt = db()->prepare("SELECT id, name, email, phone, address, role, is_approved, is_available, skills, profile_image FROM users WHERE role = 'technician' AND is_approved = 1 ORDER BY name");
    $stmt->execute();
    respond('success', 'Technicians loaded.', ['technicians' => $stmt->fetchAll()]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
