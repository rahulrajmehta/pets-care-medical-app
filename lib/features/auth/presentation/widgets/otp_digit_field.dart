import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// 6-digit OTP Input field supporting auto-focus, backspace jumping, and paste
class OtpDigitField extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool hasError;
  final bool enabled;

  const OtpDigitField({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
    this.hasError = false,
    this.enabled = true,
  });

  @override
  State<OtpDigitField> createState() => OtpDigitFieldState();
}

class OtpDigitFieldState extends State<OtpDigitField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty && mounted) {
      _focusNodes.first.requestFocus();
    }
    widget.onChanged('');
  }

  String _getOtp() {
    return _controllers.map((c) => c.text).join();
  }

  void _handleChanged(int index, String value) {
    // Check if user pasted multiple characters
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) {
        _handlePaste(digits);
        return;
      }
    }

    if (value.isNotEmpty) {
      _controllers[index].text = value.substring(value.length - 1);
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    final otp = _getOtp();
    widget.onChanged(otp);

    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }
  }

  void _handlePaste(String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    final count = digits.length.clamp(0, widget.length);

    for (int i = 0; i < widget.length; i++) {
      if (i < count) {
        _controllers[i].text = digits[i];
      } else {
        _controllers[i].clear();
      }
    }

    if (count < widget.length) {
      _focusNodes[count].requestFocus();
    } else {
      _focusNodes.last.unfocus();
    }

    final fullOtp = _getOtp();
    widget.onChanged(fullOtp);

    if (fullOtp.length == widget.length) {
      widget.onCompleted?.call(fullOtp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = ((constraints.maxWidth - (widget.length - 1) * 10) /
                widget.length)
            .clamp(42.0, 54.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (index) {
            return SizedBox(
              width: boxWidth,
              height: 58,
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.backspace): () {
                    if (_controllers[index].text.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                      _controllers[index - 1].clear();
                      widget.onChanged(_getOtp());
                    }
                  },
                },
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  enabled: widget.enabled,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: widget.hasError
                        ? AppColors.error
                        : AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    fillColor: _focusNodes[index].hasFocus
                        ? AppColors.lightSage.withValues(alpha: 0.4)
                        : AppColors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.hasError
                            ? AppColors.error
                            : AppColors.border,
                        width: 1.4,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.hasError
                            ? AppColors.error
                            : AppColors.primaryGreen,
                        width: 2.2,
                      ),
                    ),
                  ),
                  onChanged: (val) => _handleChanged(index, val),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
