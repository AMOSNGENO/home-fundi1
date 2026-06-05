<?php
require_once __DIR__ . '/helpers.php';

function ensure_chat_messages_table(): void {
    db()->exec(
        'CREATE TABLE IF NOT EXISTS chat_messages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            repair_request_id INT NULL,
            sender_id INT NOT NULL,
            recipient_id INT NOT NULL,
            message TEXT NOT NULL,
            is_read BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (repair_request_id) REFERENCES repair_requests(id) ON DELETE CASCADE,
            FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE,
            INDEX idx_chat_request (repair_request_id),
            INDEX idx_chat_users (sender_id, recipient_id),
            INDEX idx_chat_recipient_read (recipient_id, is_read)
        )'
    );
}

function last_chat_message(?int $requestId, int $userId, int $recipientId): array {
    if ($requestId !== null) {
        $stmt = db()->prepare(
            'SELECT message, created_at FROM chat_messages
             WHERE repair_request_id = ?
               AND ((sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?))
             ORDER BY created_at DESC LIMIT 1'
        );
        $stmt->execute([$requestId, $userId, $recipientId, $recipientId, $userId]);
    } else {
        $stmt = db()->prepare(
            'SELECT message, created_at FROM chat_messages
             WHERE repair_request_id IS NULL
               AND ((sender_id = ? AND recipient_id = ?) OR (sender_id = ? AND recipient_id = ?))
             ORDER BY created_at DESC LIMIT 1'
        );
        $stmt->execute([$userId, $recipientId, $recipientId, $userId]);
    }
    return $stmt->fetch() ?: ['message' => '', 'created_at' => ''];
}

function unread_chat_count(?int $requestId, int $userId, int $senderId): int {
    if ($requestId !== null) {
        $stmt = db()->prepare(
            'SELECT COUNT(*) FROM chat_messages
             WHERE repair_request_id = ? AND recipient_id = ? AND sender_id = ? AND is_read = FALSE'
        );
        $stmt->execute([$requestId, $userId, $senderId]);
    } else {
        $stmt = db()->prepare(
            'SELECT COUNT(*) FROM chat_messages
             WHERE repair_request_id IS NULL AND recipient_id = ? AND sender_id = ? AND is_read = FALSE'
        );
        $stmt->execute([$userId, $senderId]);
    }
    return (int)$stmt->fetchColumn();
}

try {
    ensure_chat_messages_table();
    $user = current_user();
    $threads = [];

    if ($user['role'] === 'technician') {
        $stmt = db()->prepare(
            "SELECT rr.id request_id, rr.status, a.name appliance_name, c.id customer_id,
                    c.name customer_name
             FROM repair_requests rr
             JOIN appliances a ON a.id = rr.appliance_id
             JOIN users c ON c.id = rr.customer_id
             WHERE rr.technician_id = ?
             ORDER BY rr.created_at DESC"
        );
        $stmt->execute([$user['id']]);
        foreach ($stmt->fetchAll() as $row) {
            $last = last_chat_message((int)$row['request_id'], (int)$user['id'], (int)$row['customer_id']);
            $threads[] = [
                'id' => 'request-' . $row['request_id'],
                'title' => $row['customer_name'],
                'subtitle' => $row['appliance_name'] . ' - ' . str_replace('_', ' ', $row['status']),
                'request_id' => $row['request_id'],
                'recipient_id' => $row['customer_id'],
                'recipient_role' => 'customer',
                'last_message' => $last['message'],
                'last_message_at' => $last['created_at'],
                'unread_count' => unread_chat_count((int)$row['request_id'], (int)$user['id'], (int)$row['customer_id']),
            ];
        }

        $admins = db()->query("SELECT id, name FROM users WHERE role = 'admin' ORDER BY name")->fetchAll();
        foreach ($admins as $admin) {
            $last = last_chat_message(null, (int)$user['id'], (int)$admin['id']);
            $threads[] = [
                'id' => 'admin-' . $admin['id'],
                'title' => $admin['name'],
                'subtitle' => 'Admin support',
                'request_id' => null,
                'recipient_id' => $admin['id'],
                'recipient_role' => 'admin',
                'last_message' => $last['message'],
                'last_message_at' => $last['created_at'],
                'unread_count' => unread_chat_count(null, (int)$user['id'], (int)$admin['id']),
            ];
        }
    } else {
        fail('Chat threads are currently available for technicians.', 403);
    }

    usort($threads, function (array $a, array $b): int {
        $aTime = strtotime((string)($a['last_message_at'] ?? '')) ?: 0;
        $bTime = strtotime((string)($b['last_message_at'] ?? '')) ?: 0;
        return $bTime <=> $aTime;
    });

    respond('success', 'Chat threads loaded.', ['threads' => $threads]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
