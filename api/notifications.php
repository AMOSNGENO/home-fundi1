<?php
require_once __DIR__ . '/helpers.php';

function ensure_notifications_table(): void {
    db()->exec(
        'CREATE TABLE IF NOT EXISTS notifications (
            id INT PRIMARY KEY AUTO_INCREMENT,
            user_id INT NOT NULL,
            title VARCHAR(100),
            message TEXT,
            is_read BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            INDEX idx_notifications_user_read (user_id, is_read, created_at)
        )'
    );
}

try {
    ensure_notifications_table();
    $user = current_user();
    if ($_SERVER['REQUEST_METHOD'] === 'PUT' || $_SERVER['REQUEST_METHOD'] === 'POST') {
        db()->prepare('UPDATE notifications SET is_read = TRUE WHERE user_id = ?')->execute([$user['id']]);
        respond('success', 'Notifications marked as read.');
    }

    $stmt = db()->prepare(
        'SELECT id, title, message, is_read, created_at
         FROM notifications
         WHERE user_id = ?
         ORDER BY created_at DESC
         LIMIT 50'
    );
    $stmt->execute([$user['id']]);
    respond('success', 'Notifications loaded.', ['notifications' => $stmt->fetchAll()]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
