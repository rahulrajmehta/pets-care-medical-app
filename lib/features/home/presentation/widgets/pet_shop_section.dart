import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Demo product model stored strictly in local memory (separate from Firebase)
class DemoProduct {
  final String id;
  final String name;
  final String subtitle;
  final String targetPet;
  final String price;
  final double rating;
  final IconData icon;
  final String? imagePath;
  final String description;

  const DemoProduct({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.targetPet,
    required this.price,
    required this.rating,
    required this.icon,
    this.imagePath,
    required this.description,
  });
}

/// Pet Essentials: Refined preview section featuring 3 demo products
/// Separated from Firebase inventory, includes a "View Shop" action
class PetShopSection extends StatelessWidget {
  final VoidCallback? onViewShopTap;
  final ValueChanged<DemoProduct>? onProductTap;

  const PetShopSection({
    super.key,
    this.onViewShopTap,
    this.onProductTap,
  });

  static const List<DemoProduct> _featuredProducts = [
    DemoProduct(
      id: 'demo-1',
      name: 'Veterinary Canine Diet',
      subtitle: 'Complete Nutrition',
      targetPet: 'Canine',
      price: '₹1,299',
      rating: 4.9,
      icon: Icons.dinner_dining_rounded,
      imagePath: 'assets/images/product_canine_diet.png',
      description:
          'Veterinarian-formulated complete canine nutrition supporting digestive vitality, lean muscle maintenance, and coat health.',
    ),
    DemoProduct(
      id: 'demo-2',
      name: 'Feline Wellness Care',
      subtitle: 'Taurine & Digestion',
      targetPet: 'Feline',
      price: '₹849',
      rating: 4.8,
      icon: Icons.set_meal_rounded,
      imagePath: 'assets/images/product_feline_wellness.png',
      description:
          'Specialized taurine-enriched nutrition supporting urinary tract health, hairball management, and immune resilience in cats.',
    ),
    DemoProduct(
      id: 'demo-3',
      name: 'Hypoallergenic Shampoo',
      subtitle: 'Dermatological Spa',
      targetPet: 'All Pets',
      price: '₹399',
      rating: 4.7,
      icon: Icons.soap_rounded,
      imagePath: 'assets/images/product_pet_shampoo.png',
      description:
          'pH-balanced soothing colloidal oatmeal cleanser formulated for sensitive pet skin, free of parabens and harsh chemicals.',
    ),
  ];

  void _showDemoModal(BuildContext context, DemoProduct product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8F7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: product.imagePath != null
                          ? Image.asset(
                              product.imagePath!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    product.icon,
                                    size: 30,
                                    color: AppColors.primaryTeal,
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                product.icon,
                                size: 30,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.softMint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Demo Showcase • Not Real Inventory',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Demo Price: ${product.price}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              product.description,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This product is displayed for UI layout demonstration. It is separate from Firebase records and clinic inventory.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: AppColors.white,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Close Preview'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with "View Shop" action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: AppColors.primaryTeal,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pet Essentials',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onViewShopTap,
              child: Text(
                'View Shop',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Featured Products Grid / Cards (exactly 3 items)
        SizedBox(
          height: 194,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _featuredProducts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = _featuredProducts[index];
              return _buildProductCard(context, product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, DemoProduct product) {
    return InkWell(
      onTap: () {
        onProductTap?.call(product);
        _showDemoModal(context, product);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 156,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Consistent Square Product Image Container
            Container(
              width: double.infinity,
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.6),
                  width: 0.8,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: product.imagePath != null
                      ? Image.asset(
                          product.imagePath!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                product.icon,
                                size: 32,
                                color: AppColors.primaryTeal,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            product.icon,
                            size: 32,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Product Name
            Text(
              product.name,
              style: AppTextStyles.headingSmall.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            // Subtitle
            Text(
              product.subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Price & Preview Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    product.price,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTeal,
                      fontSize: 12.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Text(
                    'Demo',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
