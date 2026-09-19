<?php
require __DIR__ . '/config.php';
require __DIR__ . '/smtp.php';

$body = read_json_body();
$action = $body['action'] ?? 'request';
$email = strtolower(trim($body['email'] ?? ''));

$pdo = db();
$now = date('Y-m-d H:i:s');

if ($action === 'request') {
    if ($email === '') respond(['success' => false, 'message' => 'Email is required'], 400);

    $stmt = $pdo->prepare('SELECT id FROM users WHERE email = ?');
    $stmt->execute([$email]);
    if (!$stmt->fetch()) {
        respond(['success' => true, 'message' => 'If account exists, code was sent.']);
    }

    $token = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);
    $expires = date('Y-m-d H:i:s', strtotime('+15 minutes'));

    $stmt = $pdo->prepare('DELETE FROM reset_tokens WHERE email = ?');
    $stmt->execute([$email]);

    $stmt = $pdo->prepare('INSERT INTO reset_tokens (email, token, expires_at) VALUES (?, ?, ?)');
    $stmt->execute([$email, $token, $expires]);

    $sent = send_reset_code($email, $token);
    if ($sent === true) {
        respond(['success' => true, 'message' => 'Verification code sent to your email.']);
    } else {
        respond(['success' => false, 'message' => 'Failed to send email.', 'debug' => $sent], 500);
    }
}

if ($action === 'verify') {
    $code = trim($body['code'] ?? '');
    if ($email === '' || $code === '') respond(['success' => false, 'message' => 'Email and code required'], 400);

    $stmt = $pdo->prepare('SELECT id FROM reset_tokens WHERE email = ? AND token = ? AND expires_at > ?');
    $stmt->execute([$email, $code, $now]);
    if ($stmt->fetch()) {
        respond(['success' => true, 'message' => 'Code verified.']);
    } else {
        respond(['success' => false, 'message' => 'Invalid or expired code.'], 400);
    }
}

if ($action === 'update') {
    $code = trim($body['code'] ?? '');
    $newPassword = $body['password'] ?? '';

    if ($email === '' || $code === '' || strlen($newPassword) < 6) {
        respond(['success' => false, 'message' => 'Valid input required'], 400);
    }

    $stmt = $pdo->prepare('SELECT id FROM reset_tokens WHERE email = ? AND token = ? AND expires_at > ?');
    $stmt->execute([$email, $code, $now]);
    if (!$stmt->fetch()) {
        respond(['success' => false, 'message' => 'Session expired. Restart process.'], 400);
    }

    $hash = password_hash($newPassword, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare('UPDATE users SET password_hash = ? WHERE email = ?');
    $stmt->execute([$hash, $email]);

    $stmt = $pdo->prepare('DELETE FROM reset_tokens WHERE email = ?');
    $stmt->execute([$email]);

    respond(['success' => true, 'message' => 'Password updated successfully.']);
}

respond(['success' => false, 'message' => 'Invalid action'], 400);
