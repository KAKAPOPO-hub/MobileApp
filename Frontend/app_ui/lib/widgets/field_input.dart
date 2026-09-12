import 'package:flutter/material.dart';

class FieldInput extends StatelessWidget {
  const FieldInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.fillColor = const Color(0xFFF5F6FA),
    this.borderRadius = 14,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Color fillColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final primary = Theme.of(context).colorScheme.primary;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}

class FieldPasswordInput extends StatefulWidget {
  const FieldPasswordInput({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  @override
  State<FieldPasswordInput> createState() => _FieldPasswordInputState();
}

class _FieldPasswordInputState extends State<FieldPasswordInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return FieldInput(
      controller: widget.controller,
      label: widget.label,
      icon: Icons.lock_outline_rounded,
      obscureText: _obscure,
      validator: widget.validator,
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
