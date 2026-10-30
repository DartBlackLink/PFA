import 'package:flutter/material.dart';

/// EcoLogística: superficies neutras; pizarra en oscuro y verde en claro.
abstract final class AppTheme {
  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: dark ? const Color(0xFF7288A5) : const Color(0xFF276B59),
          brightness: brightness,
        ).copyWith(
          primary: dark ? const Color(0xFFB8CBE5) : const Color(0xFF256B55),
          onPrimary: dark ? const Color(0xFF1D3048) : Colors.white,
          primaryContainer: dark
              ? const Color(0xFF334359)
              : const Color(0xFFE5F2EB),
          onPrimaryContainer: dark
              ? const Color(0xFFE0E9F5)
              : const Color(0xFF1A503B),
          secondary: dark ? const Color(0xFFE7BA7B) : const Color(0xFF885719),
          onSecondary: dark ? const Color(0xFF3C2B12) : Colors.white,
          secondaryContainer: dark
              ? const Color(0xFF493A27)
              : const Color(0xFFFAECD6),
          onSecondaryContainer: dark
              ? const Color(0xFFF6D9AC)
              : const Color(0xFF69440F),
          surface: dark ? const Color(0xFF202A37) : const Color(0xFFFFFFFF),
          onSurface: dark ? const Color(0xFFF0F3F8) : const Color(0xFF202C3C),
          onSurfaceVariant: dark
              ? const Color(0xFFC5CFDD)
              : const Color(0xFF556377),
          surfaceContainerLowest: dark
              ? const Color(0xFF121923)
              : const Color(0xFFF4F6F9),
          surfaceContainerLow: dark
              ? const Color(0xFF1B2431)
              : const Color(0xFFF9FAFC),
          surfaceContainer: dark
              ? const Color(0xFF243040)
              : const Color(0xFFF0F3F7),
          surfaceContainerHigh: dark
              ? const Color(0xFF273446)
              : const Color(0xFFEAF0F5),
          surfaceContainerHighest: dark
              ? const Color(0xFF2C394B)
              : const Color(0xFFEAF0F6),
          outline: dark ? const Color(0xFF91A0B5) : const Color(0xFF7D899B),
          outlineVariant: dark
              ? const Color(0xFF3D4B60)
              : const Color(0xFFDCE3EC),
          error: dark ? const Color(0xFFFFB4AB) : const Color(0xFFB3261E),
          errorContainer: dark
              ? const Color(0xFF5B2725)
              : const Color(0xFFFCE5E1),
          onErrorContainer: dark
              ? const Color(0xFFFFDAD4)
              : const Color(0xFF7D211B),
        );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: 'Roboto',
    );
    final text = base.textTheme
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface)
        .copyWith(
          headlineLarge: TextStyle(
            fontSize: 34,
            height: 1.16,
            letterSpacing: -1.0,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
          headlineMedium: TextStyle(
            fontSize: 30,
            height: 1.2,
            letterSpacing: -.8,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
          headlineSmall: TextStyle(
            fontSize: 26,
            height: 1.25,
            letterSpacing: -.6,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
          titleLarge: TextStyle(
            fontSize: 21,
            height: 1.3,
            letterSpacing: -.35,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: scheme.onSurface,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: scheme.onSurface,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: .1,
            color: scheme.onSurface,
          ),
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: scheme.outlineVariant),
    );
    final control = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleMedium,
        toolbarHeight: 72,
        shape: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: shape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: shape,
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium!.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        helperStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 12,
          height: 1.5,
        ),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorMaxLines: 3,
        helperMaxLines: 3,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: control,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: control,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: control,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: control,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: control,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: shape,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: scheme.onSurface),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainerLow),
        headingTextStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        dataTextStyle: TextStyle(color: scheme.onSurface, fontSize: 14),
        dataRowColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.hovered)
              ? scheme.surfaceContainerLow
              : null,
        ),
        headingRowHeight: 54,
        dataRowMinHeight: 76,
        dataRowMaxHeight: 92,
        horizontalMargin: 24,
        dividerThickness: .5,
      ),
      listTileTheme: ListTileThemeData(
        textColor: scheme.onSurface,
        iconColor: scheme.primary,
        subtitleTextStyle: text.bodyMedium!.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
