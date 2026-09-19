<?php
require __DIR__ . '/db.php';

$file = basename($_GET['file'] ?? '');
if ($file === '' || !preg_match('/^[A-Za-z0-9_\-]+\.(jpe?g|png|webp)$/i', $file)) {
    respond(['success' => false, 'message' => 'Invalid file'], 400);
}

$path = __DIR__ . '/uploads/' . $file;
if (!is_file($path)) {
    respond(['success' => false, 'message' => 'File not found'], 404);
}

$mime = [
    'jpg' => 'image/jpeg',
    'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'webp' => 'image/webp',
][strtolower(pathinfo($file, PATHINFO_EXTENSION))];

header('Content-Type: ' . $mime);
header('Content-Disposition: attachment; filename="' . $file . '"');
header('Content-Length: ' . (string) filesize($path));
readfile($path);
exit;