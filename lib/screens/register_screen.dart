import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _skills = TextEditingController();
  String _role = 'customer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'customer',
                      label: Text('Customer'),
                      icon: Icon(Icons.person),
                    ),
                    ButtonSegment(
                      value: 'technician',
                      label: Text('Technician'),
                      icon: Icon(Icons.engineering),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (value) =>
                      setState(() => _role = value.first),
                ),
                const SizedBox(height: 16),
                _field(_name, 'Full name', Icons.badge_outlined),
                _field(_email, 'Email', Icons.email_outlined, email: true),
                _field(
                  _password,
                  'Password',
                  Icons.lock_outline,
                  password: true,
                ),
                _field(_phone, 'Phone', Icons.phone_outlined),
                _field(
                  _address,
                  'Address',
                  Icons.location_on_outlined,
                  maxLines: 2,
                ),
                if (_role == 'technician')
                  _field(
                    _skills,
                    'Skills, for example fridge, cooker, washer',
                    Icons.handyman_outlined,
                    maxLines: 2,
                  ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _register,
                  icon: const Icon(Icons.person_add_alt),
                  label: Text(
                    _role == 'technician'
                        ? 'Register for approval'
                        : 'Register',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool email = false,
    bool password = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: password,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<AuthProvider>().register({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text,
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
        'role': _role,
        'skills': _skills.text.trim(),
      });
      if (mounted && _role == 'technician') {
        showToast(
          context,
          'Registered. Your technician account is pending admin approval.',
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (mounted) showToast(context, error.message, error: true);
    }
  }
}
