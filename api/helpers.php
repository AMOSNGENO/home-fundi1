<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

function input(): array {
    $raw = file_get_contents('php://input');
    $json = $raw ? json_decode($raw, true) : [];
    return is_array($json) ? $json : $_POST;
}

function respond(string $status, string $message, array $data = [], int $code = 200): void {
    http_response_code($code);
    echo json_encode(['status' => $status, 'message' => $message, 'data' => $data]);
    exit;
}

function fail(string $message, int $code = 400): void {
    respond('error', $message, [], $code);
}

function token(): ?string {
    $header = $_SERVER['HTTP_AUTHORIZATION']
        ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION']
        ?? $_SERVER['Authorization']
        ?? '';
    if ($header === '' && function_exists('apache_request_headers')) {
        $headers = apache_request_headers();
        $header = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    }
    if (preg_match('/Bearer\s+(.+)/', $header, $matches)) {
        return trim($matches[1]);
    }
    return $_SERVER['HTTP_X_AUTH_TOKEN'] ?? null;
}

function current_user(): array {
    $token = token();
    if (!$token) {
        fail('Authentication token is required.', 401);
    }
    $stmt = db()->prepare('SELECT id, name, email, phone, address, role, account_status, is_approved, is_available, skills, profile_image, api_token, token_expires_at FROM users WHERE api_token = ?');
    $stmt->execute([$token]);
    $user = $stmt->fetch();
    if (!$user) {
        fail('Invalid or expired token.', 401);
    }
    if (($user['account_status'] ?? 'active') === 'suspended') {
        fail('Your account has been suspended.', 403);
    }
    if (!empty($user['token_expires_at']) && strtotime((string)$user['token_expires_at']) < time()) {
        db()->prepare('UPDATE users SET api_token = NULL, token_expires_at = NULL WHERE id = ?')->execute([$user['id']]);
        fail('Your session has expired. Please log in again.', 401);
    }
    return $user;
}

function require_role(array|string $roles): array {
    $user = current_user();
    $allowed = is_array($roles) ? $roles : [$roles];
    if (!in_array($user['role'], $allowed, true)) {
        fail('You do not have permission to perform this action.', 403);
    }
    if ($user['role'] === 'technician' && (int)$user['is_approved'] !== 1) {
        fail('Technician account is pending admin approval.', 403);
    }
    return $user;
}

function require_fields(array $data, array $fields): void {
    foreach ($fields as $field) {
        if (!isset($data[$field]) || trim((string)$data[$field]) === '') {
            fail("$field is required.", 400);
        }
    }
}

function save_base64_upload(?string $data, ?string $name, string $folder): ?string {
    if (!$data || trim($data) === '') {
        return null;
    }
    if (strpos($data, ',') !== false) {
        $data = substr($data, strpos($data, ',') + 1);
    }
    $binary = base64_decode($data, true);
    if ($binary === false || strlen($binary) > 5 * 1024 * 1024) {
        fail('Image must be a valid file up to 5MB.', 400);
    }
    $extension = strtolower(pathinfo((string)$name, PATHINFO_EXTENSION));
    if (!in_array($extension, ['jpg', 'jpeg', 'png', 'webp'], true)) {
        $extension = 'jpg';
    }
    $root = __DIR__ . '/uploads/' . trim($folder, '/');
    if (!is_dir($root) && !mkdir($root, 0775, true) && !is_dir($root)) {
        fail('Could not prepare upload folder.', 500);
    }
    $filename = bin2hex(random_bytes(12)) . '.' . $extension;
    $path = $root . '/' . $filename;
    if (file_put_contents($path, $binary) === false) {
        fail('Could not save image.', 500);
    }
    return 'uploads/' . trim($folder, '/') . '/' . $filename;
}

function request_rows(string $where = '', array $params = []): array {
    $sql = "SELECT rr.*, a.name appliance_name,
                   c.name customer_name, c.email customer_email, c.phone customer_phone,
                   t.name technician_name
            FROM repair_requests rr
            JOIN appliances a ON a.id = rr.appliance_id
            JOIN users c ON c.id = rr.customer_id
            LEFT JOIN users t ON t.id = rr.technician_id $where
            ORDER BY rr.created_at DESC";
    $stmt = db()->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchAll();
}

function notify_user(int $userId, string $title, string $message): void {
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
    $stmt = db()->prepare('INSERT INTO notifications (user_id, title, message) VALUES (?, ?, ?)');
    $stmt->execute([$userId, $title, $message]);
}
