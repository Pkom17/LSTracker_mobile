import 'package:flutter/material.dart';

class BadgeSection extends StatelessWidget {
  final String title;
  final List<Map<String, Object?>> items; // expects keys: sample_type, cnt
  final void Function(String sampleType)? onTapType;

  const BadgeSection({
    super.key,
    required this.title,
    required this.items,
    this.onTapType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final it in items)
              ActionChip(
                label: Text(
                  '${(it['sample_type'] ?? 'N/A')} • ${(it['cnt'] ?? 0)}',
                ),
                onPressed: onTapType == null
                    ? null
                    : () => onTapType!.call('${it['sample_type'] ?? ''}'),
              ),
          ],
        ),
      ],
    );
  }
}
