import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/colors.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.title,
    this.hintText,
    this.height,
    this.maxLines,
    this.keyboardType,
    this.controller,
    this.textAlign,
    this.inputFormatters,
    this.obscureText,
    this.prefixText,
    this.focusNode,
    this.onSubmitted,
    this.onChanged,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autoFocus = false,
    this.errorText,
    this.isRequired = false,
  });

  AppTextField.number({
    super.key,
    this.title,
    this.hintText,
    this.height,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onChanged,
    this.textInputAction,
    List<TextInputFormatter>? inputFormatters,
    this.autoFocus = false,
    this.errorText,
    this.isRequired = false,
  })  : maxLines = 1,
        keyboardType = TextInputType.number,
        textAlign = TextAlign.center,
        inputFormatters =
            inputFormatters ?? [FilteringTextInputFormatter.digitsOnly],
        obscureText = false,
        prefixText = null,
        textCapitalization = TextCapitalization.none;

  AppTextField.phone({
    super.key,
    this.title,
    this.hintText,
    this.height,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onChanged,
    this.textInputAction,
    this.autoFocus = false,
    this.errorText,
    this.isRequired = false,
  })  : maxLines = 1,
        keyboardType = TextInputType.phone,
        textAlign = TextAlign.start,
        inputFormatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
          _UzbekistanPhoneFormatter(),
        ],
        obscureText = false,
        prefixText = '+998 ',
        textCapitalization = TextCapitalization.none;

  const AppTextField.password({
    super.key,
    this.title,
    this.hintText,
    this.height,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onChanged,
    this.textInputAction,
    this.autoFocus = false,
    this.errorText,
    this.isRequired = false,
  })  : maxLines = 1,
        keyboardType = TextInputType.visiblePassword,
        textAlign = TextAlign.start,
        inputFormatters = null,
        obscureText = true,
        prefixText = null,
        textCapitalization = TextCapitalization.none;

  final String? title;
  final String? hintText;
  final double? height;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final TextAlign? textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obscureText;
  final String? prefixText;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autoFocus;
  final String? errorText;
  final bool isRequired;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText ?? false;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
    Theme.of(context).extension<ApparenceKitColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title!,
                style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 14,
                  fontFamily: 'SF Pro Rounded',
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                  letterSpacing: -0.28,
                ),
              ),
              if (widget.isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: colors.error,
                    fontSize: 14,
                    fontFamily: 'SF Pro Rounded',
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        TextField(
          autofocus: widget.autoFocus,
          onChanged: widget.onChanged,
          textCapitalization: widget.textCapitalization,
          controller: widget.controller,
          focusNode: widget.focusNode,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          textAlign: widget.textAlign ?? TextAlign.start,
          inputFormatters: widget.inputFormatters,
          obscureText: _isObscured,
          textInputAction: widget.textInputAction ??
              (widget.maxLines == 1
                  ? TextInputAction.next
                  : TextInputAction.newline),
          onSubmitted: widget.onSubmitted,
          scrollController:
          widget.maxLines == 1 ? _scrollController : null,
          scrollPhysics: widget.maxLines == 1
              ? const ClampingScrollPhysics()
              : null,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 14,
            fontFamily: 'SF Pro Rounded',
            fontWeight: FontWeight.w400,
            height: 1.25,
            letterSpacing: -0.28,
          ),
          cursorColor: colors.primary,
          decoration: InputDecoration(
            constraints: BoxConstraints(
              minHeight: widget.height ?? 50,
            ),
            filled: true,
            fillColor: colors.surface,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: colors.disabledContent,
              fontSize: 15,
              fontFamily: 'SF Pro Rounded',
            ),
            errorText: widget.errorText,
            errorMaxLines: 2,
            errorStyle: TextStyle(
              color: colors.error,
              fontSize: 12,
              fontFamily: 'SF Pro Rounded',
              fontWeight: FontWeight.w400,
              height: 1.25,
              letterSpacing: -0.24,
            ),

            // PREFIX
            prefixIconConstraints:
            BoxConstraints.loose(const Size(60, 40)),
            prefixIcon: widget.prefixText != null
                ? Center(
              child: Text(
                widget.prefixText!,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 14,
                  fontFamily: 'SF Pro Rounded',
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                  letterSpacing: -0.28,
                ),
              ),
            )
                : null,

            // PASSWORD TOGGLE
            suffixIcon: widget.obscureText == true
                ? IconButton(
              icon: Icon(
                _isObscured
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: colors.primary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
            )
                : null,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),

            // BORDERS
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: widget.errorText != null
                  ? BorderSide(
                color: colors.error,
                width: 1,
              )
                  : BorderSide(
                color: colors.divider,
                width: 1,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: widget.errorText != null
                  ? BorderSide(
                color: colors.error,
                width: 1.5,
              )
                  : BorderSide(
                color: colors.primary,
                width: 1.5,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colors.error,
                width: 1,
              ),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: colors.error,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UzbekistanPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 5 || i == 7) {
        buffer.write(' ');
      }

      buffer.write(text[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}