import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lstracker/data/db/sample_dao.dart';
import 'package:lstracker/data/models/sample.dart';
import 'package:lstracker/data/services/log_service.dart';
import 'package:lstracker/features/samples/sample_types_screen.dart';

import '../features/samples/collect_context_screen.dart';
import '../features/sync/sync_screen.dart';

enum BottomTab { dashboard, collect, accept, sync }

/// Bottom navigation avec **badge dynamique** sur l'onglet Sync :
/// affiche le nombre d'éléments en attente (dirty + conflits) pour que
/// l'utilisateur sache à tout moment s'il a des données non synchronisées.
///
/// Le compteur est rafraîchi :
///  - au mount du widget
///  - à chaque log de la catégorie 'Sync' / 'AutoSync' (push, pull, etc.)
///  - périodiquement toutes les 30s
class GlobalBottomNav extends StatefulWidget {
  const GlobalBottomNav({
    super.key,
    required this.current,
    required this.userRole,
  });

  final BottomTab current;
  final String userRole;

  @override
  State<GlobalBottomNav> createState() => _GlobalBottomNavState();
}

class _GlobalBottomNavState extends State<GlobalBottomNav> {
  final SampleDao _dao = SampleDao();
  int _pending = 0;
  Timer? _refreshTimer;
  StreamSubscription<LogEntry>? _logSub;

  @override
  void initState() {
    super.initState();
    _refresh();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
    // Toute activité de sync logue → on rafraîchit le compteur.
    _logSub = LogService.instance.stream.listen((entry) {
      if (entry.tag == 'Sync' || entry.tag == 'AutoSync') {
        _refresh();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _logSub?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final dirty = await _dao.countDirty();
      final conflicts = await _dao.countConflicts();
      final total = dirty + conflicts;
      if (mounted && total != _pending) {
        setState(() => _pending = total);
      }
    } catch (_) {
      // silencieux : un compteur de UI ne doit pas faire planter l'app
    }
  }

  static ({BottomTab tab, IconData icon, IconData selectedIcon, String label}) _def(
    BottomTab t,
    IconData i,
    IconData si,
    String label,
  ) => (tab: t, icon: i, selectedIcon: si, label: label);

  List<({BottomTab tab, IconData icon, IconData selectedIcon, String label})> _allDefs() {
    return [
      _def(BottomTab.dashboard, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
      _def(BottomTab.sync, Icons.sync_outlined, Icons.sync, 'Sync'),
    ];
  }

  List<({BottomTab tab, IconData icon, IconData selectedIcon, String label})> _visibleForRole() {
    final all = _allDefs();
    switch (widget.userRole.toUpperCase()) {
      case 'ADMIN':
        return all;
      case 'CONVOYEUR':
        return all.where((d) => d.tab != BottomTab.collect).toList();
      case 'BIOLOGISTE':
        return all.where((d) => d.tab != BottomTab.accept).toList();
      default:
        return all
            .where((d) => d.tab == BottomTab.dashboard || d.tab == BottomTab.sync)
            .toList();
    }
  }

  int _selectedIndexFor(
    List<({BottomTab tab, IconData icon, IconData selectedIcon, String label})> defs,
  ) {
    final idx = defs.indexWhere((d) => d.tab == widget.current);
    return idx >= 0 ? idx : 0;
  }

  void _onTap(BuildContext context, BottomTab tab) {
    switch (tab) {
      case BottomTab.dashboard:
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/dashboard',
          (route) => false,
          arguments: {'role': widget.userRole},
        );
        break;
      case BottomTab.collect:
        Navigator.of(context).pushNamed(CollectContextScreen.route);
        break;
      case BottomTab.accept:
        Navigator.of(context).pushNamed(
          SampleTypesScreen.route,
          arguments: {
            'statuses': [
              SampleStatus.receivedAtDistrictLab,
              SampleStatus.receivedAtHub,
              SampleStatus.receivedAtReferenceLab,
              SampleStatus.receivedAtTbLab,
            ],
            'title': 'Échantillons déposés au labo',
          },
        );
        break;
      case BottomTab.sync:
        Navigator.of(context).pushNamed(SyncScreen.route).then((_) => _refresh());
        break;
    }
  }

  Widget _buildIcon(IconData iconData, {required bool selected, required bool isSync}) {
    final icon = Icon(iconData);
    if (!isSync || _pending == 0) return icon;
    // Badge rouge sur l'onglet Sync uniquement
    final label = _pending > 99 ? '99+' : '$_pending';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -8,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final defs = _visibleForRole();
    final selIndex = _selectedIndexFor(defs);

    return NavigationBar(
      selectedIndex: selIndex,
      onDestinationSelected: (i) => _onTap(context, defs[i].tab),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 5.0,
      shadowColor: Theme.of(context).colorScheme.onSurface,
      destinations: [
        for (final d in defs)
          NavigationDestination(
            icon: _buildIcon(d.icon, selected: false, isSync: d.tab == BottomTab.sync),
            selectedIcon: _buildIcon(d.selectedIcon, selected: true, isSync: d.tab == BottomTab.sync),
            label: d.label,
          ),
      ],
    );
  }
}
