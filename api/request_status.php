<?php
require_once __DIR__ . '/helpers.php';

try {
    $user = require_role(['customer', 'technician', 'admin']);
    $id = (int)($_GET['request_id'] ?? 0);
    $rows = request_rows('WHERE rr.id = ?', [$id]);
    if (!$rows) fail('Request not found.', 404);
    $request = $rows[0];
    $isOwner = (int)$request['customer_id'] === (int)$user['id'];
    $isAssignedTechnician = !empty($request['technician_id']) && (int)$request['technician_id'] === (int)$user['id'];
    if ($user['role'] !== 'admin' && !$isOwner && !$isAssignedTechnician) {
        fail('You do not have permission to view this request.', 403);
    }
    respond('success', 'Request status loaded.', ['request' => $request]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
