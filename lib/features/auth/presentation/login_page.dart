import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_management_app/core/theme.dart';
import '../../../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'Employee';

  
  // ROLE BASED TEST CREDENTIALS
  
  Map<String, Map<String, String>> get _testAccounts => {
    'Employee': {
      'username': 'emp1',
      'password': 'emp1',
    },
    'Manager': {
      'username': 'mgr1',
      'password': 'mgr1',
    },
    'Finance': {
      'username': 'fin1',
      'password': 'fin1',
    },
  };

  void _copyCredentials() {
    final creds = _testAccounts[_selectedRole]!;
    Clipboard.setData(
      ClipboardData(
        text: 'Username: ${creds['username']}\nPassword: ${creds['password']}',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selectedRole} credentials copied to clipboard',
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final role = _selectedRole.toLowerCase();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    await ref.read(authProvider.notifier).login(
      username,
      password,
      role,
    );

    final auth = ref.read(authProvider);

    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Login failed')),
      );
      return;
    }

    switch (auth.user!.role) {
      case 'employee':
        Navigator.pushReplacementNamed(context, '/employee');
        break;
      case 'manager':
        Navigator.pushReplacementNamed(context, '/manager');
        break;
      case 'finance':
        Navigator.pushReplacementNamed(context, '/finance');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final creds = _testAccounts[_selectedRole]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.black,
        title: const Text('Expense App - Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Login as',
                ),
                items: const [
                  DropdownMenuItem(value: 'Employee', child: Text('Employee')),
                  DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                  DropdownMenuItem(value: 'Finance', child: Text('Finance')),
                ],
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),



              const SizedBox(height: 16),

              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Username required' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Password required';
                  }
                  if (v.length < 4) {
                    return 'Password too short';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.loading ? null : _login,
                  child: auth.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('LOGIN'),
                ),
              ),

              const SizedBox(height: 12),

              
              // TEST CREDENTIAL INFO


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedRole} Account Test Credentials',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      _buildCredentialTile(context, 'Username:', '${creds['username']}'),
                      const SizedBox(height: 8),
                      _buildCredentialTile(context, 'Password:', '${creds['password']}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


Widget _buildCredentialTile(
    BuildContext context, String label, String value) {
  return InkWell(
    onTap: () => Clipboard.setData(ClipboardData(text: value)),
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepPurple.shade100, width: 1),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.blueAccent[200],
              fontWeight: FontWeight.w700,
            ),
          ),
          Icon(Icons.copy, size: 18, color: Colors.blueAccent[200],),
        ],
      ),
    ),
  );
}