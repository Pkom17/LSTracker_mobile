import 'package:flutter/material.dart';

/// En-tête de section de dashboard : titre + badge total.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.badge,
    this.accent,
  });

  final String title;
  final int badge;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        if (badge > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$badge',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}

/// Grille adaptative : 2 colonnes sur mobile, 3 sur tablette, 4 au-delà.
class CardsGrid extends StatelessWidget {
  const CardsGrid({super.key, required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w > 900 ? 4 : (w > 600 ? 3 : 2);
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      children: cards,
    );
  }
}

/// Bandeau d'aide affiché en tête des dashboards mobile pour expliquer
/// que les compteurs reflètent l'état actuel (snapshot temps réel) et
/// peuvent différer des chiffres du dashboard web (qui couvrent une
/// période). Dismissible — masqué pour la session en cours, réapparaît
/// au prochain login (la BD est purgée + la classe est rechargée).
class DashboardInfoNote extends StatefulWidget {
  const DashboardInfoNote({super.key});

  /// Drapeau partagé pour toute la session : une fois mis à true, le
  /// bandeau ne se ré-affiche plus tant que l'app n'est pas réinitialisée
  /// (cold start ou relogin via AuthService.login → purge + nav reset).
  static bool _dismissedForSession = false;

  /// À appeler depuis le flow logout/login pour resetter explicitement
  /// (par défaut le static survit aux navigations mais pas au cold start).
  static void resetForNewSession() {
    _dismissedForSession = false;
  }

  @override
  State<DashboardInfoNote> createState() => _DashboardInfoNoteState();
}

class _DashboardInfoNoteState extends State<DashboardInfoNote> {
  @override
  Widget build(BuildContext context) {
    if (DashboardInfoNote._dismissedForSession) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // blue-50
        border: Border(left: BorderSide(color: Colors.blue.shade400, width: 3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vue temps réel',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Les compteurs reflètent l'état actuel des échantillons (snapshot). "
                  "Les chiffres du tableau de bord web couvrent une période et peuvent donc différer.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade900,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Masquer pour cette session',
            icon: const Icon(Icons.close, size: 18),
            color: Colors.blue.shade700,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () {
              setState(() {
                DashboardInfoNote._dismissedForSession = true;
              });
            },
          ),
        ],
      ),
    );
  }
}

/// État vide pour un dashboard sans aucune donnée.
class EmptyDashboardState extends StatelessWidget {
  const EmptyDashboardState({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.science_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
