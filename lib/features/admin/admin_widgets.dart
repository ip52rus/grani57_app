import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/tokens/app_colors.dart';
import '../../core/design_system/tokens/app_radii.dart';
import '../../core/design_system/typography/app_typography.dart';

class AdminGradientTitle extends StatelessWidget {
  const AdminGradientTitle(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (bounds) => const LinearGradient(
      colors: [
        AppColors.brand,
        AppColors.sky,
        Color(0xFFA46BD5),
        AppColors.coral,
        AppColors.accent,
        AppColors.brand,
      ],
      stops: [0, .32, .48, .62, .76, 1],
    ).createShader(bounds),
    child: Text(text, style: style ?? AppTypography.title),
  );
}

class AdminScreenHeader extends StatelessWidget {
  const AdminScreenHeader({
    required this.title,
    super.key,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (onBack != null) ...[
            SizedBox.square(
              dimension: 40,
              child: IconButton(
                key: const ValueKey('admin.header.back'),
                onPressed: onBack,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  overlayColor: Colors.transparent,
                  foregroundColor: AppColors.brand,
                ),
                icon: SvgPicture.asset(
                  'assets/icons/actions/back.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(color: AppColors.brand),
            ),
          ),
          ?trailing,
        ],
      ),
    ),
  );
}

class AdminBadge extends StatelessWidget {
  const AdminBadge(this.label, {super.key, this.success = false});

  final String label;
  final bool success;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: success ? AppColors.successBg : AppColors.soft,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: AppTypography.caption.copyWith(
        color: success ? AppColors.success : AppColors.brand,
      ),
    ),
  );
}

class AdminBottomNavigation extends StatelessWidget {
  const AdminBottomNavigation({
    required this.index,
    required this.onChanged,
    super.key,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 80,
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: Color(0xFFF0F3F8))),
    ),
    child: Row(
      children: [
        _AdminNavItem(
          key: const ValueKey('admin.nav.home'),
          label: 'Главная',
          activeAsset: 'assets/icons/navigation/nav_home_active_clean.svg',
          inactiveAsset: 'assets/icons/navigation/nav_home_inactive_clean.svg',
          selected: index == 0,
          onTap: () => onChanged(0),
        ),
        _AdminNavItem(
          key: const ValueKey('admin.nav.publications'),
          label: 'Публикации',
          activeAsset: 'assets/icons/navigation/nav_documents_active_clean.svg',
          inactiveAsset:
              'assets/icons/navigation/nav_documents_inactive_clean.svg',
          selected: index == 1,
          onTap: () => onChanged(1),
        ),
        _AdminNavItem(
          key: const ValueKey('admin.nav.doctors'),
          label: 'Врачи',
          activeAsset: 'assets/icons/navigation/nav_profile_active_clean.svg',
          inactiveAsset:
              'assets/icons/navigation/nav_profile_inactive_clean.svg',
          selected: index == 2,
          onTap: () => onChanged(2),
        ),
      ],
    ),
  );
}

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
    required this.label,
    required this.activeAsset,
    required this.inactiveAsset,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final String activeAsset;
  final String inactiveAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            selected ? activeAsset : inactiveAsset,
            width: 24,
            height: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              color: selected ? AppColors.brand : AppColors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 18,
            height: 2,
            decoration: BoxDecoration(
              color: selected ? AppColors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    ),
  );
}

class AdminFormField extends StatelessWidget {
  const AdminFormField({
    required this.label,
    required this.controller,
    super.key,
    this.hint,
    this.helper,
    this.maxLines = 1,
    this.inputHeight,
    this.obscureText = false,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final int maxLines;
  final double? inputHeight;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTypography.caption.copyWith(color: AppColors.secondary),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: inputHeight ?? (maxLines == 1 ? 68 : 102),
        child: TextField(
          key: key,
          controller: controller,
          maxLines: obscureText ? 1 : maxLines,
          obscureText: obscureText,
          enableSuggestions: false,
          autocorrect: false,
          enableInteractiveSelection: false,
          magnifierConfiguration: TextMagnifierConfiguration.disabled,
          onChanged: onChanged,
          style: AppTypography.small.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.small.copyWith(color: AppColors.secondary),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(14),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.brand, width: 1.5),
          ),
        ),
      ),
      if (helper != null) ...[
        const SizedBox(height: 6),
        Text(
          helper!,
          style: AppTypography.caption.copyWith(color: AppColors.secondary),
        ),
      ],
    ],
  );

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: AppRadii.radius12,
        borderSide: BorderSide(color: color, width: width),
      );
}

class AdminCard extends StatelessWidget {
  const AdminCard({required this.child, super.key, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadii.radius20,
      boxShadow: [
        BoxShadow(
          color: Color(0x0D173866),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}
