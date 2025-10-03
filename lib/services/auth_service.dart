import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  // static const String baseUrl = 'http://localhost:8080/api/users';

  // For Android emulator, use 10.0.2.2 instead of localhost
   static const String baseUrl = 'http://10.0.2.2:8080/api/users';

  // For physical device, use your computer's IP address
  // static const String baseUrl = 'http://192.168.1.100:8080/api/users';

  static const Duration timeoutDuration = Duration(seconds: 10);

  // Register a new user
  static Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final user = User(
        username: username.trim(),
        email: email.trim(),
        fullName: fullName.trim(),
        password: password,
      );

      // Validate user data before sending
      final validationErrors = user.validateAll();
      if (validationErrors.isNotEmpty) {
        return AuthResult.failure(validationErrors.values.first);
      }

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toRegistrationJson()),
      ).timeout(timeoutDuration);

      if (response.statusCode == 201) {
        final userData = jsonDecode(response.body);
        return AuthResult.success(
          message: 'Registration successful! You can now log in.',
          user: User.fromJson(userData),
        );
      } else {
        String errorMessage = 'Registration failed';

        try {
          if (response.body.startsWith('Error:')) {
            errorMessage = response.body.substring(7).trim();
          } else {
            // Try to parse as JSON first
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (e) {
          // If not JSON, use raw response body
          errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
        }

        // Handle specific validation errors from backend
        if (errorMessage.toLowerCase().contains('username') &&
            errorMessage.toLowerCase().contains('already')) {
          errorMessage = 'Username is already taken. Please choose another.';
        } else if (errorMessage.toLowerCase().contains('email') &&
            errorMessage.toLowerCase().contains('already')) {
          errorMessage = 'Email is already registered. Please use another email or try logging in.';
        }

        return AuthResult.failure(errorMessage);
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  // Login user
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Basic validation
      if (email.trim().isEmpty || password.isEmpty) {
        return AuthResult.failure('Email and password are required');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final user = User.fromJson(userData);

        return AuthResult.success(
          message: 'Welcome back, ${user.fullName}!',
          user: user,
        );
      } else {
        String errorMessage = 'Login failed';

        try {
          if (response.body.startsWith('Error:')) {
            errorMessage = response.body.substring(7).trim();
          } else if (response.body.contains('Invalid credentials')) {
            errorMessage = 'Invalid email or password. Please check your credentials and try again.';
          } else {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (e) {
          if (response.statusCode == 401) {
            errorMessage = 'Invalid email or password. Please check your credentials and try again.';
          } else {
            errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
          }
        }

        return AuthResult.failure(errorMessage);
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  // Get user by ID
  static Future<AuthResult> getUserById(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return AuthResult.success(
          message: 'User retrieved successfully',
          user: User.fromJson(userData),
        );
      } else if (response.statusCode == 404) {
        return AuthResult.failure('User not found');
      } else {
        return AuthResult.failure('Failed to retrieve user');
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  // Update user profile
  static Future<AuthResult> updateProfile({
    required int userId,
    required String username,
    required String email,
    required String fullName,
  }) async {
    try {
      final user = User(
        id: userId,
        username: username.trim(),
        email: email.trim(),
        fullName: fullName.trim(),
      );

      // Validate user data before sending (excluding password)
      final usernameError = user.validateUsername();
      if (usernameError != null) {
        return AuthResult.failure(usernameError);
      }

      final emailError = user.validateEmail();
      if (emailError != null) {
        return AuthResult.failure(emailError);
      }

      final fullNameError = user.validateFullName();
      if (fullNameError != null) {
        return AuthResult.failure(fullNameError);
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toProfileUpdateJson()),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return AuthResult.success(
          message: 'Profile updated successfully',
          user: User.fromJson(userData),
        );
      } else {
        String errorMessage = 'Failed to update profile';

        try {
          if (response.body.startsWith('Error:')) {
            errorMessage = response.body.substring(7).trim();
          } else {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (e) {
          errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
        }

        // Handle specific validation errors
        if (errorMessage.toLowerCase().contains('username') &&
            errorMessage.toLowerCase().contains('already')) {
          errorMessage = 'Username is already taken. Please choose another.';
        } else if (errorMessage.toLowerCase().contains('email') &&
            errorMessage.toLowerCase().contains('already')) {
          errorMessage = 'Email is already registered. Please use another email.';
        }

        return AuthResult.failure(errorMessage);
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  // Update password
  static Future<AuthResult> updatePassword({
    required int userId,
    required String newPassword,
  }) async {
    try {
      // Validate password
      if (newPassword.isEmpty) {
        return AuthResult.failure('Password is required');
      }
      if (newPassword.length < 6) {
        return AuthResult.failure('Password must be at least 6 characters');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$userId/password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'newPassword': newPassword,
        }),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return AuthResult.success(
          message: 'Password updated successfully',
        );
      } else {
        String errorMessage = 'Failed to update password';

        try {
          if (response.body.startsWith('Error:')) {
            errorMessage = response.body.substring(7).trim();
          } else {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (e) {
          errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
        }

        return AuthResult.failure(errorMessage);
      }
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  // Helper method to handle network errors consistently
  static AuthResult _handleNetworkError(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('TimeoutException')) {
      return AuthResult.failure('Request timeout. Please check your internet connection and try again.');
    } else if (errorString.contains('SocketException')) {
      return AuthResult.failure('No internet connection. Please check your network settings.');
    } else if (errorString.contains('HandshakeException')) {
      return AuthResult.failure('SSL connection failed. Please check your network security settings.');
    } else if (errorString.contains('Connection refused')) {
      return AuthResult.failure('Cannot connect to server. Please ensure the server is running.');
    } else {
      return AuthResult.failure('Network error: Please check your connection and try again.');
    }
  }
}

// Enhanced result class to handle API responses
class AuthResult {
  final bool success;
  final String message;
  final User? user;
  final List<User>? users; // For getAllUsers

  AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.users,
  });

  factory AuthResult.success({
    required String message,
    User? user,
    List<User>? users,
  }) {
    return AuthResult(
      success: true,
      message: message,
      user: user,
      users: users,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(
      success: false,
      message: message,
    );
  }
}