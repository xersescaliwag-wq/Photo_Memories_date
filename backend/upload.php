<?php
require __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    respond(['success' => false, 'message' => 'Method not allowed'], 405);
}

$userId = (int)($_POST['user_id'] ?? 0);
$memoryDate = trim($_POST['memory_date'] ?? '');

if ($userId <= 0 || $memoryDate === '') {
    respond(['success' => false, 'message' => 'user_id and memory_date are required'], 400);
}

if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $memoryDate)) {
    respond(['success' => false, 'message' => 'memory_date must be YYYY-MM-DD'], 400);
}

$today = (new DateTime('today'))->format('Y-m-d');
if ($memoryDate > $today) {
    respond(['success' => false, 'message' => 'Future dates are not allowed'], 400);
}

if (!isset($_FILES['file'])) {
    $max_upload = ini_get('upload_max_filesize');
    $max_post = ini_get('post_max_size');
    respond(['success' => false, 'message' => "No file was received by the server. Your file might be larger than the server limit (Upload Limit: $max_upload, Post Limit: $max_post)."], 400);
}

if ($_FILES['file']['error'] !== UPLOAD_ERR_OK) {
    $errorCodes = [
        1 => 'The uploaded file exceeds the upload_max_filesize directive in php.ini',
        2 => 'The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form',
        3 => 'The uploaded file was only partially uploaded',
        4 => 'No file was uploaded',
        6 => 'Missing a temporary folder',
        7 => 'Failed to write file to disk',
        8 => 'A PHP extension stopped the file upload',
    ];
    $errCode = $_FILES['file']['error'];
    $errMessage = $errorCodes[$errCode] ?? 'Unknown upload error';
    respond(['success' => false, 'message' => "File upload error ($errCode): $errMessage"], 400);
}

$file = $_FILES['file'];
$allowed = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];

if (!class_exists('finfo')) {
    // Fallback if fileinfo extension is disabled
    $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
    $mime = $file['type'];
} else {
    $finfo = new finfo(FILEINFO_MIME_TYPE);
    $mime = $finfo->file($file['tmp_name']);
}

if (!isset($allowed[$mime])) {
    respond(['success' => false, 'message' => 'Only JPG, PNG, or WEBP images are allowed. Got: ' . $mime], 400);
}
if ($file['size'] > 10 * 1024 * 1024) {
    respond(['success' => false, 'message' => 'Image must be under 10 MB'], 400);
}

$ext = $allowed[$mime];
$filename = $memoryDate . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
$uploadDir = __DIR__ . '/uploads/';

// Create uploads directory if it doesn't exist
if (!is_dir($uploadDir)) {
    if (!mkdir($uploadDir, 0775, true)) {
        respond(['success' => false, 'message' => 'Upload directory does not exist and could not be created.'], 500);
    }
}

// Check if directory is writable
if (!is_writable($uploadDir)) {
    respond(['success' => false, 'message' => 'Upload directory is not writable. Please check folder permissions (775 or 777).'], 500);
}

$destination = $uploadDir . $filename;

if (!move_uploaded_file($file['tmp_name'], $destination)) {
    $error = error_get_last();
    respond([
        'success' => false,
        'message' => 'Failed to save image. Server error: ' . ($error['message'] ?? 'Unknown error')
    ], 500);
}

$pdo = db();

$stmt = $pdo->prepare('SELECT image_url FROM memories WHERE user_id = ? AND memory_date = ?');
$stmt->execute([$userId, $memoryDate]);
$existing = $stmt->fetch();

$stmt = $pdo->prepare(
    'INSERT INTO memories (user_id, memory_date, image_url) VALUES (?, ?, ?)
     ON DUPLICATE KEY UPDATE image_url = VALUES(image_url)'
);
$stmt->execute([$userId, $memoryDate, $filename]);

if ($existing) {
    $oldFile = __DIR__ . '/uploads/' . $existing['image_url'];
    if ($oldFile !== $destination && is_file($oldFile)) {
        @unlink($oldFile);
    }
}

respond([
    'success' => true,
    'message' => 'Memory saved',
    'memory' => ['memory_date' => $memoryDate, 'image_url' => $filename],
], 201);