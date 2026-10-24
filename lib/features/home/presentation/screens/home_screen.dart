import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/feature_placeholder_sheet.dart';
import '../widgets/greeting_header.dart';
import '../widgets/healthcare_banner.dart';
import '../widgets/health_and_appointments_section.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/my_pets_preview.dart';
import '../widgets/pet_shop_section.dart';
import '../widgets/service_categories.dart';

/// Screen 5: Home Page Dashboard for Pet Care Medical
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showFeaturePlaceholder(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    String stepLabel = 'Clinical Feature',
  }) {
    FeaturePlaceholderSheet.show(
      context,
      title: title,
      description: description,
      icon: icon,
      stepLabel: stepLabel,
    );
  }

  void _openProfile(BuildContext context) {
    if (GoRouter.maybeOf(context) != null) {
      context.push(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userName = authState.userProfile?.fullName ?? 'Pet Parent';

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER: Welcome to Pet Care Medical & Top-Right Profile Icon
              GreetingHeader(
                userName: userName,
                onProfileTap: () => _openProfile(context),
              ),
              const SizedBox(height: 16),

              // 2. SEARCH BAR: Search doctors, services, products with clear button
              const HomeSearchBar(),
              const SizedBox(height: 20),

              // 3. PROMOTIONAL BANNER: Complete Care for Your Pets & 24/7 CTA
              HealthcareBanner(
                onBookAppointmentTap: () => _showFeaturePlaceholder(
                  context,
                  title: 'Book Appointment',
                  description:
                      'Select an experienced veterinary physician, pick an in-clinic or home visit slot, and get immediate confirmation.',
                  icon: Icons.calendar_month_rounded,
                  stepLabel: 'Appointments',
                ),
              ),
              const SizedBox(height: 24),

              // 4. MY PETS: Horizontal list + "Add Your Pet" button with plus icon
              MyPetsPreview(
                onAddPetTap: () => _showFeaturePlaceholder(
                  context,
                  title: 'Add Your Pet',
                  description:
                      'Register your dog or cat with breed, birth date, microchip ID, and emergency veterinary history.',
                  icon: Icons.pets_rounded,
                  stepLabel: 'Patient Registration',
                ),
                onPetTap: (petName) => _showFeaturePlaceholder(
                  context,
                  title: '$petName Clinical File',
                  description:
                      'View diagnostic imaging, vaccine history, diet prescriptions, and veterinary consultation notes for $petName.',
                  icon: Icons.folder_shared_outlined,
                  stepLabel: 'Pet Health Vault',
                ),
              ),
              const SizedBox(height: 24),

              // 5. QUICK SERVICES: Book Appointment, Find a Doctor, Pet Grooming, Video Consultation
              ServiceCategories(
                onCategoryTap: (service) => _showFeaturePlaceholder(
                  context,
                  title: service,
                  description:
                      'Licensed clinical care for $service will be scheduled with top veterinary specialists.',
                  icon: Icons.medical_services_rounded,
                  stepLabel: 'Clinical Services',
                ),
              ),
              const SizedBox(height: 24),

              // 6. SHOP FOR YOUR PET: Categories & Demo product cards (clearly local demo data)
              PetShopSection(
                onViewShopTap: () => _showFeaturePlaceholder(
                  context,
                  title: 'Pet Care Essentials Store',
                  description:
                      'Browse vet-recommended prescription diets, therapeutic supplements, and dermatological essentials.',
                  icon: Icons.shopping_bag_rounded,
                  stepLabel: 'Pharmacy & Essentials',
                ),
              ),
              const SizedBox(height: 24),

              // 7. HEALTH AND APPOINTMENTS: Upcoming Appointments, Medical Records, Vaccination Reminders
              HealthAndAppointmentsSection(
                onAppointmentDetailsTap: () => _showFeaturePlaceholder(
                  context,
                  title: 'Upcoming Appointment',
                  description:
                      'Clinic directions, doctor credentials, pre-visit fasting instructions, and check-in QR code.',
                  icon: Icons.event_available_rounded,
                  stepLabel: 'Visit Details',
                ),
                onVaccinationReminderTap: () => _showFeaturePlaceholder(
                  context,
                  title: 'Rabies Booster Reminder',
                  description:
                      'Schedule Bella\'s annual rabies and DHPP vaccination booster with cold-chain certified biologics.',
                  icon: Icons.vaccines_rounded,
                  stepLabel: 'Immunization Alert',
                ),
                onMedicalRecordsTap: () => _showFeaturePlaceholder(
                  context,
                  title: 'Digital Health Vault',
                  description:
                      'Upload blood test reports, histopathology results, and digital X-rays to share securely with your vet.',
                  icon: Icons.folder_shared_rounded,
                  stepLabel: 'Medical Records',
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
