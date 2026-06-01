<?php
require_once __DIR__ . '/../helpers.php';

try {
    require_role('admin');
    $data = input();
    require_fields($data, ['name']);
    $stmt = db()->prepare('INSERT INTO appliances (name, category, description, image_url) VALUES (?, ?, ?, ?)');
    $stmt->execute([$data['name'], $data['category'] ?? null, $data['description'] ?? null, $data['image_url'] ?? null]);
    respond('success', 'Appliance added.', ['id' => (int)db()->lastInsertId()], 201);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
