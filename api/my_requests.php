<?php
require_once __DIR__ . '/helpers.php';

try {
    $user = require_role('customer');
    $customerId = (int)($_GET['customer_id'] ?? 0);
    if ($customerId !== (int)$user['id']) fail('Cannot view another customer requests.', 403);
    respond('success', 'Requests loaded.', ['requests' => request_rows('WHERE rr.customer_id = ?', [$customerId])]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
