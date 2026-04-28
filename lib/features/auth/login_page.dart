import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../dashboard/main_layout.dart';
import 'auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  static const String routePath = '/login';

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Bypass local para pruebas
    if (email == 'admin' && password == '123456') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bienvenido, Admin (Modo Local)')));
      context.go(MainLayout.routePath);
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: email,
          password: password,
        );

    final authState = ref.read(authControllerProvider);

    authState.whenOrNull(
      data: (user) {
        if (user != null && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Bienvenido, ${user.nombre}')));
          
          context.go(MainLayout.routePath);
        }
      },
      error: (error, _) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  const SizedBox(height: 42),

                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 23),

                  const Text(
                    'SmartBudget+',
                    style: AppTextStyles.logoTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Bienvenido de vuelta',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 37),

                  Container(
                    padding: const EdgeInsets.fromLTRB(27, 27, 27, 30),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Correo electrónico',
                            style: AppTextStyles.label,
                          ),
                          const SizedBox(height: 12),
                          _PlainTextField(
                            controller: _emailController,
                            hintText: 'tu@email.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final email = value?.trim() ?? '';

                              if (email.isEmpty) {
                                return 'Ingresa tu usuario o correo.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 25),

                          const Text('Contraseña', style: AppTextStyles.label),
                          const SizedBox(height: 12),
                          _PlainTextField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            validator: (value) {
                              final password = value?.trim() ?? '';

                              if (password.isEmpty) {
                                return 'Ingresa tu contraseña.';
                              }

                              if (password.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 28),

                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Iniciar sesión'),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Row(
                            children: const [
                              Expanded(
                                child: Divider(color: AppColors.divider),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'o continúa con',
                                  style: AppTextStyles.small,
                                ),
                              ),
                              Expanded(
                                child: Divider(color: AppColors.divider),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          const _SocialButton(
                            iconText: 'G',
                            label: 'Continuar con Google',
                          ),

                          const SizedBox(height: 14),

                          const _SocialButton(
                            iconText: 'f',
                            label: 'Continuar con Facebook',
                          ),

                          const SizedBox(height: 14),

                          const _SocialButton(
                            iconText: '',
                            label: 'Continuar con Apple',
                          ),

                          const SizedBox(height: 36),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¿No tienes una cuenta? ',
                                style: AppTextStyles.small,
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Luego conectamos con RegisterPage.
                                },
                                child: const Text(
                                  'Regístrate',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlainTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _PlainTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String iconText;
  final String label;

  const _SocialButton({required this.iconText, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceSoft,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              iconText,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 18),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
