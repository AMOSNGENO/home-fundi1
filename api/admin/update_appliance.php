<?php
require_once __DIR__ . '/../helpers.php';

try {
    require_role('admin');
    $data = input();
    require_fields($data, ['id', 'name']);
    $stmt = db()->prepare('UPDATE appliances SET name = ?, category = ?, description = ?, image_url = ? WHERE id = ?');
    $stmt->execute([$data['name'], $data['category'] ?? null, $data['description'] ?? null, $data['image_url'] ?? null, $data['id']]);
    if ($stmt->rowCount() === 0) fail('Appliance not found or unchanged.', 404);
    respond('success', 'Appliance updated.');
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
