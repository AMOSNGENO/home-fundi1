<?php
require_once __DIR__ . '/helpers.php';

try {
    $user = require_role('technician');
    $stmt = db()->prepare('SELECT r.*, c.name customer_name FROM ratings r JOIN users c ON c.id = r.customer_id WHERE r.technician_id = ? ORDER BY r.created_at DESC');
    $stmt->execute([$user['id']]);
    $ratings = $stmt->fetchAll();
    $avg = db()->prepare('SELECT AVG(rating) FROM ratings WHERE technician_id = ?');
    $avg->execute([$user['id']]);
    respond('success', 'Ratings loaded.', ['average' => round((float)$avg->fetchColumn(), 2), 'ratings' => $ratings]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
