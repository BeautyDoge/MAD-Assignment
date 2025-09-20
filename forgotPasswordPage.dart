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

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailCtrl.text.trim(),
        redirectTo: kIsWeb
            ? "${Uri.base.origin}/resetPasswordPage"
            : "io.supabase.flutterdemo://reset-callback",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset email sent. Please check your inbox."),
          ),
        );
        _emailCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 66),

                // Card container with shadow + rounded border
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22.0, vertical: 26.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Enter your email to reset password",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Custom email field
                        CustomTextField(
                          label: "Email",
                          hint: "abc@example.com",
                          leftIcon: Icons.mail_rounded,
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email cannot be empty";
                            }
                            if (!value.contains("@")) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 26),

                        // Custom button / loading indicator
                        _isLoading
                            ? const CircularProgressIndicator()
                            : CustomButton(
                          text: "Send Reset Link",
                          onPressed: _sendResetLink,
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


