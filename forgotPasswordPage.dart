  import 'package:flutter/material.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'package:flutter/foundation.dart' show kIsWeb;
  import 'customTextField.dart';
  import 'customButton.dart';

  class ForgotPasswordPage extends StatefulWidget {
    const ForgotPasswordPage({super.key});

    @override
    State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
  }

  class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
    final _emailCtrl = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    bool _isLoading = false;

    @override
    void dispose() {
      _emailCtrl.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x11000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Color(0xFFE8E8E8)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 26.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            'Enter your email to reset password',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 30),

                          // Email field
                          CustomTextField(
                            label: 'Email',
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

                          const SizedBox(height: 26),

                          _isLoading
                              ? const CircularProgressIndicator()
                              : CustomButton(
                            text: 'Send Reset Link',
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);
                                try {
                                  await Supabase.instance.client.auth.resetPasswordForEmail(
                                    _emailCtrl.text.trim(),
                                    redirectTo: kIsWeb
                                      // ? '${Uri.base.origin}/resetPasswordPage'        // for web
                                      ? '${Uri.base.origin}/resetPasswordPage?email=${_emailCtrl.text.trim()}'        // for web
                                      : 'io.supabase.flutterdemo://reset-callback',   // for emulator
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Password reset email sent. Please check your inbox.')),
                                  );

                                  _emailCtrl.clear();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                } finally {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
                          ),
                        ],
                      ),
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
