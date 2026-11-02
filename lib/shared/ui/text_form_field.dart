import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.inputFormatters,
    this.autofillHints,
    this.focusColor,
    this.fillColor,
    this.filled = true,
    this.borderRadius = 2,
    this.borderWidth = 0.8,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.onTapOutside,
    this.clean,
    this.autovalidateMode,
    this.expands = false,
    this.isDense,
    this.isCollapsed,
    this.cursorColor,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool expands;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool? clean;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<PointerDownEvent>? onTapOutside;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onFieldSubmitted;
  final GestureTapCallback? onTap;
  final VoidCallback? onEditingComplete;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final Color? focusColor;
  final Color? fillColor;
  final Color? cursorColor;
  final bool filled;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool? isDense;
  final bool? isCollapsed;
  final TextStyle? labelStyle;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // When filled is true, prioritize the background fill over a heavy OutlineInputBorder
    final bool useCleanBorder = (clean == true) || filled;

    final baseBorderSide = useCleanBorder
        ? BorderSide.none
        : BorderSide(
            color: colors.onSurface.withValues(alpha: 0.2),
            width: borderWidth,
          );

    final border = filled == true
        ? UnderlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          )
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: baseBorderSide,
          );

    // If filled, keep focused border minimal (e.g., primary color stroke) or none
    final focusedBorder = clean == true
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          )
        : filled
        ? UnderlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(),
          )
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: focusColor ?? colors.primary,
              width: 1.5,
            ),
          );

    final errorBorder = clean == true
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          )
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: colors.error, width: borderWidth),
          );

    final focusedErrorBorder = clean == true
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          )
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: colors.error, width: 1.2),
          );

    final disabledBorder = clean == true
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          )
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: colors.onSurface.withValues(alpha: 0.05),
              width: borderWidth,
            ),
          );

    final resolvedContentPadding =
        contentPadding ?? EdgeInsets.symmetric(horizontal: 12, vertical: 5);

    return TextFormField(
      expands: expands,
      autovalidateMode: autovalidateMode,
      controller: controller,
      focusNode: focusNode,
      initialValue: initialValue,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
      onTapOutside:
          onTapOutside ??
          (event) => FocusManager.instance.primaryFocus?.unfocus(),
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      cursorColor: cursorColor ?? colors.primary,
      style: textStyle ?? theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            hintStyle ??
            TextStyle(
              color: colors.onSurface.withValues(alpha: 1),
              fontWeight: .w400,
              fontSize: 14,
            ),
        helperText: helperText,
        errorText: errorText,
        prefix: prefix,
        suffix: suffix,
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        isCollapsed: isCollapsed ?? false,
        isDense: isDense ?? false,
        filled: filled,
        fillColor: fillColor ?? colors.onSurface.withValues(alpha: 0.08),
        contentPadding: resolvedContentPadding,
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: focusedErrorBorder,
        disabledBorder: disabledBorder,
      ),
    );
  }
}
