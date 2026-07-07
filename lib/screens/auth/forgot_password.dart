// lib/screens/auth/forgot_password.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isEmailFocused = false;
  bool _isPhoneFocused = false;
  bool _isNewPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSc1gKNq-pipYogGaoVtuagtKO8NjtxBJx7LkYySN-8pA&s=10',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.65), // Enhanced filter
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Watermark Text
              Positioned(
                bottom: 30,
                right: 20,
                child: Opacity(
                  opacity: 0.15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'NIT\nEMS',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 0.9,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),

              // Back Button - Properly Positioned
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    // Proper back navigation
                    Navigator.pop(context);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ),

              // Main Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo with Glow
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.primaryColor.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_reset,
                          size: 35,
                          color: AppConstants.primaryColor,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Enter your details to reset your password',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          shadows: [
                            const Shadow(
                              blurRadius: 8,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Reset Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return Column(
                              children: [
                                // Email Field
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  hint: 'example@nit.ac.tz',
                                  icon: Icons.email,
                                  isFocused: _isEmailFocused,
                                  onFocusChange: (focused) {
                                    setState(() {
                                      _isEmailFocused = focused;
                                    });
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Phone Field
                                _buildTextField(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  hint: '0712345678',
                                  icon: Icons.phone,
                                  isFocused: _isPhoneFocused,
                                  onFocusChange: (focused) {
                                    setState(() {
                                      _isPhoneFocused = focused;
                                    });
                                  },
                                  keyboardType: TextInputType.phone,
                                ),

                                const SizedBox(height: 16),

                                // New Password Field
                                _buildPasswordField(
                                  controller: _newPasswordController,
                                  label: 'New Password',
                                  icon: Icons.lock,
                                  isFocused: _isNewPasswordFocused,
                                  onFocusChange: (focused) {
                                    setState(() {
                                      _isNewPasswordFocused = focused;
                                    });
                                  },
                                  obscureText: _obscureNewPassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscureNewPassword = !_obscureNewPassword;
                                    });
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Confirm Password Field
                                _buildPasswordField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirm New Password',
                                  icon: Icons.lock_outline,
                                  isFocused: _isConfirmPasswordFocused,
                                  onFocusChange: (focused) {
                                    setState(() {
                                      _isConfirmPasswordFocused = focused;
                                    });
                                  },
                                  obscureText: _obscureConfirmPassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Reset Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : () async {
                                            String email = _emailController.text.trim();
                                            String phone = _phoneController.text.trim();
                                            String newPassword = _newPasswordController.text.trim();
                                            String confirmPassword =
                                                _confirmPasswordController.text.trim();

                                            if (email.isEmpty || phone.isEmpty ||
                                                newPassword.isEmpty || confirmPassword.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Please fill all fields'),
                                                  backgroundColor: AppConstants.errorColor,
                                                ),
                                              );
                                              return;
                                            }

                                            if (newPassword != confirmPassword) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Passwords do not match'),
                                                  backgroundColor: AppConstants.errorColor,
                                                ),
                                              );
                                              return;
                                            }

                                            if (newPassword.length < 6) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Password must be at least 6 characters',
                                                  ),
                                                  backgroundColor: AppConstants.errorColor,
                                                ),
                                              );
                                              return;
                                            }

                                            bool success = await authProvider.resetPassword(
                                              email,
                                              phone,
                                              newPassword,
                                            );

                                            if (success) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Password reset successfully!',
                                                  ),
                                                  backgroundColor: AppConstants.successColor,
                                                ),
                                              );
                                              Navigator.pop(context);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    authProvider.error ?? 'An error occurred',
                                                  ),
                                                  backgroundColor: AppConstants.errorColor,
                                                ),
                                              );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppConstants.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            'RESET PASSWORD',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Back to Login Link
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back,
                              size: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Back to Login',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  const Shadow(
                                    blurRadius: 5,
                                    color: Colors.black38,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Footer
                      Text(
                         'Scar Tech Team',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.6),
                          shadows: [
                            const Shadow(
                              blurRadius: 5,
                              color: Colors.black38,
                            ),
                          ],
                        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isFocused,
    required ValueChanged<bool> onFocusChange,
    TextInputType? keyboardType,
  }) {
    return FocusScope(
      child: Focus(
        onFocusChange: onFocusChange,
        child: TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14),
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontSize: 12,
              color: isFocused ? AppConstants.primaryColor : Colors.grey[600],
            ),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: isFocused ? AppConstants.primaryColor : Colors.grey[500],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppConstants.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isFocused ? Colors.grey[50] : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isFocused,
    required ValueChanged<bool> onFocusChange,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return FocusScope(
      child: Focus(
        onFocusChange: onFocusChange,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontSize: 12,
              color: isFocused ? AppConstants.primaryColor : Colors.grey[600],
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: isFocused ? AppConstants.primaryColor : Colors.grey[500],
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: Colors.grey[600],
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppConstants.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isFocused ? Colors.grey[50] : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}