// lib/features/auth/auth_provider.dart

import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_service.dart';
import '../../core/models/models.dart';

enum AuthStatus { unknown, anonymous, authenticated }

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  AuthStatus _status = AuthStatus.unknown;
  UserResponse? _user;
  String? _error;
  bool _loading = false;

  AuthStatus get status => _status;
  UserResponse? get user => _user;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAnonymous => _user?.isAnonymous ?? true;
  bool get isLoggedIn => _status != AuthStatus.unknown;

  Future<void> init() async {
    await ApiClient().init();
    if (ApiClient().isAuthenticated) {
      try {
        _user = await _api.getMe();
        _status =
            _user!.isAnonymous ? AuthStatus.anonymous : AuthStatus.authenticated;
      } catch (_) {
        await ApiClient().clearToken();
        _status = AuthStatus.unknown;
      }
    } else {
      _status = AuthStatus.unknown;
    }
    notifyListeners();
  }

  Future<bool> loginAnonymous() async {
    _setLoading(true);
    try {
      await _api.loginAnonymous();
      _user = await _api.getMe();
      _status = AuthStatus.anonymous;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _api.authenticate(email, password);
      _user = await _api.getMe();
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> upgradeAccount({
    required String email,
    required String password,
    String? mobile,
  }) async {
    _setLoading(true);
    try {
      await _api.upgradeAccount(email: email, password: password, mobile: mobile);
      _user = await _api.getMe();
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    _status = AuthStatus.unknown;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('401') || msg.contains('403')) {
      return 'Invalid credentials. Please try again.';
    }
    if (msg.contains('409')) return 'Email already registered.';
    if (msg.contains('SocketException') || msg.contains('Connection')) {
      return 'Cannot reach server. Check your connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}
