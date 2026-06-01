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

function request_rows(string $where = '', array $params = []): array {
    $sql = "SELECT rr.*, a.name appliance_name, c.name customer_name, t.name technician_name
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
    $stmt = db()->prepare('INSERT INTO notifications (user_id, title, message) VALUES (?, ?, ?)');
    $stmt->execute([$userId, $title, $message]);
}
