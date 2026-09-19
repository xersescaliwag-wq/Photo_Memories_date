<?php
require __DIR__ . '/config.php';

$body = read_json_body();
$userId = (int)($body['user_id'] ?? 0);
$oldPassword = (string)($body['old_password'] ?? '');
$newPassword = (string)($body['new_password'] ?? '');

if ($userId <= 0 || $oldPassword === '' || $newPassword === '') {
    respond(['success' => false, 'message' => 'user_id, old_password and new_password are required'], 400);
}
if (strlen($newPassword) < 6) {
    respond(['success' => false, 'message' => 'New password must be at least 6 characters'], 400);
}

$pdo = db();
$stmt = $pdo->prepare('SELECT password_hash FROM users WHERE id = ?');
$stmt->execute([$userId]);
$user = $stmt->fetch();

if (!$user || !password_verify($oldPassword, $user['password_hash'])) {
    respond(['success' => false, 'message' => 'Incorrect old password'], 401);
}

$hash = password_hash($newPassword, PASSWORD_DEFAULT);
$stmt = $pdo->prepare('UPDATE users SET password_hash = ? WHERE id = ?');
$stmt->execute([$hash, $userId]);

respond(['success' => true, 'message' => 'Password updated']);