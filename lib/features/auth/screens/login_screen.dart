import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController(text: AppConstants.mockEmail);
  final _passwordController =
      TextEditingController(text: AppConstants.mockPassword);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.main,
        (route) => false,
      );
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign In To MemoQuest',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use the demo account below to test the full app flow.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            AppTextField(
                              controller: _emailController,
                              label: 'Email',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _passwordController,
                              label: 'Password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              validator: Validators.password,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Demo: ${AppConstants.mockEmail} / ${AppConstants.mockPassword}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              label: 'Sign In',
                              icon: Icons.login,
                              isLoading: authProvider.isLoading,
                              onPressed: _submit,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
