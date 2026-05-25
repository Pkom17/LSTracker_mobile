import 'package:flutter/material.dart';

/// Petit "skeleton" animé (shimmer) sans dépendance externe.
///
/// Utilisé en remplacement des `CircularProgressIndicator` plein écran
/// pour donner un retour visuel immédiat de la structure attendue.
/// Le shimmer alterne deux teintes via un [AnimatedBuilder] + un
/// [LinearGradient] qui se translate de gauche à droite.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 6,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (context, _) {
        final t = _ctl.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + 2 * t, 0),
                end: Alignment(1.0 + 2 * t, 0),
                colors: const [
                  Color(0xFFE9ECF1),
                  Color(0xFFF5F7FA),
                  Color(0xFFE9ECF1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton préfabriqué pour une carte "ligne d'échantillon" : avatar
/// circulaire + 2 lignes de texte + chevron. Reproduit visuellement la
/// densité d'un vrai [ListTile] dans les listes (sample_list, results_*).
class SampleTileSkeleton extends StatelessWidget {
  const SampleTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: const [
            Skeleton(width: 28, height: 28, borderRadius: 14),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 160, height: 14),
                  SizedBox(height: 8),
                  Skeleton(width: 220, height: 11),
                  SizedBox(height: 4),
                  Skeleton(width: 140, height: 11),
                ],
              ),
            ),
            SizedBox(width: 12),
            Skeleton(width: 18, height: 18, borderRadius: 9),
          ],
        ),
      ),
    );
  }
}

/// Liste de N skeletons espacés comme une vraie liste paginée.
/// `padding` reprend exactement les valeurs utilisées par les listes
/// (cf. SampleListScreen) pour que l'arrivée du contenu réel ne fasse
/// pas "sauter" l'écran.
class SampleListSkeleton extends StatelessWidget {
  const SampleListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (_, _) => const SampleTileSkeleton(),
    );
  }
}
