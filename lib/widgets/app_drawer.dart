import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user == null) {
      return const Drawer();
    }

    final role = user.role;

    return Drawer(
      child: Column(
        children: [
          
          // PROFILE HEADER
          
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            accountName: Text(user.name),
            accountEmail: Text(role.toUpperCase()),
          ),

          
          // ROLE BASED MENU
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(
                  context,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: _dashboardRoute(role),
                ),

                if (role == 'employee') ...[
                  _drawerItem(
                    context,
                    icon: Icons.add,
                    label: 'Create Expense',
                    route: '/create-expense',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.receipt_long,
                    label: 'My Expenses',
                    route: '/my-expenses',
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.assignment,
                    label: 'My Reports',
                    route: '/my-reports',
                  ),
                ],

                if (role == 'manager') ...[
                  _drawerItem(
                    context,
                    icon: Icons.approval,
                    label: 'Pending Approvals',
                    route: '/manager-reports',
                  ),
                ],
                if (role == 'manager') ...[
                  _drawerItem(
                    context,
                    icon: Icons.check_circle_outline,
                    label: 'Approved Reports',
                    route: '/approved-reports',
                  ),
                ],
                if (role == 'manager') ...[
                  _drawerItem(
                    context,
                    icon: Icons.cancel_outlined,
                    label: 'Rejected Reports',
                    route: '/rejected-reports',
                  ),
                ],
                if (role == 'manager') ...[
                  _drawerItem(
                    context,
                    icon: Icons.bar_chart,
                    label: 'Team Analytics',
                    route: '/manager-analytics',
                  ),
                ],

                if (role == 'finance') ...[
                  _drawerItem(
                    context,
                    icon: Icons.payments,
                    label: 'Pending Payments',
                    route: '/finance-reports',
                  ),
                ],
                if (role == 'finance') ...[
                  _drawerItem(
                    context,
                    icon: Icons.payments,
                    label: 'Paid Payments',
                    route: '/payment-history',
                  ),
                ],

                // const Divider(),
                
                // _drawerItem(
                //   context,
                //   icon: Icons.person,
                //   label: 'Profile',
                //   route: '/profile',
                // ),
              ],
            ),
          ),

          
          // LOGOUT
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              _showLogoutConfirmDialog(context, ref);
            },

          ),
        ],
      ),
    );
  }
  void _showLogoutConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              ref.read(authProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  
  // HELPERS
  
  Widget _drawerItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String route,
      }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context); // close drawer
        Navigator.pushNamed(context, route);
      },
    );
  }

  String _dashboardRoute(String role) {
    switch (role) {
      case 'manager':
        return '/manager';
      case 'finance':
        return '/finance';
      default:
        return '/employee';
    }
  }
}
