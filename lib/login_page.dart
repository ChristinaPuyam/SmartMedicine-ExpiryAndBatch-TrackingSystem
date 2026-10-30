import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Check empty fields
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter email and password',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading
    setState(() {
      isLoading = true;
    });

    try {
      // Send login data to Node.js API
      final result = await ApiService.login(
        email,
        password,
      );

      // Check login result
      if (result['success'] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Successful'),
            backgroundColor: Colors.green,
          ),
        );

        // Go to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const DashboardPage(),
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  'Invalid Email or Password',
            ),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connection error: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Card(
            elevation: 8,

            child: Padding(
              padding: const EdgeInsets.all(25),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [

                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.medical_services,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Medicine Tracking System',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Login to continue',
                  ),

                  const SizedBox(height: 25),

                  // EMAIL FIELD
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,

                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // PASSWORD FIELD
                  TextField(
                    controller: passwordController,
                    obscureText: true,

                    onSubmitted: (_) {
                      if (!isLoading) {
                        login();
                      }
                    },

                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : login,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.all(15),
                      ),

                      child: isLoading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                        CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'LOGIN',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}