import 'package:flutter/material.dart';

class AppToggle extends StatelessWidget {
  const AppToggle({
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      label: semanticLabel,
      child: SizedBox(
        width: 60,
        height: 44,
        child: Switch.adaptive(value: value, onChanged: onChanged),
      ),
    );
  }
}
