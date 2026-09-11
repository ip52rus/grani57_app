import 'package:flutter/material.dart';

import '../../core/design_system/components/app_button.dart';
import '../../core/design_system/components/app_checkbox.dart';
import '../../core/design_system/components/app_text_field.dart';
import '../../core/design_system/components/app_toggle.dart';
import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/tokens/app_spacing.dart';
import '../../core/design_system/typography/app_typography.dart';
import '../../core/mock_runtime/demo_session.dart';

class DevelopmentDemoScreen extends StatefulWidget {
  const DevelopmentDemoScreen({required this.session, super.key});

  final DemoSession session;

  @override
  State<DevelopmentDemoScreen> createState() => _DevelopmentDemoScreenState();
}

class _DevelopmentDemoScreenState extends State<DevelopmentDemoScreen> {
  bool _toggleValue = true;
  bool _checkboxValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '57 ГРАНЕЙ',
                style: AppTypography.title.copyWith(color: AppColors.brand),
              ),
              const SizedBox(height: AppSpacing.x8),
              Text(
                'Development foundation',
                style: AppTypography.heading.copyWith(color: AppColors.text),
              ),
              const SizedBox(height: AppSpacing.x8),
              Text(
                'Role: ${widget.session.role?.name ?? 'none'}',
                style: AppTypography.small.copyWith(color: AppColors.secondary),
              ),
              const SizedBox(height: AppSpacing.x24),
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.radius20,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.x20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppTextField(
                        label: 'Demo field',
                        hintText: 'Focus and keyboard check',
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: AppSpacing.x16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Demo toggle',
                            style: AppTypography.body.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                          AppToggle(
                            value: _toggleValue,
                            semanticLabel: 'Demo toggle',
                            onChanged: (value) {
                              setState(() => _toggleValue = value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.x12),
                      Row(
                        children: [
                          AppCheckbox(
                            value: _checkboxValue,
                            semanticLabel: 'Demo checkbox',
                            onChanged: (value) {
                              setState(() => _checkboxValue = value ?? false);
                            },
                          ),
                          const SizedBox(width: AppSpacing.x8),
                          Expanded(
                            child: Text(
                              'Demo checkbox',
                              style: AppTypography.body.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.x20),
                      AppButton(
                        label: 'Primary action',
                        semanticLabel: 'Primary demo action',
                        onPressed: () {},
                      ),
                      const SizedBox(height: AppSpacing.x12),
                      AppButton(
                        label: 'Loading action',
                        isLoading: true,
                        onPressed: () {},
                      ),
                      const SizedBox(height: AppSpacing.x12),
                      const AppButton(
                        label: 'Disabled action',
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
