<?php
header('Content-Type: application/json');
echo json_encode([
    'status' => 'online',
    'service' => 'Photo Memories API',
    'version' => '1.0.0'
]);
