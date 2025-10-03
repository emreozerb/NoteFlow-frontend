// This is a basic Flutter widget test for NoteFlow authentication app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noteflow_frontend/main.dart';

void main() {
  testWidgets('NoteFlow app launches with authentication page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoteFlowApp());

    // Verify that the app title is displayed
    expect(find.text('NoteFlow'), findsOneWidget);

    // Verify that the subtitle is displayed
    expect(find.text('Your digital notebook companion'), findsOneWidget);

    // Verify that Register and Login tabs are present
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Verify that we start on the Register tab (Create Account should be visible)
    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('Can switch between Register and Login tabs', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoteFlowApp());

    // Initially should be on Register tab
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Welcome Back'), findsNothing);

    // Tap the Login tab
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Should now be on Login tab
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Create Account'), findsNothing);

    // Tap the Register tab again
    await tester.tap(find.text('Register'));
    await tester.pump();

    // Should be back on Register tab
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Welcome Back'), findsNothing);
  });

  testWidgets('Register form has all required fields', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoteFlowApp());

    // Verify all form fields are present in Register tab
    expect(find.widgetWithText(TextFormField, 'Full Name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Confirm Password'), findsOneWidget);

    // Verify Create Account button is present
    expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsOneWidget);
  });

  testWidgets('Login form has required fields', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoteFlowApp());

    // Switch to Login tab
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify login form fields are present
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

    // Verify Login button is present
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Verify Forgot Password button is present
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('Form validation works for empty fields', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoteFlowApp());

    // Try to submit register form without filling fields
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump();

    // Should show validation errors
    expect(find.text('Please enter your full name'), findsOneWidget);
    expect(find.text('Please enter a username'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
  });

  testWidgets('Password visibility toggle works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoteFlowApp());

    // Initially visibility_off icon should be present (password hidden)
    expect(find.byIcon(Icons.visibility_off), findsAtLeastNWidgets(1));

    // Find and tap the first visibility toggle button (register password)
    final visibilityButtons = find.byIcon(Icons.visibility_off);
    await tester.tap(visibilityButtons.first);
    await tester.pump();

    // After tapping, should find at least one visibility icon (password shown)
    expect(find.byIcon(Icons.visibility), findsAtLeastNWidgets(1));
  });

  testWidgets('Email validation works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoteFlowApp());

    // Find email field by looking for field with email hint text
    final emailField = find.widgetWithText(TextFormField, 'Email');

    // Enter invalid email
    await tester.enterText(emailField, 'invalid-email');

    // Try to submit form
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump();

    // Should show email validation error
    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });

  testWidgets('Username validation works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoteFlowApp());

    // Enter username with invalid characters
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'user@name!'
    );

    // Try to submit form
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump();

    // Should show username validation error
    expect(find.text('Username can only contain letters, numbers, and underscores'), findsOneWidget);
  });

  testWidgets('Password confirmation validation works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoteFlowApp());

    // Find password fields
    final passwordFields = find.widgetWithText(TextFormField, 'Password');
    final confirmPasswordField = find.widgetWithText(TextFormField, 'Confirm Password');

    // Enter different passwords
    await tester.enterText(passwordFields.first, 'password123');
    await tester.enterText(confirmPasswordField, 'differentpassword');

    // Try to submit form
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump();

    // Should show password mismatch error
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Can enter text in form fields', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoteFlowApp());

    // Test entering text in various fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'John Doe');
    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'johndoe');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'john@example.com');

    // Verify text was entered
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('johndoe'), findsOneWidget);
    expect(find.text('john@example.com'), findsOneWidget);
  });

  testWidgets('Login tab switch and form interaction', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoteFlowApp());

    // Switch to Login tab
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Enter login credentials
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');

    // Verify text was entered
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);

    // Test forgot password button
    await tester.tap(find.text('Forgot Password?'));
    await tester.pump();

    // Should show snackbar message
    expect(find.text('Forgot password feature coming soon!'), findsOneWidget);
  });

  testWidgets('Navigation links work between tabs', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoteFlowApp());

    // Initially on Register tab
    expect(find.text('Create Account'), findsOneWidget);

    // Tap "Login here" link
    await tester.tap(find.text('Login here'));
    await tester.pump();

    // Should switch to Login tab
    expect(find.text('Welcome Back'), findsOneWidget);

    // Tap "Register here" link
    await tester.tap(find.text('Register here'));
    await tester.pump();

    // Should switch back to Register tab
    expect(find.text('Create Account'), findsOneWidget);
  });
}