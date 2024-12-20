import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_project/main.dart'; // Import the main file to start the app
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_project/controllers/auth_controller.dart';
import 'package:the_project/view/home_page.dart';
import 'package:the_project/view/gift_list_page.dart';
import 'package:the_project/view/login_page.dart';
import 'package:the_project/view/signup_page.dart'; // Assuming the SignupPage is defined here

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end user interaction with Signup flow', (tester) async {
    
    await tester.pumpWidget(const MyApp());

    
    await tester.pumpAndSettle();

    
    final signupButton = find.byKey(const Key('signupButton'));
    expect(signupButton, findsOneWidget);
    
    await tester.tap(signupButton);
    await tester.pumpAndSettle();

    final nameFieldSignup = find.byKey(const Key('nameFieldSignup'));
    final emailFieldSignup = find.byKey(const Key('emailFieldSignup'));
    final passwordFieldSignup = find.byKey(const Key('passwordFieldSignup'));
    final phoneNumberFieldSignup = find.byKey(const Key('phoneNumberFieldSignup'));
    final signupSubmitButton = find.byKey(const Key('signupSubmitButton'));
     
    expect(nameFieldSignup, findsOneWidget);
    expect(emailFieldSignup, findsOneWidget);
    expect(passwordFieldSignup, findsOneWidget);
    expect(nameFieldSignup, findsOneWidget);
    expect(signupSubmitButton, findsOneWidget);
    await tester.enterText(nameFieldSignup, 'mo@example.com');
    await tester.enterText(emailFieldSignup, 'mo@example.com');
    await tester.enterText(passwordFieldSignup, '123321');
    await tester.enterText(phoneNumberFieldSignup, '123321');
    await tester.tap(signupSubmitButton);

    await tester.pumpAndSettle();

   
    expect(find.byType(LoginPage), findsOneWidget);

    
    final emailField = find.byKey(const Key('emailField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.byKey(const Key('loginButton'));

    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);

    await tester.enterText(emailField, 'mo@example.com');
    await tester.enterText(passwordField, '123321');
    await tester.tap(loginButton);

    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);

    
    final addEventButton = find.byKey(const Key('addEventButton'));
    expect(addEventButton, findsOneWidget);
    
    await tester.tap(addEventButton);
    await tester.pumpAndSettle();

    
    final eventNameField = find.byKey(const Key('eventNameField'));
    final eventCategoryField = find.byKey(const Key('eventCategoryField'));
    final eventSaveButton = find.byKey(const Key('eventSaveButton'));

    expect(eventNameField, findsOneWidget);
    expect(eventCategoryField, findsOneWidget);
    expect(eventSaveButton, findsOneWidget);

    await tester.enterText(eventNameField, 'Birthday Bash');
    await tester.enterText(eventCategoryField, 'Birthday');
    await tester.tap(eventSaveButton);

    await tester.pumpAndSettle();

   
    expect(find.text('Birthday Bash'), findsOneWidget);

   
    final eventCard = find.text('Birthday Bash'); 
    await tester.tap(eventCard);
    await tester.pumpAndSettle();

    expect(find.byType(GiftListPage), findsOneWidget);

    
    final addGiftButton = find.byKey(const Key('addGiftButton'));
    expect(addGiftButton, findsOneWidget);
    
    await tester.tap(addGiftButton);
    await tester.pumpAndSettle();

    final giftNameField = find.byKey(const Key('giftNameField'));
    final giftCategoryField = find.byKey(const Key('giftCategoryField'));
    final giftSaveButton = find.byKey(const Key('giftSaveButton'));

    expect(giftNameField, findsOneWidget);
    expect(giftCategoryField, findsOneWidget);
    expect(giftSaveButton, findsOneWidget);

    await tester.enterText(giftNameField, 'Toy Car');
    await tester.enterText(giftCategoryField, 'Toys');
    await tester.tap(giftSaveButton);

    await tester.pumpAndSettle();

    
    expect(find.text('Toy Car'), findsOneWidget);
 
    final pledgeButton = find.byKey(const Key('pledgeGiftButton'));
    expect(pledgeButton, findsOneWidget);
    
    await tester.tap(pledgeButton);
    await tester.pumpAndSettle();

   
    expect(find.text('Pledged: Toy Car'), findsOneWidget);

    
    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pumpAndSettle();

    final notification = find.text('You pledged Toy Car');
    expect(notification, findsOneWidget);

    
    final logoutButton = find.byKey(const Key('logoutButton'));
    expect(logoutButton, findsOneWidget);
    
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
