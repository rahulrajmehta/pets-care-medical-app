import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care_medical/core/constants/app_theme.dart';
import 'package:pet_care_medical/features/auth/data/auth_repository.dart';
import 'package:pet_care_medical/features/auth/presentation/screens/login_screen.dart';
import 'package:pet_care_medical/features/auth/presentation/screens/splash_screen.dart';
import 'package:pet_care_medical/features/auth/presentation/widgets/pet_brand_logo.dart';
import 'package:pet_care_medical/features/auth/presentation/widgets/pet_illustration_card.dart';
import 'package:pet_care_medical/features/auth/presentation/widgets/premium_button.dart';
import 'package:pet_care_medical/features/home/presentation/screens/main_scaffold.dart';
import 'package:pet_care_medical/features/home/presentation/widgets/greeting_header.dart';
import 'package:pet_care_medical/features/home/presentation/widgets/health_and_appointments_section.dart';
import 'package:pet_care_medical/features/home/presentation/widgets/healthcare_banner.dart';
import 'package:pet_care_medical/features/home/presentation/widgets/home_search_bar.dart';
import 'package:pet_care_medical/features/home/presentation/widgets/my_pets_preview.dart';
import 'package:pet_care_medical/features/home/presentation/widgets/pet_shop_section.dart';
import 'package:pet_care_medical/features/home/presentation/widgets/service_categories.dart';

class FakeAuthRepository extends Fake implements AuthRepository {
  @override
  fb.User? get currentFirebaseUser => null;

  @override
  Stream<fb.User?> get onFirebaseAuthStateChange => const Stream.empty();

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(fb.PhoneAuthCredential credential) verificationCompleted,
    required void Function(fb.FirebaseAuthException exception) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
    int? forceResendingToken,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    codeSent('test-verification-id', null);
  }
}

