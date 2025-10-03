class User {
  final int? id;
  final String username;
  final String email;
  final String fullName;
  final String? password; // Will be null when received from API due to @JsonProperty(access = WRITE_ONLY)

  User({
    this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.password,
  });

  // Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toInt(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      password: json['password'], // Will typically be null from API response
    );
  }

  // Method to convert User to JSON for API requests
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'fullName': fullName,
    };

    // Only include password if it's not null (for registration/update requests)
    if (password != null) {
      data['password'] = password;
    }

    // Only include id if it's not null (for update requests)
    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  // Method to convert User to JSON for registration
  Map<String, dynamic> toRegistrationJson() {
    return {
      'username': username,
      'email': email,
      'fullName': fullName,
      'password': password,
    };
  }

  // Method to convert User to JSON for profile update (excludes password)
  Map<String, dynamic> toProfileUpdateJson() {
    return {
      'username': username,
      'email': email,
      'fullName': fullName,
    };
  }

  // Method to create a copy of User with updated fields
  User copyWith({
    int? userId,
    String? newUsername,
    String? newEmail,
    String? newFullName,
    String? newPassword,
  }) {
    return User(
      id: userId ?? this.id,
      username: newUsername ?? this.username,
      email: newEmail ?? this.email,
      fullName: newFullName ?? this.fullName,
      password: newPassword ?? this.password,
    );
  }

  // Method to create a copy without password (for display purposes)
  User withoutPassword() {
    return User(
      id: id,
      username: username,
      email: email,
      fullName: fullName,
      password: null,
    );
  }

  // Validation methods that match your backend validation
  String? validateUsername() {
    if (username.trim().isEmpty) {
      return 'Username is required';
    }
    if (username.length < 3 || username.length > 50) {
      return 'Username must be between 3 and 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  String? validateEmail() {
    if (email.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      return 'Email should be valid';
    }
    return null;
  }

  String? validatePassword() {
    if (password == null || password!.isEmpty) {
      return 'Password is required';
    }
    if (password!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateFullName() {
    if (fullName.trim().isEmpty) {
      return 'Full name is required';
    }
    if (fullName.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  // Method to validate all fields
  Map<String, String> validateAll() {
    Map<String, String> errors = {};

    final usernameError = validateUsername();
    if (usernameError != null) errors['username'] = usernameError;

    final emailError = validateEmail();
    if (emailError != null) errors['email'] = emailError;

    final fullNameError = validateFullName();
    if (fullNameError != null) errors['fullName'] = fullNameError;

    final passwordError = validatePassword();
    if (passwordError != null) errors['password'] = passwordError;

    return errors;
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, fullName: $fullName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.fullName == fullName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    username.hashCode ^
    email.hashCode ^
    fullName.hashCode;
  }
}