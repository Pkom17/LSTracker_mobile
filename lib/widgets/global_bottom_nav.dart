import 'package:flutter/material.dart';
import 'package:lstracker/data/models/sample.dart';
import 'package:lstracker/features/samples/sample_types_screen.dart';

import '../features/samples/collect_context_screen.dart';
import '../features/sync/sync_screen.dart';

enum BottomTab { dashboard, collect, accept, sync }

class GlobalBottomNav extends StatelessWidget {
  const GlobalBottomNav({
    super.key,
    required this.current,
    required this.userRole, // <- rôle injecté
  });

  final BottomTab current;
  final String
  userRole; // valeurs attendues: 'ADMIN', 'CONVOYEUR', 'BIOLOGISTE'

  // Définition d’un “onglet” avec sa logique
  static ({BottomTab tab, Icon icon, Icon selectedIcon, String label}) _def(
    BottomTab t,
    IconData i,
    IconData si,
    String label,
  ) => (tab: t, icon: Icon(i), selectedIcon: Icon(si), label: label);

  List<({BottomTab tab, Icon icon, Icon selectedIcon, String label})>
  _allDefs() {
    return [
      _def(
        BottomTab.dashboard,
        Icons.dashboard_outlined,
        Icons.dashboard,
        'Dashboard',
      ),
      _def(BottomTab.sync, Icons.sync_outlined, Icons.sync, 'Sync'),
    ];
    // NB: on filtre par rôle plus bas
  }

  // Filtrage selon le rôle
  List<({BottomTab tab, Icon icon, Icon selectedIcon, String label})>
  _visibleForRole() {
    final all = _allDefs();
    switch (userRole.toUpperCase()) {
      case 'ADMIN':
        return all;
      case 'CONVOYEUR':
        // Demande: convoyeur NE voit PAS "Collecte"
        return all.where((d) => d.tab != BottomTab.collect).toList();
      case 'BIOLOGISTE':
        // Demande: labo NE voit PAS "Accepter"
        return all.where((d) => d.tab != BottomTab.accept).toList();
      default:
        // par défaut on reste prudent : dashboard + sync
        return all
            .where(
              (d) => d.tab == BottomTab.dashboard || d.tab == BottomTab.sync,
            )
            .toList();
    }
  }

  int _selectedIndexFor(
    List<({BottomTab tab, Icon icon, Icon selectedIcon, String label})> defs,
  ) {
    final idx = defs.indexWhere((d) => d.tab == current);
    return idx >= 0 ? idx : 0;
  }

  void _onTap(BuildContext context, BottomTab tab) {
    switch (tab) {
      case BottomTab.dashboard:
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/dashboard',
          (route) => false,
          arguments: {'role': userRole},
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
        Navigator.of(context).pushNamed(SyncScreen.route);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defs = _visibleForRole();
    final selIndex = _selectedIndexFor(defs);

    return NavigationBar(
      selectedIndex: selIndex,
      onDestinationSelected: (i) => _onTap(context, defs[i].tab),
      backgroundColor: Theme.of(context).colorScheme.surface,
      // Ajoute de la profondeur pour distinguer la barre
      elevation: 5.0,
      shadowColor: Theme.of(context).colorScheme.onSurface,
      destinations: [
        for (final d in defs)
          NavigationDestination(
            icon: d.icon,
            selectedIcon: d.selectedIcon,
            label: d.label,
          ),
      ],
    );
  }
}
