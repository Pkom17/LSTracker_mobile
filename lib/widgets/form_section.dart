import 'package:flutter/material.dart';

/// Section de formulaire encadrée : un en-tête (icône + titre + sous-titre
/// optionnel) puis le corps. Conçue pour les longs formulaires terrain
/// (collecte, dépôt, etc.) afin de découper en blocs digestes plutôt
/// qu'une longue liste de champs alignés.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Corps
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: child,
          ),
        ],
      ),
    );
  }
}
