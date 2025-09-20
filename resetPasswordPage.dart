// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'customTextField.dart';
// import 'customButton.dart';
//
// class ResetPasswordPage extends StatefulWidget {
//   final String? accessToken; // accept the reset token
//   const ResetPasswordPage({super.key, this.accessToken});
//
//   @override
//   State<ResetPasswordPage> createState() => _ResetPasswordPageState();
// }
//
// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final _newPasswordCtrl = TextEditingController();
//   final _confirmPasswordCtrl = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     _newPasswordCtrl.dispose();
//     _confirmPasswordCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reset Password'),
//       ),
//
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 52.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 66),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16.0),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Color(0x11000000),
//                         blurRadius: 8,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                     border: Border.all(color: const Color(0xFFE8E8E8)),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 26.0),
//                   // Reset Password Form
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'Enter Your New Password',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                         ),
//
//                         const SizedBox(height: 30),
//
//                         // New Password Field
//                         CustomTextField (
//                           label: 'New Password',
//                           hint: 'New Password must be at least 8 characters',
//                           leftIcon: Icons.lock_rounded,
//                           controller: _newPasswordCtrl,
//                           obscureText: true,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'New Password cannot be empty';
//                             }
//                             if (value.length < 8) {
//                               return 'New Password must be at least 8 characters';
//                             }
//                             return null;
//                           },
//                         ),
//
//                         const SizedBox(height: 26),
//
//                         // Confirm Password Field
//                         CustomTextField (
//                           label: 'Confirm Password',
//                           hint: 'Re-enter your new password',
//                           leftIcon: Icons.lock_rounded,
//                           controller: _confirmPasswordCtrl,
//                           obscureText: true,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Confirm Password cannot be empty';
//                             }
//                             if (value != _newPasswordCtrl.text) {
//                               return 'Passwords do not match';
//                             }
//                             return null;
//                           },
//                         ),
//
//                         const SizedBox(height: 26),
//
//                         // Reset Button
//                         _isLoading
//                         ? const CircularProgressIndicator()
//                         : CustomButton(
//                           text: 'Reset Password',
//                           onPressed: () async {
//                             if (_formKey.currentState!.validate()) {
//                               setState(() => _isLoading = true);
//
//                               try {
//                                 // Get the recovery code from the URL
//                                 final code = Uri.base.queryParameters['code'];
//                                 if (code == null) {
//                                   throw Exception("No recovery code found in URL.");
//                                 }
//
//                                 // Exchange code for session
//                                 final sessionResponse = await Supabase.instance.client.auth.exchangeCodeForSession(code);
//
//                                 if (sessionResponse.session == null) {
//                                   throw Exception("Failed to exchange code for session.");
//                                 }
//
//                                 // Update password
//                                 final updateResponse = await Supabase.instance.client.auth.updateUser(
//                                   UserAttributes(password: _newPasswordCtrl.text.trim()),
//                                 );
//
//                                 if (updateResponse.user != null) {
//                                   // Clear fields
//                                   _newPasswordCtrl.clear();
//                                   _confirmPasswordCtrl.clear();
//
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(content: Text(
//                                         'Password updated successfully. Please login again.')),
//                                   );
//
//                                   // Force logout after password reset
//                                   await Supabase.instance.client.auth.signOut();
//                                   Navigator.popUntil(context, (route) => route.isFirst);
//                                 }
//                               } catch (e) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(content: Text('Failed to reset password: $e')),
//                                 );
//                               } finally {
//                                 setState(() => _isLoading = false);
//                               }
//                             }
//                           }
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'customTextField.dart';
import 'customButton.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResetPasswordPage extends StatefulWidget {
  final String? accessToken; // recovery code
  const ResetPasswordPage({super.key, this.accessToken});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); // <-- ask user email again (for web)
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 52.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text('Enter Your New Password',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),

                // Email field (only for web fallback)
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
                const SizedBox(height: 20),

                // New Password
                CustomTextField(
                  label: 'New Password',
                  hint: 'At least 8 characters',
                  leftIcon: Icons.lock_rounded,
                  controller: _newPasswordCtrl,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'New Password cannot be empty';
                    }
                    if (value.length < 8) {
                      return 'New Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter new password',
                  leftIcon: Icons.lock_rounded,
                  controller: _confirmPasswordCtrl,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm Password cannot be empty';
                    }
                    if (value != _newPasswordCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                  text: 'Reset Password',
                  onPressed: () async {

                    final query = Uri.base.queryParameters;
                    final frag = Uri.splitQueryString(Uri.base.fragment.replaceFirst(RegExp(r'^[^?]*\??'), ''));
                    final code = query['code'] ?? frag['code'];
                    final email = query['email'];

                    if (!_formKey.currentState!.validate()) return;

                    setState(() => _isLoading = true);
                    try {
                      final code = widget.accessToken ??
                          Uri.base.queryParameters['code'] ??
                          Uri.splitQueryString(
                            Uri.base.fragment.replaceFirst(
                                RegExp(r'^[^?]*\??'), ''),
                          )['code'];

                      if (code == null) {
                        throw Exception("No recovery code found in URL.");
                      }

                      final client = Supabase.instance.client;

                      if (kIsWeb) {
                        // Web: no PKCE, so verifyOTP
                        final res = await client.auth.verifyOTP(
                          type: OtpType.recovery,
                          token: code,
                          email: email!,
                        );
                        if (res.session == null) throw Exception("verifyOTP failed");
                      } else {
                        // Mobile: PKCE works
                        final res = await client.auth.exchangeCodeForSession(code);
                        if (res.session == null) throw Exception("exchangeCodeForSession failed");
                      }

                      // Success
                      _newPasswordCtrl.clear();
                      _confirmPasswordCtrl.clear();
                      _emailCtrl.clear();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Password updated successfully. Please login again.')),
                      );

                      await client.auth.signOut();
                      if (context.mounted) {
                        Navigator.popUntil(
                            context, (route) => route.isFirst);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                            Text('Failed to reset password: $e')),
                      );
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
