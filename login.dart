import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'customTextField.dart';
import 'customButton.dart';
import 'forgotPasswordPage.dart';
import 'resetPasswordPage.dart';
import 'managerDashboard.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://fslfjrhryjroacsfxaqf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzbGZqcmhyeWpyb2Fjc2Z4YXFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcyNTA4OTksImV4cCI6MjA3MjgyNjg5OX0.55h3kWxFzcEJYElcPqFwdtAAuLqmTKHMA3v9dFBS18c',
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event  = data.event;
    final session = data.session;

    if (event == AuthChangeEvent.passwordRecovery) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.base; // This is the URL the app was opened with
    String initialRoute = '/';

    // Handle Supabase recovery link
    if (uri.fragment.contains('resetPasswordPage') || uri.path.contains('resetPasswordPage')) {
      initialRoute = '/resetPasswordPage';
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Job Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE6E6E6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      initialRoute: initialRoute,
      routes: {
        // '/': (context) => const LoginPage(),
        // '/resetPasswordPage': (context) {
        //   final accessToken  = Uri.base.queryParameters['access_token'];
        //   return ResetPasswordPage(accessToken : accessToken );
        // },

        '/': (context) => const LoginPage(),
        '/resetPasswordPage': (context) {
          // Code may come from query OR fragment (because Supabase sends it differently for web)
          final queryParams = Uri.base.queryParameters;

          // Try parsing fragment params too, in case it's like: #/resetPasswordPage?code=xxxx
          Map<String, String> fragParams = {};
          if (Uri.base.fragment.contains('?')) {
            fragParams = Uri.splitQueryString(
              Uri.base.fragment.split('?').last,
            );
          }

          final code = queryParams['code'] ?? fragParams['code'];

          return ResetPasswordPage(accessToken: code);
        },
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;
    // final cardWidth = screenWidth * 0.88;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Management'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 66),
                Container(
                  //width: cardWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: const[
                      BoxShadow(
                        //color: Color(0x11000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 26.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 6),
                      const Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Sign in to manage your workshop operations.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),

                      const SizedBox(height: 48),

                      // Login Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email Field
                            CustomTextField(
                              label: 'Email Address',
                              hint: 'abc@example.com',
                              leftIcon: Icons.mail_rounded,
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email cannot be empty';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // Password Field
                            CustomTextField(
                              label: 'Password',
                              hint: '••••••••',
                              leftIcon: Icons.lock_rounded,
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              suffix: IconButton(
                                padding: const EdgeInsets.only(right: 8.0),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.black54,
                                ),
                                onPressed: () => setState(() {
                                  _obscure = !_obscure;
                                }),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password cannot be empty';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 26),

                            // Login button
                            CustomButton(
                              text: 'Login',
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final email = _emailCtrl.text.trim();
                                  final password = _passwordCtrl.text.trim();

                                  try {
                                    final response = await Supabase.instance.client.auth.signInWithPassword(
                                      email: email,
                                      password: password
                                    );

                                    if (response.user != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Login Successfully'))
                                      );
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const ManagerDashboard())
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Login Failed: Invalid email or password.'))
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Unexpected Error: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),

                      // Forgot Password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.indigo,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
