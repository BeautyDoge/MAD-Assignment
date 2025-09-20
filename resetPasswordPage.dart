import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'customTextField.dart';
import 'customButton.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Update password directly (session already restored by Supabase)
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordCtrl.text.trim()),
      );

      if (!mounted) return;

      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password updated successfully. Please log in again."),
        ),
      );

      // Log out after password reset
      await Supabase.instance.client.auth.signOut();

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update password: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 52.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 66),

              // Card container
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
                padding:
                const EdgeInsets.symmetric(horizontal: 22.0, vertical: 26.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Enter Your New Password",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Make sure your new password is different from your old one.",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // New password field
                      CustomTextField(
                        label: "New Password",
                        hint: "At least 8 characters",
                        leftIcon: Icons.lock_rounded,
                        controller: _newPasswordCtrl,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "New Password cannot be empty";
                          }
                          if (value.length < 8) {
                            return "Password must be at least 8 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm password field
                      CustomTextField(
                        label: "Confirm Password",
                        hint: "Re-enter new password",
                        leftIcon: Icons.lock_rounded,
                        controller: _confirmPasswordCtrl,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Confirm Password cannot be empty";
                          }
                          if (value != _newPasswordCtrl.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // Reset button
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomButton(
                        text: "Reset Password",
                        onPressed: _handleReset,
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
