<?php
require __DIR__ . '/config.php';

$userId = (int)($_GET['user_id'] ?? 0);
if ($userId <= 0) {
    respond(['success' => false, 'message' => 'user_id is required'], 400);
}

$sql = 'SELECT memory_date, image_url FROM memories WHERE user_id = ?';
$params = [$userId];

$year = $_GET['year'] ?? '';
$month = $_GET['month'] ?? '';
if ($year !== '' && $month !== '') {
    $sql .= ' AND YEAR(memory_date) = ? AND MONTH(memory_date) = ?';
    $params[] = (int)$year;
    $params[] = (int)$month;
} elseif ($year !== '') {
    $sql .= ' AND YEAR(memory_date) = ?';
    $params[] = (int)$year;
}

$sql .= ' ORDER BY memory_date ASC';

$pdo = db();
$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$rows = $stmt->fetchAll();

$memories = array_map(static function (array $row): array {
    return [
        'memory_date' => $row['memory_date'],
        'image_url' => $row['image_url'],
    ];
}, $rows);

respond(['success' => true, 'memories' => $memories]);