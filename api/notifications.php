<?php
require_once __DIR__ . '/helpers.php';

try {
    $user = current_user();
    if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
        db()->prepare('UPDATE notifications SET is_read = TRUE WHERE user_id = ?')->execute([$user['id']]);
        respond('success', 'Notifications marked as read.');
    }

    $stmt = db()->prepare('SELECT id, title, message, is_read, created_at FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 50');
    $stmt->execute([$user['id']]);
    respond('success', 'Notifications loaded.', ['notifications' => $stmt->fetchAll()]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
