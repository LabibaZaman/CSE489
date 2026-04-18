import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  final AuthService _authService = AuthService();

  bool loading = false;

  void register() async {
    setState(() => loading = true);

    String? result = await _authService.registerUser(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
    );

    setState(() => loading = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: "Name")),
              const SizedBox(height: 10),

              TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
              const SizedBox(height: 10),

              TextField(controller: _phone, decoration: const InputDecoration(labelText: "Phone")),
              const SizedBox(height: 10),

              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),

              const SizedBox(height: 20),

              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: register,
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}