void main() {
  group('Pet Care Medical - Widget Smoke Tests', () {
    testWidgets('PetBrandLogo renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: PetBrandLogo(size: 80),
          ),
        ),
      );

      expect(find.text('VetCare'), findsOneWidget);
      expect(find.text('MED'), findsOneWidget);
      expect(find.text('Specialized Veterinary & Pet Care'), findsOneWidget);
      expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
    });

    testWidgets('PetIllustrationCard renders trust badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: PetIllustrationCard(),
          ),
        ),
      );

      expect(find.text('Canine Care'), findsOneWidget);
      expect(find.text('Feline Care'), findsOneWidget);
      expect(find.text('Licensed Veterinary Care • 24/7 Helpline'), findsOneWidget);
    });

    testWidgets('HealthcareBanner renders headline, badge, and Book Appointment CTA',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: HealthcareBanner(
              onBookAppointmentTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Every Paw Deserves Exceptional Care.'), findsOneWidget);
      expect(find.text('24/7 Veterinary Emergency Care'), findsOneWidget);
      expect(find.text('Book Appointment'), findsOneWidget);

      await tester.tap(find.text('Book Appointment'));
      expect(tapped, isTrue);
    });

    testWidgets('PremiumButton displays loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: PremiumButton(
              label: 'Verify OTP',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Verify OTP'), findsNothing);
    });

    testWidgets('LoginScreen renders Pet Care Medical branding, headings, and country code',
        (tester) async {
      final fakeAuthRepo = FakeAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepo),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Flush microtasks for initial session check
      await tester.pump();

      expect(find.text('Pet Care Medical'), findsOneWidget);
      expect(find.text('Care that feels\nlike family'), findsOneWidget);
      expect(find.text('Expert veterinary care for your furry family,\nall in one place.'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(find.text('Continue with Phone'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);

      // Tap Continue with Phone with empty field to trigger validation
      await tester.tap(find.text('Continue with Phone'));
      await tester.pump();
      expect(find.text('Please enter your mobile number'), findsOneWidget);

      // Tap +91 country selector to open bottom sheet
      await tester.tap(find.text('+91'));
      await tester.pumpAndSettle();
      expect(find.text('Select Country / Region'), findsOneWidget);
      expect(find.text('India'), findsOneWidget);
    });

    testWidgets('SplashScreen renders logo, title, tagline and progress indicator',
        (tester) async {
      final fakeAuthRepo = FakeAuthRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepo),
          ],
          child: const MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Advance animation to halfway mark
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.text('Pet Care Medical'), findsOneWidget);
      expect(find.text('Complete Care for Your Pets'), findsOneWidget);
      expect(find.text('Specialized Veterinary Care'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.pets_rounded), findsOneWidget);

      // Complete animation and timers
      await tester.pump(const Duration(milliseconds: 2500));
    });

    testWidgets('GreetingHeader renders Pet Care Medical branding and handles profile tap',
        (tester) async {
      bool profileTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GreetingHeader(
              userName: 'Rahul Sharma',
              onProfileTap: () => profileTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Pet Care Medical'), findsOneWidget);
      expect(find.textContaining('Rahul'), findsOneWidget);
      expect(find.byTooltip('My Profile'), findsOneWidget);

      await tester.tap(find.byTooltip('My Profile'));
      expect(profileTapped, isTrue);
    });

    testWidgets('HomeSearchBar renders placeholder and handles clear button',
        (tester) async {
      String searchQuery = '';
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: HomeSearchBar(
              onChanged: (val) => searchQuery = val,
            ),
          ),
        ),
      );

      expect(find.text('Search doctors, services, products...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Vaccination');
      await tester.pump();
      expect(searchQuery, 'Vaccination');
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(find.text('Vaccination'), findsNothing);
    });

    testWidgets('MyPetsPreview renders My Pets and handles Add Pet tap on empty state',
        (tester) async {
      bool addPetTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: MyPetsPreview(
              onAddPetTap: () => addPetTapped = true,
              onPetTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('My Pets'), findsOneWidget);
      expect(find.text('Add Pet'), findsOneWidget);
      expect(find.text('No Pets Registered Yet'), findsOneWidget);
      expect(find.text('+ Add Pet'), findsOneWidget);

      await tester.tap(find.text('Add Pet'));
      expect(addPetTapped, isTrue);
    });

    testWidgets('MyPetsPreview renders saved pets when present',
        (tester) async {
      String tappedPet = '';
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: MyPetsPreview(
              onAddPetTap: () {},
              onPetTap: (name) => tappedPet = name,
              pets: const [
                {'name': 'Bella', 'breed': 'Golden Retriever', 'age': '2 yrs'},
                {'name': 'Milo', 'breed': 'Persian Cat', 'age': '1 yr'},
              ],
            ),
          ),
        ),
      );

      expect(find.text('Bella'), findsOneWidget);
      expect(find.text('Milo'), findsOneWidget);

      await tester.tap(find.text('Bella'));
      expect(tappedPet, 'Bella');
    });

    testWidgets('ServiceCategories renders 8 veterinary service shortcuts',
        (tester) async {
      String selectedService = '';
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: ServiceCategories(
                onCategoryTap: (val) => selectedService = val,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Veterinary Services'), findsOneWidget);
      expect(find.text('Doctor Consultation'), findsOneWidget);
      expect(find.text('Vaccination'), findsOneWidget);
      expect(find.text('Grooming'), findsOneWidget);
      expect(find.text('Diagnostics'), findsOneWidget);
      expect(find.text('Video\nConsultation'), findsOneWidget);
      expect(find.text('Wellness'), findsOneWidget);
      expect(find.text('Book\nVisit'), findsOneWidget);
      expect(find.text('Emergency'), findsOneWidget);

      await tester.tap(find.text('Doctor Consultation'));
      expect(selectedService, 'Doctor Consultation');
    });

    testWidgets('PetShopSection renders Pet Essentials with 3 demo products',
        (tester) async {
      bool viewShopTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: PetShopSection(
                onViewShopTap: () => viewShopTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pet Essentials'), findsOneWidget);
      expect(find.text('View Shop'), findsOneWidget);
      expect(find.text('Veterinary Canine Diet'), findsOneWidget);
      expect(find.text('Feline Wellness Care'), findsOneWidget);
      expect(find.text('Hypoallergenic Shampoo'), findsOneWidget);

      await tester.tap(find.text('View Shop'));
      expect(viewShopTapped, isTrue);
    });

    testWidgets('HealthAndAppointmentsSection renders appointments, reminders, and records',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HealthAndAppointmentsSection(
                onAppointmentDetailsTap: () {},
                onMedicalRecordsTap: () {},
                onVaccinationReminderTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Upcoming Appointments'), findsOneWidget);
      expect(find.text('No Upcoming Appointments'), findsOneWidget);
      expect(find.text('Vaccination Reminders'), findsOneWidget);
      expect(find.text('Vaccination Records Clear'), findsOneWidget);
      expect(find.text('Medical Records'), findsOneWidget);
      expect(find.text('Pet Health Vault'), findsOneWidget);
    });

    testWidgets('MainScaffold renders 4 bottom navigation items: Home, Appointments, Shop, Medical Records',
        (tester) async {
      final fakeAuthRepo = FakeAuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepo),
          ],
          child: const MaterialApp(
            home: MainScaffold(),
          ),
        ),
      );

      final navFinder = find.byType(BottomNavigationBar);
      expect(navFinder, findsOneWidget);
      expect(find.descendant(of: navFinder, matching: find.text('Home')), findsOneWidget);
      expect(find.descendant(of: navFinder, matching: find.text('Appointments')), findsOneWidget);
      expect(find.descendant(of: navFinder, matching: find.text('Shop')), findsOneWidget);
      expect(find.descendant(of: navFinder, matching: find.text('Medical Records')), findsOneWidget);

      // Profile must NOT be in bottom navigation
      final bottomNav = tester.widget<BottomNavigationBar>(navFinder);
      expect(bottomNav.items.length, 4);
      expect(bottomNav.items[0].label, 'Home');
      expect(bottomNav.items[1].label, 'Appointments');
      expect(bottomNav.items[2].label, 'Shop');
      expect(bottomNav.items[3].label, 'Medical Records');
      expect(bottomNav.items.any((item) => item.label == 'Profile'), isFalse);
    });
  });
}

