import 'package:flutter/material.dart';

/// Uygulamanın tüm renk ve bileşen stillerinin tek kaynağı.
/// Palet: derin indigo-mor ana renk, şampanya altını vurgu rengi,
/// açıkta ılık lavanta-beyazı, koyuda gece laciverti yüzeyler.
class AppTheme {
  const AppTheme._();

  static const _indigo = Color(0xFF4C3FD0);
  static const _gold = Color(0xFFB8892B);

  static ThemeData get light => _build(
    ColorScheme.fromSeed(seedColor: _indigo).copyWith(
      primary: const Color(0xFF4C3FD0),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE4E0FF),
      onPrimaryContainer: const Color(0xFF1B1170),
      secondaryContainer: const Color(0xFFEAE7F8),
      onSecondaryContainer: const Color(0xFF2A2557),
      tertiary: _gold,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFBE9C0),
      onTertiaryContainer: const Color(0xFF4A3300),
      surface: const Color(0xFFF6F5FB),
      onSurface: const Color(0xFF16152B),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFFAF9FE),
      surfaceContainer: const Color(0xFFF1EFF9),
      surfaceContainerHigh: const Color(0xFFECEAF6),
      surfaceContainerHighest: const Color(0xFFE6E3F3),
      outline: const Color(0xFF7A7794),
      outlineVariant: const Color(0xFFDCD9EC),
      error: const Color(0xFFD64560),
    ),
  );

  static ThemeData get dark => _build(
    ColorScheme.fromSeed(
      seedColor: _indigo,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFA99CFF),
      onPrimary: const Color(0xFF1D1070),
      primaryContainer: const Color(0xFF3A2FA8),
      onPrimaryContainer: const Color(0xFFE4E0FF),
      secondaryContainer: const Color(0xFF2B2A52),
      onSecondaryContainer: const Color(0xFFE2DFFA),
      tertiary: const Color(0xFFE8C16A),
      onTertiary: const Color(0xFF3B2A00),
      tertiaryContainer: const Color(0xFF5A4310),
      onTertiaryContainer: const Color(0xFFFBE9C0),
      surface: const Color(0xFF0E0F1C),
      onSurface: const Color(0xFFEAE9F5),
      surfaceContainerLowest: const Color(0xFF0A0B16),
      surfaceContainerLow: const Color(0xFF14152A),
      surfaceContainer: const Color(0xFF191A31),
      surfaceContainerHigh: const Color(0xFF20213B),
      surfaceContainerHighest: const Color(0xFF272947),
      outline: const Color(0xFF8D8BAE),
      outlineVariant: const Color(0xFF34365A),
      error: const Color(0xFFFF7C92),
    ),
  );

  /// Logo rozetleri ve vurgu alanları için ana renk geçişi.
  static LinearGradient brandGradient(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [Color(0xFF8F7DFF), Color(0xFF5C4BDE)]
          : const [Color(0xFF7B6CF6), Color(0xFF4C3FD0)],
    );
  }

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final isDark = scheme.brightness == Brightness.dark;
    final fieldFill = isDark
        ? scheme.surfaceContainerHigh
        : scheme.surfaceContainerLowest;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: border(scheme.outlineVariant),
        enabledBorder: border(scheme.outlineVariant),
        focusedBorder: border(scheme.primary, 1.8),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 1.8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.outline,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.outline,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? scheme.surfaceContainerHighest
            : const Color(0xFF241F4D),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
