import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class AuthService extends ChangeNotifier {
  AuthService({required this.api});

  final ApiService api;

  bool _isLoggedIn = false;
  int? _userId;
  String? _currentUsername;
  String? _currentEmail;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  int? get userId => _userId;
  String? get currentUsername => _currentUsername;
  String? get currentEmail => _currentEmail;
  String? get errorMessage => _errorMessage;

  static const String _sessionKey = 'active_session';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString(_sessionKey);
    if (sessionJson != null) {
      final session = jsonDecode(sessionJson);
      _isLoggedIn = true;
      _userId = session['user_id'];
      _currentUsername = session['username'];
      _currentEmail = session['email'];
      notifyListeners();
    }
  }

  Future<bool> logIn(String identifier, String password) async {
    _errorMessage = null;
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final user = await api.login(identifier, password);
      _isLoggedIn = true;
      _userId = user.userId;
      _currentUsername = user.username;
      _currentEmail = user.email;
      await _saveSession();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Could not reach the server';
      notifyListeners();
      return false;
    }
  }

  // --- REGISTRATION FLOW WITH OTP ---

  Future<bool> requestRegistrationCode(String username, String email, String password) async {
    _errorMessage = null;
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _errorMessage = 'Please fill all fields';
      notifyListeners();
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    try {
      await api.requestRegistrationCode(username, email, password);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Could not reach the server';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyRegistrationAndCreate(String username, String email, String password, String code) async {
    _errorMessage = null;
    try {
      final user = await api.verifyRegistrationCode(username, email, password, code);
      _isLoggedIn = true;
      _userId = user.userId;
      _currentUsername = user.username;
      _currentEmail = user.email;
      await _saveSession();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Registration verification failed';
      notifyListeners();
      return false;
    }
  }

  Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _isLoggedIn = false;
    _userId = null;
    _currentUsername = null;
    _currentEmail = null;
    notifyListeners();
  }

  // PASSWORD RESET FLOW
  
  Future<bool> requestResetCode(String email) async {
    _errorMessage = null;
    try {
      await api.requestPasswordReset(email);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Could not reach the server';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyCode(String email, String code) async {
    _errorMessage = null;
    try {
      await api.verifyResetCode(email, code);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Verification failed';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePasswordWithCode(String email, String code, String newPassword) async {
    _errorMessage = null;
    try {
      await api.updatePasswordWithCode(email, code, newPassword);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Password update failed';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    _errorMessage = null;
    if (_userId == null) return false;

    try {
      await api.deleteAccount(_userId!);
      await logOut();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Could not reach the server';
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _errorMessage = null;
    if (newPassword.length < 6) {
      _errorMessage = 'New password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    try {
      if (_userId == null) throw ApiException('Not logged in');
      await api.changePassword(_userId!, oldPassword, newPassword);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Could not reach the server';
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _sessionKey,
      jsonEncode({
        'user_id': _userId,
        'username': _currentUsername,
        'email': _currentEmail,
      }),
    );
  }
}
