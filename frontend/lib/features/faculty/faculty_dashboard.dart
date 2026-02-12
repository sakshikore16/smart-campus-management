import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    try {
      final data = await ApiService.getUnreadCount();
      if (mounted) setState(() => _unreadCount = (data['count'] as num?)?.toInt() ?? 0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn || auth.user?.role != 'faculty') {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final name = auth.user?.name ?? 'Faculty';
    final profile = auth.facultyProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Dashboard'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _unreadCount > 0,
              label: Text('$_unreadCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              context.push('/faculty/notifications');
              _loadUnread();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await auth.fetchMe();
          _loadUnread();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, $name 👋', style: Theme.of(context).textTheme.titleLarge),
              if (profile != null && profile.subjects.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Subjects', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: profile.subjects.map((s) => Chip(label: Text(s))).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _DashboardCard(
                    icon: Icons.how_to_reg,
                    title: 'Mark Attendance',
                    onTap: () => context.push('/faculty/mark-attendance'),
                  ),
                  _DashboardCard(
                    icon: Icons.gavel,
                    title: 'Attendance Grievances',
                    onTap: () => context.push('/faculty/grievance-review'),
                  ),
                  _DashboardCard(
                    icon: Icons.pending_actions,
                    title: 'Student Leaves',
                    onTap: () => context.push('/faculty/student-leaves'),
                  ),
                  _DashboardCard(
                    icon: Icons.grade,
                    title: 'Upload Marks',
                    onTap: () => context.push('/faculty/upload-marks'),
                  ),
                  _DashboardCard(
                    icon: Icons.schedule,
                    title: 'Lecture Schedule',
                    onTap: () => context.push('/faculty/timetable'),
                  ),
                  _DashboardCard(
                    icon: Icons.payments,
                    title: 'Salary Slip',
                    onTap: () => context.push('/faculty/salary-slips'),
                  ),
                  _DashboardCard(
                    icon: Icons.event_busy,
                    title: 'Apply Leave',
                    onTap: () => context.push('/faculty/leaves'),
                  ),
                  _DashboardCard(
                    icon: Icons.badge,
                    title: 'ID Card Request',
                    onTap: () => context.push('/faculty/id-card-request'),
                  ),
                  _DashboardCard(
                    icon: Icons.campaign,
                    title: 'Notices',
                    onTap: () => context.push('/faculty/notices'),
                  ),
                  _DashboardCard(
                    icon: Icons.report_problem,
                    title: 'Complaints',
                    onTap: () => context.push('/faculty/complaints'),
                  ),
                  _DashboardCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Request Budget',
                    onTap: () => context.push('/faculty/budget-requests'),
                  ),
                  // _DashboardCard(
                  //   icon: Icons.notifications,
                  //   title: 'Notifications',
                  //   onTap: () {
                  //     context.push('/faculty/notifications');
                  //     _loadUnread();
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DashboardCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: SizedBox(
          width: 140,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: AppTheme.primary),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
