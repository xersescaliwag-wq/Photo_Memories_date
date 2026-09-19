<?php
// SMTP Configuration for Gmail using PHPMailer
// Use this for sending emails via jasslapos@gmail.com

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require __DIR__ . '/PHPMailer/src/Exception.php';
require __DIR__ . '/PHPMailer/src/PHPMailer.php';
require __DIR__ . '/PHPMailer/src/SMTP.php';

define('SMTP_HOST', 'smtp.gmail.com');
define('SMTP_PORT', 465); // SSL
define('SMTP_USER', 'jasslapos@gmail.com');
define('SMTP_PASS', 'rxel ilzn ajmb ywso');
define('SMTP_FROM', 'jasslapos@gmail.com');
define('SMTP_NAME', 'Photo Memories Support');

/**
 * Sends a 6-digit verification code for new account registration
 */
function send_verification_code($to_email, $username, $code) {
    return send_glass_email(
        $to_email,
        $username,
        'Verify Your Account',
        "Welcome to PHOTO MEMORIES! To complete your registration, please enter the following verification code:<br><br><span style='font-size: 32px; font-weight: 800; color: #007AFF; letter-spacing: 8px;'>$code</span><br><br>This code will expire in 30 minutes."
    );
}

/**
 * Sends a 6-digit verification code for password reset
 */
function send_reset_code($to_email, $code) {
    return send_glass_email(
        $to_email,
        'User',
        'Password Reset Code',
        "Your password reset verification code is:<br><br><span style='font-size: 32px; font-weight: 800; color: #007AFF; letter-spacing: 8px;'>$code</span><br><br>This code will expire in 15 minutes."
    );
}

/**
 * Core function to send themed HTML emails
 */
function send_glass_email($to_email, $name, $subject, $body_html) {
    $mail = new PHPMailer(true);

    try {
        $mail->isSMTP();
        $mail->Host       = SMTP_HOST;
        $mail->SMTPAuth   = true;
        $mail->Username   = SMTP_USER;
        $mail->Password   = SMTP_PASS;
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
        $mail->Port       = SMTP_PORT;
        $mail->Timeout    = 10;

        $mail->setFrom(SMTP_FROM, SMTP_NAME);
        $mail->addAddress($to_email, $name);

        $mail->isHTML(true);
        $mail->Subject = $subject;

        $mail->Body = "
        <html>
        <body style='font-family: Arial, sans-serif; background-color: #05050A; color: white; padding: 20px;'>
          <div style='max-width: 600px; margin: 0 auto; background-color: #1A1A1A; padding: 40px; border-radius: 20px; text-align: center; border: 1px solid #333;'>
            <h1 style='color: #007AFF; letter-spacing: 4px; font-size: 24px; margin-bottom: 30px;'>PHOTO MEMORIES</h1>
            <div style='font-size: 16px; line-height: 1.8; color: #CCCCCC;'>
              $body_html
            </div>
            <div style='margin-top: 40px; padding-top: 20px; border-top: 1px solid #222;'>
              <small style='color: #444;'>Security verification from Photo Memories Date Lab</small>
            </div>
          </div>
        </body>
        </html>
        ";

        $mail->send();
        return true;
    } catch (Exception $e) {
        return "SMTP Error: " . $mail->ErrorInfo;
    }
}
