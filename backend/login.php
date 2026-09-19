<?php
require __DIR__ . '/config.php';

$body = read_json_body();
$identifier = trim($body['identifier'] ?? '');
$password = (string)($body['password'] ?? '');

if ($identifier === '' || $password === '') {
    respond(['success' => false, 'message' => 'Please fill all fields'], 400);
}

$pdo = db();
$stmt = $pdo->prepare('SELECT id, username, email, password_hash FROM users WHERE username = ? OR email = ?');
$stmt->execute([$identifier, $identifier]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password_hash'])) {
    respond(['success' => false, 'message' => 'Invalid username or password'], 401);
}

respond([
    'success' => true,
    'message' => 'Logged in',
    'user' => [
        'user_id' => (int)$user['id'],
        'username' => $user['username'],
        'email' => $user['email'],
    ],
]);