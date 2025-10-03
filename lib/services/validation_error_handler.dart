import 'dart:convert';

class ValidationErrorHandler {
  // Parse validation errors from Spring Boot backend
  static String parseValidationError(String responseBody, int statusCode) {
    try {
      // Handle Spring Boot validation errors (usually status 400)
      if (statusCode == 400) {
        final Map<String, dynamic> errorData = jsonDecode(responseBody);

        // Handle Spring Boot @Valid annotation errors
        if (errorData.containsKey('errors')) {
          final List<dynamic> errors = errorData['errors'];
          if (errors.isNotEmpty) {
            return errors.first['defaultMessage'] ?? 'Validation error';
          }
        }

        // Handle Spring Boot field validation errors
        if (errorData.containsKey('fieldErrors')) {
          final List<dynamic> fieldErrors = errorData['fieldErrors'];
          if (fieldErrors.isNotEmpty) {
            return fieldErrors.first['defaultMessage'] ?? 'Field validation error';
          }
        }

        // Handle custom validation messages
        if (errorData.containsKey('message')) {
          return errorData['message'];
        }

        // Handle validation error with specific field
        if (errorData.containsKey('field') && errorData.containsKey('error')) {
          return '${errorData['field']}: ${errorData['error']}';
        }
      }

      // Handle other HTTP error responses
      if (responseBody.startsWith('Error:')) {
        return responseBody.substring(7).trim();
      }

      // Try to parse as JSON for any other error format
      final Map<String, dynamic> errorData = jsonDecode(responseBody);
      return errorData['message'] ?? errorData['error'] ?? 'Unknown error occurred';

    } catch (e) {
      // If JSON parsing fails, return the raw response or a default message
      if (responseBody.isNotEmpty) {
        return responseBody;
      }

      // Return status-code-specific messages
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Invalid email or password.';
        case 403:
          return 'Access denied.';
        case 404:
          return 'Resource not found.';
        case 409:
          return 'Resource already exists.';
        case 422:
          return 'Validation failed. Please check your input.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
  }

  // Handle specific user-related validation errors
  static String handleUserValidationError(String error) {
    final lowerError = error.toLowerCase();

    // Username validation errors
    if (lowerError.contains('username')) {
      if (lowerError.contains('required') || lowerError.contains('blank')) {
        return 'Username is required';
      }
      if (lowerError.contains('size') || lowerError.contains('length')) {
        return 'Username must be between 3 and 50 characters';
      }
      if (lowerError.contains('unique') || lowerError.contains('already') || lowerError.contains('exists')) {
        return 'Username is already taken. Please choose another.';
      }
      if (lowerError.contains('invalid') || lowerError.contains('format')) {
        return 'Username can only contain letters, numbers, and underscores';
      }
    }

    // Email validation errors
    if (lowerError.contains('email')) {
      if (lowerError.contains('required') || lowerError.contains('blank')) {
        return 'Email is required';
      }
      if (lowerError.contains('valid') || lowerError.contains('format')) {
        return 'Please enter a valid email address';
      }
      if (lowerError.contains('unique') || lowerError.contains('already') || lowerError.contains('exists')) {
        return 'Email is already registered. Please use another email or try logging in.';
      }
    }

    // Password validation errors
    if (lowerError.contains('password')) {
      if (lowerError.contains('required') || lowerError.contains('blank')) {
        return 'Password is required';
      }
      if (lowerError.contains('size') || lowerError.contains('length') || lowerError.contains('6')) {
        return 'Password must be at least 6 characters';
      }
      if (lowerError.contains('weak') || lowerError.contains('strong')) {
        return 'Please choose a stronger password';
      }
    }

    // Full name validation errors
    if (lowerError.contains('fullname') || lowerError.contains('full name')) {
      if (lowerError.contains('required') || lowerError.contains('blank')) {
        return 'Full name is required';
      }
      if (lowerError.contains('size') || lowerError.contains('length')) {
        return 'Please enter a valid full name';
      }
    }

    // Database constraint errors
    if (lowerError.contains('constraint') || lowerError.contains('duplicate')) {
      if (lowerError.contains('username')) {
        return 'Username is already taken. Please choose another.';
      }
      if (lowerError.contains('email')) {
        return 'Email is already registered. Please use another email.';
      }
      return 'This information is already in use. Please try different values.';
    }

    // Connection and network errors
    if (lowerError.contains('connection') || lowerError.contains('network')) {
      return 'Network connection error. Please check your internet connection.';
    }

    if (lowerError.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (lowerError.contains('server') || lowerError.contains('internal')) {
      return 'Server error. Please try again later.';
    }

    // Return the original error if no specific handling is found
    return error;
  }

  // Create user-friendly error messages for common HTTP status codes
  static String getStatusCodeMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'Invalid email or password. Please check your credentials.';
      case 403:
        return 'Access denied. You don\'t have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'Resource conflict. The data you\'re trying to create already exists.';
      case 422:
        return 'Validation failed. Please check your input data.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. The server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. The request took too long to process.';
      default:
        return 'An error occurred (Status: $statusCode). Please try again.';
    }
  }

  // Check if an error is a network-related error
  static bool isNetworkError(String error) {
    final lowerError = error.toLowerCase();
    return lowerError.contains('socket') ||
        lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout') ||
        lowerError.contains('host') ||
        lowerError.contains('unreachable');
  }

  // Check if an error is a validation error
  static bool isValidationError(int statusCode) {
    return statusCode == 400 || statusCode == 422;
  }

  // Check if an error is an authentication error
  static bool isAuthenticationError(int statusCode) {
    return statusCode == 401;
  }

  // Check if an error is a conflict error (duplicate data)
  static bool isConflictError(int statusCode) {
    return statusCode == 409;
  }
}