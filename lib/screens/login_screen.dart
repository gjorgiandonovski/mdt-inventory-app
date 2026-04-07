import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;
  bool isSignUp = false;

  Future<void> _resetPassword() async {
    final strings = context.read<LanguageProvider>().strings;
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() => errorMessage = strings.loginFailed('missing-email'));
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await context.read<AuthProvider>().sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.resetPasswordSent)),
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      final message = (e.message ?? '').trim();
      final code = e.code.trim();
      final display = message.isEmpty ? code : '$code: $message';
      setState(() => errorMessage = strings.resetPasswordFailedPrefix + ': ' + display);
    } catch (_) {
      setState(() => errorMessage = strings.resetPasswordFailedPrefix);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _showResetDialog() async {
    final strings = context.read<LanguageProvider>().strings;
    final controller = TextEditingController(text: emailController.text.trim());
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.resetPassword),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: strings.emailLabel,
            hintText: 'name@mdt.gov.mk',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () async {
              emailController.text = controller.text.trim();
              Navigator.pop(ctx);
              await _resetPassword();
            },
            child: Text(strings.resetPassword),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> submit() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final strings = context.read<LanguageProvider>().strings;

    try {
      if (isSignUp) {
        if (passwordController.text != confirmPasswordController.text) {
          setState(() => errorMessage = strings.passwordsDoNotMatch);
          return;
        }
        await context.read<AuthProvider>().signUp(
          emailController.text,
          passwordController.text,
        );
      } else {
        await context.read<AuthProvider>().signIn(
          emailController.text,
          passwordController.text,
        );
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      final message = (e.message ?? '').trim();
      final code = e.code.trim();
      final display = message.isEmpty ? code : '$code: $message';
      debugPrint('Login failed: $display');
      setState(() => errorMessage = strings.loginFailed(display));
    } catch (_) {
      setState(() => errorMessage = strings.loginFailedUnknown);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final strings = context.watch<LanguageProvider>().strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSignUp ? strings.createAccountTitle : strings.loginTitle),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<AppLanguage>(
              value: language,
              onChanged: (value) {
                if (value == null) return;
                context.read<LanguageProvider>().language = value;
              },
              items: [
                DropdownMenuItem(
                  value: AppLanguage.en,
                  child: Text(strings.languageEnglish),
                ),
                DropdownMenuItem(
                  value: AppLanguage.mk,
                  child: Text(strings.languageMacedonian),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: strings.emailLabel,
                hintText: 'name@mdt.gov.mk',
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: strings.passwordLabel),
              textInputAction: isSignUp ? TextInputAction.next : TextInputAction.done,
            ),
            if (isSignUp) ...[
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: strings.confirmPasswordLabel),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),
              Text(
                strings.onlyMdtEmailNote,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 24),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: isLoading ? null : submit,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Text(isSignUp ? strings.createAccountTitle : strings.loginTitle),
            ),
            if (!isSignUp) ...[
              const SizedBox(height: 4),
              TextButton(
                onPressed: isLoading ? null : _showResetDialog,
                child: Text(
                  strings.forgotPassword,
                  style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.7),
                          ) ??
                      TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.7),
                      ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        isSignUp = !isSignUp;
                        errorMessage = null;
                      });
                    },
              child: Text(isSignUp ? strings.signInCta : strings.signUpCta),
            ),
          ],
        ),
      ),
    );
  }
}
