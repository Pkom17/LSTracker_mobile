import 'package:flutter/material.dart';
import 'package:lstracker/features/dashboard/dashboard_admin_screen.dart';
import 'package:lstracker/features/dashboard/dashboard_conveyor_screen.dart';
import 'package:lstracker/features/dashboard/dashboard_lab_screen.dart';
import 'package:lstracker/features/dashboard/dashboard_user_screen.dart';

import '../../data/db/sample_dao.dart';

class DashboardScreen extends StatefulWidget {
  final String userRole;
  const DashboardScreen({super.key, required this.userRole});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final dao = SampleDao();
  Map<String, int>? counters;
  List<Map<String, Object?>> collectedBadges = const [];
  List<Map<String, Object?>> deliveredBadges = const [];
  List<Map<String, Object?>> rejectedBadges = const [];
  List<Map<String, Object?>> resultsCollectedBadges = const [];
  List<Map<String, Object?>> resultsDepositedBadges = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final c = await dao.dashboardCounters();
    if (!mounted) return;
    setState(() {
      counters = c;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userRole == 'CONVOYEUR') {
      return const DashboardConveyorScreen();
    } else if (widget.userRole == 'BIOLOGISTE') {
      return const DashboardLabScreen();
    } else if (widget.userRole == 'USER') {
      return const DashboardUserScreen();
    } else if (widget.userRole == 'ADMIN') {
      return const DashboardAdminScreen();
    }
    return const Scaffold(body: Center(child: Text('Rôle non reconnu')));
  }
}
