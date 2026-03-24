// // lib/src/presentation/shared/themes/theme.dart

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:nivvesh/mobile/presentation/shared/themes/colors.dart';

// class AppTheme {
//   /// Light theme configuration (inverse of dark)
//   static ThemeData get lightTheme {
//     final baseTextTheme = GoogleFonts.interTextTheme();
//     final colors = AppColors.light;

//     return ThemeData(
//       brightness: Brightness.light,
//       primaryColor: colors.accent,
//       scaffoldBackgroundColor: colors.background,
      
//       colorScheme: ColorScheme.light(
//         primary: colors.accent,
//         onPrimary: colors.accentText,
//         secondary: colors.accent,
//         onSecondary: colors.accentText,
//         surface: colors.surface,
//         onSurface: colors.primaryText,
//         error: colors.error,
//         onError: Colors.white,
//         outline: colors.border,
//       ),

//       textTheme: baseTextTheme.copyWith(
//         displaySmall: baseTextTheme.displaySmall?.copyWith(
//           fontWeight: FontWeight.bold,
//           color: colors.primaryText,
//         ),
//         headlineMedium: baseTextTheme.headlineMedium?.copyWith(
//           fontSize: 21.0,
//           fontWeight: FontWeight.w600,
//           color: colors.primaryText,
//           letterSpacing: -0.5,
//         ),
//         titleLarge: baseTextTheme.titleLarge?.copyWith(
//           fontWeight: FontWeight.w500,
//           color: colors.primaryText,
//         ),
//         bodyLarge: baseTextTheme.bodyLarge?.copyWith(
//           color: colors.primaryText,
//         ),
//         bodyMedium: baseTextTheme.bodyMedium?.copyWith(
//           color: colors.secondaryText,
//           height: 1.5,
//         ),
//         labelLarge: baseTextTheme.labelLarge?.copyWith(
//           fontWeight: FontWeight.w600,
//           fontSize: 13.0,
//         ),
//         labelMedium: baseTextTheme.labelMedium?.copyWith(
//           color: colors.secondaryText,
//           fontSize: 12.0,
//         ),
//       ),

//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.transparent,
//         foregroundColor: Color(0xFF1A1A1A),
//         elevation: 0,
//       ),

//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: colors.accent,
//           foregroundColor: colors.accentText,
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//           textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
//           elevation: 2,
//           shadowColor: Colors.black.withOpacity(0.1),
//         ),
//       ),

//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: colors.primaryText,
//           side: BorderSide(color: colors.border),
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//           textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
//         ),
//       ),

//       dividerTheme: DividerThemeData(
//         color: colors.border,
//         thickness: 1,
//       ),

//       chipTheme: ChipThemeData(
//         backgroundColor: colors.surface,
//         side: BorderSide.none,
//         labelStyle: GoogleFonts.inter(
//           color: colors.primaryText,
//           fontSize: 13,
//           fontWeight: FontWeight.w500,
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
//         iconTheme: IconThemeData(
//           color: colors.primaryText,
//           size: 16,
//         ),
//       ),

//       tabBarTheme: TabBarThemeData(
//         labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
//         unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
//         labelColor: colors.primaryText,
//         unselectedLabelColor: colors.secondaryText,
//         indicator: BoxDecoration(
//           color: colors.accent.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         indicatorSize: TabBarIndicatorSize.tab,
//       ),
//     );
//   }

//   /// Dark theme configuration
//   static ThemeData get darkTheme {
//     final baseTextTheme = GoogleFonts.interTextTheme();
//     final colors = AppColors.dark;

//     return ThemeData(
//       brightness: Brightness.dark,
//       primaryColor: colors.accent,
//       scaffoldBackgroundColor: colors.background,
      
//       colorScheme: ColorScheme.dark(
//         primary: colors.accent,
//         onPrimary: colors.accentText,
//         secondary: colors.accent,
//         onSecondary: colors.accentText,
//         surface: colors.surface,
//         onSurface: colors.primaryText,
//         error: colors.error,
//         onError: const Color(0xFF070707),
//         outline: colors.border,
//       ),

//       textTheme: baseTextTheme.copyWith(
//         displaySmall: baseTextTheme.displaySmall?.copyWith(
//           fontWeight: FontWeight.bold,
//           color: colors.primaryText,
//         ),
//         headlineMedium: baseTextTheme.headlineMedium?.copyWith(
//           fontSize: 21.0,
//           fontWeight: FontWeight.w600,
//           color: colors.primaryText,
//           letterSpacing: -0.5,
//         ),
//         titleLarge: baseTextTheme.titleLarge?.copyWith(
//           fontWeight: FontWeight.w500,
//           color: colors.primaryText,
//         ),
//         bodyLarge: baseTextTheme.bodyLarge?.copyWith(
//           color: colors.primaryText,
//         ),
//         bodyMedium: baseTextTheme.bodyMedium?.copyWith(
//           color: colors.secondaryText,
//           height: 1.5,
//         ),
//         labelLarge: baseTextTheme.labelLarge?.copyWith(
//           fontWeight: FontWeight.w600,
//           fontSize: 13.0,
//         ),
//         labelMedium: baseTextTheme.labelMedium?.copyWith(
//           color: colors.secondaryText,
//           fontSize: 12.0,
//         ),
//       ),

//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.transparent,
//         foregroundColor: Color(0xFFEAEAEA),
//         elevation: 0,
//       ),

//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: colors.accent,
//           foregroundColor: colors.accentText,
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//           textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
//           elevation: 4,
//           shadowColor: Colors.black.withOpacity(0.3),
//         ),
//       ),

//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: colors.primaryText,
//           side: BorderSide(color: colors.border),
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//           textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
//         ),
//       ),

//       dividerTheme: DividerThemeData(
//         color: colors.border,
//         thickness: 1,
//       ),

//       chipTheme: ChipThemeData(
//         backgroundColor: colors.surface,
//         side: BorderSide.none,
//         labelStyle: GoogleFonts.inter(
//           color: colors.primaryText,
//           fontSize: 13,
//           fontWeight: FontWeight.w500,
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
//         iconTheme: IconThemeData(
//           color: colors.primaryText,
//           size: 16,
//         ),
//       ),

//       tabBarTheme: TabBarThemeData(
//         labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
//         unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
//         labelColor: colors.primaryText,
//         unselectedLabelColor: colors.secondaryText,
//         indicator: BoxDecoration(
//           color: Colors.white.withOpacity(0.12),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         indicatorSize: TabBarIndicatorSize.tab,
//       ),
//     );
//   }
// }