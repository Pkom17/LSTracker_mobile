import 'package:flutter/material.dart';

class CounterCard extends StatelessWidget {
  const CounterCard({
    super.key,
    required this.label,
    required this.actionTitle,
    required this.count,
    required this.icon,
    this.onTap,
  });

  final String actionTitle;
  final String label;
  final int count;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Utilisation d'un InkWell pour un effet de "splash" lors du tap
    return InkWell(
      onTap: onTap,
      child: Card(
        // Utilisation du nouveau thème Material 3
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 2, // Réduit l'ombre pour un aspect plus léger
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Bordures plus arrondies
          side: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant, // Bordure très discrète
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                actionTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                icon,
                size: 36,
                color: Theme.of(
                  context,
                ).colorScheme.primary, // Couleur de l'icône
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
