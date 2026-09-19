<?php
require __DIR__ . '/config.php';
require __DIR__ . '/smtp.php';

$body = read_json_body();
$action = $body['action'] ?? 'request'; // 'request' or 'verify'
$email = strtolower(trim($body['email'] ?? ''));

$pdo = db();

if ($action === 'request') {
    $username = trim($body['username'] ?? '');
    $password = (string)($body['password'] ?? '');

    if ($username === '' || $email === '' || $password === '') {
        respond(['success' => false, 'message' => 'Please fill all fields'], 400);
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        respond(['success' => false, 'message' => 'Invalid email address format'], 400);
    }

    // Check if domain exists (MX Records)
    $domain = substr(strrchr($email, "@"), 1);
    if (!checkdnsrr($domain, "MX")) {
        respond(['success' => false, 'message' => "The email domain '@$domain' does not exist."], 400);
    }

    // Check if user already exists
    $stmt = $pdo->prepare('SELECT id FROM users WHERE username = ? OR email = ?');
    $stmt->execute([$username, $email]);
    if ($stmt->fetch()) {
        respond(['success' => false, 'message' => 'Username or email already registered'], 409);
    }

    // Generate Verification Code
    $code = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);
    $expires = date('Y-m-d H:i:s', strtotime('+30 minutes'));

    // Save to reset_tokens table (we reuse it for registration verification too)
    $stmt = $pdo->prepare('DELETE FROM reset_tokens WHERE email = ?');
    $stmt->execute([$email]);
    $stmt = $pdo->prepare('INSERT INTO reset_tokens (email, token, expires_at) VALUES (?, ?, ?)');
    $stmt->execute([$email, $code, $expires]);

    // Send Verification Email
    $sent = send_verification_code($email, $username, $code);
    if ($sent === true) {
        respond(['success' => true, 'message' => 'Verification code sent to your email.']);
    } else {
        respond(['success' => false, 'message' => 'Failed to send verification email.', 'debug' => $sent], 500);
    }
}

if ($action === 'verify') {
    $username = trim($body['username'] ?? '');
    $password = (string)($body['password'] ?? '');
    $code = trim($body['code'] ?? '');

    if ($username === '' || $email === '' || $password === '' || $code === '') {
        respond(['success' => false, 'message' => 'Missing required data'], 400);
    }

    // Verify the code
    $stmt = $pdo->prepare('SELECT id FROM reset_tokens WHERE email = ? AND token = ? AND expires_at > NOW()');
    $stmt->execute([$email, $code]);
    if (!$stmt->fetch()) {
        respond(['success' => false, 'message' => 'Invalid or expired verification code.'], 400);
    }

    // Code is valid, create the account
    $hash = password_hash($password, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare('INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)');
    try {
        $stmt->execute([$username, $email, $hash]);
        $userId = (int)$pdo->lastInsertId();

        // Cleanup token
        $stmt = $pdo->prepare('DELETE FROM reset_tokens WHERE email = ?');
        $stmt->execute([$email]);

        respond([
            'success' => true,
            'message' => 'Account verified and created!',
            'user' => ['user_id' => $userId, 'username' => $username, 'email' => $email],
        ], 201);
    } catch (PDOException $e) {
        respond(['success' => false, 'message' => 'Registration failed. User might have been created by another session.'], 500);
    }
}

respond(['success' => false, 'message' => 'Invalid action'], 400);
