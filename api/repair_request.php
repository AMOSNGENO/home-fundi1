<?php
require_once __DIR__ . '/helpers.php';

try {
    $user = require_role('customer');
    $data = input();
    require_fields($data, ['customer_id', 'appliance_id', 'description', 'address']);
    if ((int)$data['customer_id'] !== (int)$user['id']) fail('Cannot create a request for another customer.', 403);
    $technician = null;
    $techStmt = db()->query("
        SELECT u.id, u.name, u.phone, COUNT(rr.id) AS active_jobs
        FROM users u
        LEFT JOIN repair_requests rr
            ON rr.technician_id = u.id
            AND rr.status IN ('accepted', 'in_progress')
        WHERE u.role = 'technician'
            AND u.is_approved = 1
            AND u.is_available = 1
            AND u.account_status = 'active'
        GROUP BY u.id, u.name, u.phone
        ORDER BY active_jobs ASC, u.id ASC
        LIMIT 1
    ");
    $technician = $techStmt->fetch() ?: null;
    $status = $technician ? 'accepted' : 'pending';

    $stmt = db()->prepare('INSERT INTO repair_requests (customer_id, technician_id, appliance_id, description, preferred_date, preferred_time, address, latitude, longitude, status, estimated_cost) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
    $stmt->execute([
        $user['id'],
        $technician['id'] ?? null,
        $data['appliance_id'],
        $data['description'],
        $data['preferred_date'] ?? null,
        $data['preferred_time'] ?? null,
        $data['address'],
        $data['latitude'] ?? null,
        $data['longitude'] ?? null,
        $status,
        $data['estimated_cost'] ?? null
    ]);
    $id = (int)db()->lastInsertId();

    if ($technician) {
        notify_user((int)$technician['id'], 'New assigned job', 'A customer repair request has been assigned to you.');
        notify_user((int)$user['id'], 'Technician assigned', $technician['name'] . ' has been assigned to your repair request.');
    } else {
        foreach (db()->query("SELECT id FROM users WHERE role = 'technician' AND is_approved = 1") as $tech) {
            notify_user((int)$tech['id'], 'New repair job', 'A customer posted a new repair request.');
        }
    }
    respond('success', $technician ? 'Repair request created and technician assigned.' : 'Repair request created.', [
        'request_id' => $id,
        'status' => $status,
        'assigned_technician' => $technician ? [
            'id' => (int)$technician['id'],
            'name' => $technician['name'],
            'phone' => $technician['phone'],
        ] : null,
    ], 201);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
