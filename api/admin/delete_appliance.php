<?php
require_once __DIR__ . '/../helpers.php';

try {
    require_role('admin');
    $data = input();
    require_fields($data, ['id']);
    $stmt = db()->prepare('DELETE FROM appliances WHERE id = ?');
    $stmt->execute([$data['id']]);
    if ($stmt->rowCount() === 0) fail('Appliance not found.', 404);
    respond('success', 'Appliance deleted.');
} catch (PDOException $e) {
    fail('Cannot delete an appliance that is linked to repair requests.', 400);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
