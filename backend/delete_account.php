<?php
require __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    respond(['success' => false, 'message' => 'Method not allowed'], 405);
}

$body = read_json_body();
$userId = (int)($body['user_id'] ?? 0);

if ($userId <= 0) {
    respond(['success' => false, 'message' => 'user_id is required'], 400);
}

$pdo = db();

$stmt = $pdo->prepare('SELECT image_url FROM memories WHERE user_id = ?');
$stmt->execute([$userId]);
$memories = $stmt->fetchAll();

$stmt = $pdo->prepare('DELETE FROM memories WHERE user_id = ?');
$stmt->execute([$userId]);

foreach ($memories as $memory) {
    $file = __DIR__ . '/uploads/' . $memory['image_url'];
    if (is_file($file)) {
        @unlink($file);
    }
}

$stmt = $pdo->prepare('DELETE FROM users WHERE id = ?');
$stmt->execute([$userId]);

if ($stmt->rowCount() === 0) {
    respond(['success' => false, 'message' => 'User not found'], 404);
}

respond(['success' => true, 'message' => 'Account deleted']);