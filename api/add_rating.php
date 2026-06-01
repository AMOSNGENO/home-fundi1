<?php
require_once __DIR__ . '/helpers.php';

try {
    $user = require_role('customer');
    $data = input();
    require_fields($data, ['repair_request_id', 'technician_id', 'rating']);
    $rating = (int)$data['rating'];
    if ($rating < 1 || $rating > 5) fail('Rating must be between 1 and 5.', 400);
    $stmt = db()->prepare("SELECT * FROM repair_requests WHERE id = ? AND customer_id = ? AND technician_id = ? AND status = 'completed'");
    $stmt->execute([$data['repair_request_id'], $user['id'], $data['technician_id']]);
    if (!$stmt->fetch()) fail('Completed request not found for rating.', 404);
    $stmt = db()->prepare('INSERT INTO ratings (repair_request_id, customer_id, technician_id, rating, review) VALUES (?, ?, ?, ?, ?)');
    $stmt->execute([$data['repair_request_id'], $user['id'], $data['technician_id'], $rating, $data['review'] ?? null]);
    respond('success', 'Rating saved.', [], 201);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
