import 'package:flutter/material.dart';
import 'package:lstracker/data/services/meta_sync_service.dart';
import 'package:lstracker/features/common/account_menu_button.dart';
import 'package:lstracker/features/samples/sample_types_screen.dart';
import 'package:lstracker/utils/auth_utils.dart';
import 'package:lstracker/widgets/global_bottom_nav.dart';

import '../../data/db/sample_dao.dart';
import '../../data/models/sample.dart';
import '../../widgets/counter_card.dart';

class DashboardLabScreen extends StatefulWidget {
  const DashboardLabScreen({super.key});

  @override
  State<DashboardLabScreen> createState() => _DashboardLabScreenState();
}

class _DashboardLabScreenState extends State<DashboardLabScreen> {
  final dao = SampleDao();
  Map<String, int>? counters;
  List<Map<String, Object?>> toReceiveBadges = const [];
  List<Map<String, Object?>> receivedBadges = const [];
  List<Map<String, Object?>> rejectedBadges = const [];
  List<Map<String, Object?>> resultReadyBadges = const [];
  bool loading = true;
  bool syncing = false;

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

  Future<void> _syncMeta() async {
    if (syncing) return;
    setState(() => syncing = true);
    try {
      await MetaSyncService.refreshAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Métadonnées synchronisées')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la synchronisation: $e')),
      );
    } finally {
      if (mounted) setState(() => syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = counters ?? {};
    return FutureBuilder<String?>(
      future: AuthUtils.getUserRole(),
      builder: (context, snapshot) {
        final userRole = snapshot.data ?? 'ADMIN';
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tableau de bord — Biologiste'),
            actions: [
              AccountMenuButton(),
              /*       IconButton(
            tooltip: 'Recharger les métadonnées',
            onPressed: syncing ? null : _syncMeta,
            icon: syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_sync_outlined),
          ),*/
            ],
          ),
          bottomNavigationBar: GlobalBottomNav(
            current: BottomTab.dashboard,
            userRole: userRole,
          ),
          body: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 900
                      ? 4
                      : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    CounterCard(
                      actionTitle: '',
                      label: 'Collectés',
                      count: c['collected'] ?? 0,
                      icon: Icons.inventory_2_outlined,
                      /*onTap: () {
                    Navigator.of(context)
                        .pushNamed(
                          SampleTypesScreen.route,
                          arguments: {
                            'status': SampleStatus.collected,
                            'title': 'Echantillons collectés',
                          },
                        )
                        .then((_) => _load());
                  },*/
                    ),
                    CounterCard(
                      actionTitle: 'Recevoir des échantillons',
                      label: 'Déposés (labo)',
                      count: c['delivered'] ?? 0,
                      icon: Icons.biotech_outlined,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(
                              SampleTypesScreen.route,
                              arguments: {
                                'statuses': [
                                  SampleStatus.receivedAtDistrictLab,
                                  SampleStatus.receivedAtHub,
                                  SampleStatus.receivedAtReferenceLab,
                                  SampleStatus.receivedAtTbLab,
                                ],
                                'title': 'Echantillons déposés au labo',
                              },
                            )
                            .then((_) => _load());
                      },
                    ),
                    CounterCard(
                      actionTitle: 'Finaliser des analyses',
                      label: 'Reçus labo',
                      count: c['received'] ?? 0,
                      icon: Icons.verified_outlined,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(
                              SampleTypesScreen.route,
                              arguments: {
                                'statuses': [
                                  SampleStatus.acceptedAtDistrictLab,
                                  SampleStatus.acceptedAtHub,
                                  SampleStatus.acceptedAtReferenceLab,
                                  SampleStatus.acceptedAtTbLab,
                                ],
                                'title': 'Echantillons acceptés par le labo',
                              },
                            )
                            .then((_) => _load());
                      },
                    ),
                    CounterCard(
                      actionTitle: '',
                      label: 'Résultats prêts',
                      count: c['resultReady'] ?? 0,
                      icon: Icons.fact_check_outlined,
                    ),
                    CounterCard(
                      actionTitle: '',
                      label: 'Résultats récupérés',
                      count: c['resultCollected'] ?? 0,
                      icon: Icons.assignment_return_outlined,
                    ),
                    CounterCard(
                      actionTitle: '',
                      label: 'Résultats déposés',
                      count: c['resultDeposited'] ?? 0,
                      icon: Icons.assignment_turned_in_outlined,
                    ),
                    CounterCard(
                      actionTitle: '',
                      label: 'Rejetés',
                      count: c['rejected'] ?? 0,
                      icon: Icons.block_outlined,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(
                              SampleTypesScreen.route,
                              arguments: {
                                'status': SampleStatus.nonConform,
                                'title': 'Echantillons rejetés',
                              },
                            )
                            .then((_) => _load());
                      },
                    ),
                    CounterCard(
                      actionTitle: '',
                      label: 'Echoués',
                      count: c['analysisFailed'] ?? 0,
                      icon: Icons.report_problem_outlined,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(
                              SampleTypesScreen.route,
                              arguments: {
                                'status': SampleStatus.analysisFailed,
                                'title': 'Echantillons échoués',
                              },
                            )
                            .then((_) => _load());
                      },
                    ),
                  ],
                ),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
