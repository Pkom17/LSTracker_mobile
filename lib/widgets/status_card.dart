import 'package:flutter/material.dart';

/// Carte compacte de statut pour le dashboard : un compteur animé, une
/// icône colorée selon l'accent et un libellé. Différencie visuellement
/// les statuts actionnables (`actionable: true` → couleur primaire +
/// chevron) des statuts purement informatifs (gris doux).
///
/// Le compteur utilise un `AnimatedSwitcher` : quand la valeur change
/// (après une synchro), l'ancien chiffre fade out et le nouveau fade in
/// — petit feedback visuel discret pour l'utilisateur sur le terrain.
class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    this.onTap,
    this.accent,
    this.actionable = false,
  });

  final String label;
  final int count;
  final IconData icon;
  final VoidCallback? onTap;

  /// Teinte d'accent (icône + halo). Si null, dérivée du thème.
  final Color? accent;

  /// Si true, affiche un petit chevron et utilise une couleur d'accent
  /// plus marquée pour signaler que la carte mène à une action.
  final bool actionable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = accent ?? theme.colorScheme.primary;
    final tappable = onTap != null;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: actionable
                  ? accentColor.withValues(alpha: 0.35)
                  : theme.colorScheme.outlineVariant,
              width: actionable ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  const Spacer(),
                  if (actionable && tappable)
                    Icon(Icons.chevron_right,
                        color: accentColor, size: 20),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                child: Text(
                  '$count',
                  key: ValueKey<int>(count),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
