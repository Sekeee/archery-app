import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/new_match_controller.dart';

class NewMatchView extends GetView<NewMatchController> {
  const NewMatchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text('New Match', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: controller.state.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Error message
                      Obx(() {
                        if (controller.state.errorMessage.value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            controller.state.errorMessage.value,
                            style: const TextStyle(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),

                      // Match Name
                      _buildLabel('Match Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.state.nameController,
                        validator: controller.validateName,
                        textCapitalization: TextCapitalization.words,
                        decoration: _buildInputDecoration(
                          hintText: 'e.g., Morning Practice',
                          prefixIcon: Icons.edit_outlined,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Match Type
                      _buildLabel('Match Type'),
                      const SizedBox(height: 8),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.state.selectedMatchType.value,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                              items:
                                  controller.state.matchTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Row(
                                        children: [
                                          Icon(_getMatchTypeIcon(type), color: AppColors.primary, size: 20),
                                          const SizedBox(width: 12),
                                          Text(type),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                              onChanged: controller.setMatchType,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Number of Ends and Arrows per End (side by side)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Number of Ends'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: controller.state.endsController,
                                  validator: controller.validateEnds,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration(hintText: '10', prefixIcon: Icons.repeat),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Arrows per End'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: controller.state.arrowsPerEndController,
                                  validator: controller.validateArrowsPerEnd,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration(hintText: '3', prefixIcon: Icons.arrow_upward),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Total arrows info
                      Obx(() {
                        final total = controller.state.totalArrows.value;
                        if (total > 0) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Total: $total arrows',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
            ),
            // Floating Create button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.state.isLoading.value ? null : controller.createMatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child:
                        controller.state.isLoading.value
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary),
                            )
                            : const Text('Create Match', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }

  InputDecoration _buildInputDecoration({required String hintText, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textHint),
      prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  IconData _getMatchTypeIcon(String type) {
    switch (type) {
      case 'Range':
        return Icons.track_changes;
      case 'Moving Object':
        return Icons.moving;
      case 'Horseback':
        return Icons.pets;
      case 'Long Distance':
        return Icons.straighten;
      case 'Dynamic Shooting':
        return Icons.directions_run;
      default:
        return Icons.sports;
    }
  }
}
