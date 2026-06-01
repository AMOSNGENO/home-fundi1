<?php
require_once __DIR__ . '/../helpers.php';

try {
    require_role('admin');
    $status = $_GET['status'] ?? null;
    if ($status) {
        respond('success', 'Repair requests loaded.', ['requests' => request_rows('WHERE rr.status = ?', [$status])]);
    }
    respond('success', 'Repair requests loaded.', ['requests' => request_rows()]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
