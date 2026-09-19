<?php
require __DIR__ . '/config.php';

$body = read_json_body();
$userId = (int)($body['user_id'] ?? 0);
$memoryDate = trim($body['memory_date'] ?? '');

if ($userId <= 0 || $memoryDate === '') {
    respond(['success' => false, 'message' => 'user_id and memory_date are required'], 400);
}

$pdo = db();
$stmt = $pdo->prepare('SELECT image_url FROM memories WHERE user_id = ? AND memory_date = ?');
$stmt->execute([$userId, $memoryDate]);
$memory = $stmt->fetch();

if (!$memory) {
    respond(['success' => false, 'message' => 'Memory not found'], 404);
}

$stmt = $pdo->prepare('DELETE FROM memories WHERE user_id = ? AND memory_date = ?');
$stmt->execute([$userId, $memoryDate]);

$file = __DIR__ . '/uploads/' . $memory['image_url'];
if (is_file($file)) {
    @unlink($file);
}

respond(['success' => true, 'message' => 'Memory deleted']);