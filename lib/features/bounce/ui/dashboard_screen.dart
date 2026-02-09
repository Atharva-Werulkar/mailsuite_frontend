import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/ux_utils.dart';
import '../../mailbox/ui/mailbox_list_screen.dart';
import '../bloc/bounce_bloc.dart';
import '../bloc/bounce_event.dart';
import '../bloc/bounce_state.dart';
import '../widgets/bounce_breakdown_chart.dart';
import '../widgets/stats_card.dart';
import 'bounce_list_screen.dart';

/// Dashboard Screen - Shows bounce statistics and overview
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    context.read<BounceBloc>().add(LoadBounceStatsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MailSuite Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: () {
              UxUtils.buttonTap();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MailboxListScreen(),
                ),
              );
            },
            tooltip: 'Mailboxes',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              UxUtils.buttonTap();
              _loadDashboardData();
            },
          ),
        ],
      ),
      body: BlocConsumer<BounceBloc, BounceState>(
        listener: (context, state) {
          if (state is BounceError) {
            UxUtils.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is BounceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BounceStatsLoaded) {
            final stats = state.stats;
            return RefreshIndicator(
              onRefresh: () async {
                _loadDashboardData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions Cards
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: InkWell(
                              onTap: () {
                                UxUtils.buttonTap();
                                Navigator.pushNamed(context, '/inbox');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inbox,
                                      size: 32,
                                      color: Colors.blue.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Inbox',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            child: InkWell(
                              onTap: () {
                                UxUtils.buttonTap();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MailboxListScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      size: 32,
                                      color: Colors.purple.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Mailboxes',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            child: InkWell(
                              onTap: () {
                                UxUtils.buttonTap();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BounceListScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      size: 32,
                                      color: Colors.orange.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Bounces',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Total Failures',
                            value: stats.totalFailures.toString(),
                            icon: Icons.error_outline,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatsCard(
                            title: 'Unique Emails',
                            value: stats.uniqueEmails.toString(),
                            icon: Icons.email_outlined,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Bounce Type Breakdown
                    const Text(
                      'Bounce Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    BounceBreakdownChart(bouncesByType: stats.byType),
                    const SizedBox(height: 24),

                    // Recent Bounces Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Trend',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            UxUtils.buttonTap();
                            UxUtils.navigateToWithSlide(
                              context,
                              const BounceListScreen(),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRecentActivity(stats.recentCount, stats.last7Days),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.dashboard, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No data available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadDashboardData,
                  child: const Text('Load Dashboard'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivity(int recentCount, int last7Days) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActivityStat(
                  'Recent Bounces',
                  recentCount.toString(),
                  Icons.mail_outline,
                  Colors.orange,
                ),
                _buildActivityStat(
                  'Last 7 Days',
                  last7Days.toString(),
                  Icons.trending_up,
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
