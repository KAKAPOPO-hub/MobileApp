import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/field_input.dart';
import '../services/auth_session.dart';
import '../config/api_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      if (response.statusCode == 200) {
        final responseData = data['data'] as Map<String, dynamic>;
        AuthSession.token = responseData['token']?.toString();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login berhasil. ')));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']?.toString() ?? 'Login gagal')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server tidak dapat dihubungi')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Image.asset(
                  'assets/image/blogapp-assets.jpg',
                  height: 180,
                  width: 380,
                  fit: BoxFit.contain,
                ),
              ),
              const Center(
                child: Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FieldInput(
                controller: _emailController,
                label: 'Email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@')
                    ? 'Email tidak valid'
                    : null,
              ),
              const SizedBox(height: 16),
              FieldPasswordInput(
                controller: _passwordController,
                validator: (value) => value == null || value.length < 6
                    ? 'Minimal 6 karakter'
                    : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _login,
                child: Text(_loading ? 'Memproses...' : 'Login'),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1)),
                    const SizedBox(width: 12),
                    const Text('OR', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 12),
                    const Expanded(child: Divider(thickness: 1)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: SvgPicture.asset(
                  'assets/image/google_logo.svg',
                  width: 20,
                  height: 20,
                ),
                label: const Text('Log in with Google'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const FaIcon(
                  FontAwesomeIcons.apple,
                  size: 20,
                  color: Colors.black,
                ),
                label: const Text('Log in with Apple'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/register'),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: 'Create an account',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
