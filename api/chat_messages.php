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

function can_use_request_chat(array $user, int $requestId, int $recipientId): array {
    $stmt = db()->prepare('SELECT * FROM repair_requests WHERE id = ? LIMIT 1');
    $stmt->execute([$requestId]);
    $request = $stmt->fetch();
    if (!$request) {
        fail('Repair request not found.', 404);
    }
    $isParticipant =
        (int)$request['customer_id'] === (int)$user['id'] ||
        (int)$request['technician_id'] === (int)$user['id'] ||
        $user['role'] === 'admin';
    if (!$isParticipant) {
        fail('You cannot view this chat.', 403);
    }
    $recipient = db()->prepare('SELECT role FROM users WHERE id = ? LIMIT 1');
    $recipient->execute([$recipientId]);
    $recipientRow = $recipient->fetch();
    if (!$recipientRow) {
        fail('Recipient not found.', 404);
    }
    $isValidRecipient =
        (int)$request['customer_id'] === $recipientId ||
        (int)$request['technician_id'] === $recipientId ||
        $recipientRow['role'] === 'admin';
    if (!$isValidRecipient) {
        fail('Recipient is not part of this repair request.', 403);
    }
    return $request;
}

function can_use_direct_chat(array $user, int $recipientId): void {
    $stmt = db()->prepare('SELECT role FROM users WHERE id = ? LIMIT 1');
    $stmt->execute([$recipientId]);
    $recipient = $stmt->fetch();
    if (!$recipient) {
        fail('Recipient not found.', 404);
    }
    $allowed =
        ($user['role'] === 'technician' && $recipient['role'] === 'admin') ||
        ($user['role'] === 'admin' && $recipient['role'] === 'technician');
    if (!$allowed) {
        fail('Direct chat is only available between technicians and admins.', 403);
    }
}

try {
    ensure_chat_messages_table();
    $user = current_user();
    $data = $_SERVER['REQUEST_METHOD'] === 'POST' ? input() : $_GET;
    $recipientId = (int)($data['recipient_id'] ?? 0);
    $requestId = isset($data['request_id']) && $data['request_id'] !== ''
        ? (int)$data['request_id']
        : null;
    if ($recipientId <= 0) {
        fail('recipient_id is required.', 400);
    }

    if ($requestId !== null) {
        can_use_request_chat($user, $requestId, $recipientId);
    } else {
        can_use_direct_chat($user, $recipientId);
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        require_fields($data, ['message']);
        $message = trim((string)$data['message']);
        if ($message === '') {
            fail('Message cannot be empty.', 400);
        }
        $stmt = db()->prepare('INSERT INTO chat_messages (repair_request_id, sender_id, recipient_id, message) VALUES (?, ?, ?, ?)');
        $stmt->execute([$requestId, $user['id'], $recipientId, $message]);
        $preview = strlen($message) > 80 ? substr($message, 0, 77) . '...' : $message;
        notify_user($recipientId, 'New message', $user['name'] . ': ' . $preview);
        $messageId = (int)db()->lastInsertId();
        respond('success', 'Message sent.', [
            'message' => [
                'id' => $messageId,
                'sender_id' => $user['id'],
                'sender_name' => $user['name'],
                'message' => $message,
                'is_mine' => true,
                'created_at' => date('Y-m-d H:i:s'),
            ],
        ]);
    }

    if ($requestId !== null) {
        db()->prepare(
            'UPDATE chat_messages SET is_read = TRUE
             WHERE repair_request_id = ? AND recipient_id = ? AND sender_id = ?'
        )->execute([$requestId, $user['id'], $recipientId]);
        $stmt = db()->prepare(
            'SELECT cm.id, cm.sender_id, u.name sender_name, cm.message, cm.created_at,
                    CASE WHEN cm.sender_id = ? THEN 1 ELSE 0 END is_mine
             FROM chat_messages cm
             JOIN users u ON u.id = cm.sender_id
             WHERE cm.repair_request_id = ?
               AND ((cm.sender_id = ? AND cm.recipient_id = ?) OR (cm.sender_id = ? AND cm.recipient_id = ?))
             ORDER BY cm.created_at ASC'
        );
        $stmt->execute([$user['id'], $requestId, $user['id'], $recipientId, $recipientId, $user['id']]);
    } else {
        db()->prepare(
            'UPDATE chat_messages SET is_read = TRUE
             WHERE repair_request_id IS NULL AND recipient_id = ? AND sender_id = ?'
        )->execute([$user['id'], $recipientId]);
        $stmt = db()->prepare(
            'SELECT cm.id, cm.sender_id, u.name sender_name, cm.message, cm.created_at,
                    CASE WHEN cm.sender_id = ? THEN 1 ELSE 0 END is_mine
             FROM chat_messages cm
             JOIN users u ON u.id = cm.sender_id
             WHERE cm.repair_request_id IS NULL
               AND ((cm.sender_id = ? AND cm.recipient_id = ?) OR (cm.sender_id = ? AND cm.recipient_id = ?))
             ORDER BY cm.created_at ASC'
        );
        $stmt->execute([$user['id'], $user['id'], $recipientId, $recipientId, $user['id']]);
    }

    respond('success', 'Messages loaded.', ['messages' => $stmt->fetchAll()]);
} catch (Throwable $e) {
    fail('Server error: ' . $e->getMessage(), 500);
}
