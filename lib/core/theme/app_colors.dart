import 'package:flutter/material.dart';
import 'package:nivvesh/core/theme/app_category_colors.dart';

abstract class AppColorsBase {
  Color get background;
  Color get surface;
  Color get surfaceContainerLow;
  Color get surfaceContainerHigh;
  Color get cardSurface;       
  Color get dropdownSurface;   
  Color get primaryText;
  Color get secondaryText;
  Color get muted;           

  Color get outlineVariant;
  Color get border;

  Color get gold;
  Color get goldSoft;          

  // Accent for revamped home/nav UI.
  Color get accentPrimary;
  Color get accentPrimarySoft;
  Color get accentTint10;
  Color get accentTint20;

  // Neutral overlays for glass/tinted surfaces.
  Color get surfaceTintLow;
  Color get surfaceTintMid;
  Color get surfaceTintHigh;
  Color get borderSubtle;

  // Semantic money direction for revamped balance card.
  Color get incomePositive;
  Color get expenseNegative;

  Color get accent;
  Color get accentContainer;
  Color get onAccentContainer;
  Color get accentText;        

  // Debit / negative
  Color get debit;
  Color get debitContainer;
  Color get onDebitContainer;

  // Credit / positive
  Color get credit;

  // Secondary
  Color get secondary;
  Color get onSecondary;

  CategoryPalette get categories;

  Color get error;
}

class DarkAppColors extends AppColorsBase {
  @override Color get background         => const Color(0xFF000000);
  @override Color get surface            => const Color(0xFF1C1B1F);
  @override Color get surfaceContainerLow  => const Color(0xFF211F26);
  @override Color get surfaceContainerHigh => const Color(0xFF2B2930);
  @override Color get cardSurface        => const Color(0xFF0A0A0A);
  @override Color get dropdownSurface    => const Color(0xFF141414);

  @override Color get primaryText        => const Color(0xFFE6E1E5);
  @override Color get secondaryText      => const Color(0xFF938F99);
  @override Color get muted              => const Color(0xFF8E8E93);

  @override Color get outlineVariant     => const Color(0xFF49454F);
  @override Color get border             => const Color(0x1AFFFFFF);

  @override Color get gold               => const Color(0xFFD4AF37);
  @override Color get goldSoft           => const Color(0xFFF1D592);

  @override Color get accentPrimary      => const Color(0xFF34D399);
  @override Color get accentPrimarySoft  => const Color(0xFF10B981);
  @override Color get accentTint10       => const Color(0x1A34D399);
  @override Color get accentTint20       => const Color(0x3334D399);

  @override Color get surfaceTintLow     => const Color(0x4D1F2937);
  @override Color get surfaceTintMid     => const Color(0x661F2937);
  @override Color get surfaceTintHigh    => const Color(0x801F2937);
  @override Color get borderSubtle       => const Color(0x80374151);

  @override Color get incomePositive     => const Color(0xFF34D399);
  @override Color get expenseNegative    => const Color(0xFFFB7185);

  @override Color get accent             => const Color(0xFFD0BCFF);
  @override Color get accentContainer    => const Color(0xFF4F378B);
  @override Color get onAccentContainer  => const Color(0xFFEADDFF);
  @override Color get accentText         => const Color(0xFF1C1B1F);

  @override Color get debit              => const Color(0xFFFFB4AB);
  @override Color get debitContainer     => const Color(0xFF93000A);
  @override Color get onDebitContainer   => const Color(0xFFFFDAD6);

  @override Color get credit             => const Color(0xFF4CAF50);

  @override Color get secondary          => const Color(0xFF4A4458);
  @override Color get onSecondary        => const Color(0xFFCCC2DC);

  @override
  CategoryPalette get categories => const CategoryPalette(
        blue: CategorySwatch(
          Color(0xFF3B82F6),
          Color(0x1A3B82F6),
          Color(0x333B82F6),
        ),
        rose: CategorySwatch(
          Color(0xFFF43F5E),
          Color(0x1AF43F5E),
          Color(0x33F43F5E),
        ),
        purple: CategorySwatch(
          Color(0xFFA855F7),
          Color(0x1AA855F7),
          Color(0x33A855F7),
        ),
        orange: CategorySwatch(
          Color(0xFFF97316),
          Color(0x1AF97316),
          Color(0x33F97316),
        ),
        indigo: CategorySwatch(
          Color(0xFF6366F1),
          Color(0x1A6366F1),
          Color(0x336366F1),
        ),
        pink: CategorySwatch(
          Color(0xFFEC4899),
          Color(0x1AEC4899),
          Color(0x33EC4899),
        ),
        amber: CategorySwatch(
          Color(0xFFF59E0B),
          Color(0x1AF59E0B),
          Color(0x33F59E0B),
        ),
        emerald: CategorySwatch(
          Color(0xFF34D399),
          Color(0x1A34D399),
          Color(0x3334D399),
        ),
      );

  @override Color get error              => const Color(0xFFFFB4AB);
}

class LightAppColors extends AppColorsBase {
  @override Color get background         => const Color(0xFFFFFBFE);
  @override Color get surface            => const Color(0xFFFFFBFE);
  @override Color get surfaceContainerLow  => const Color(0xFFF7F2FA);
  @override Color get surfaceContainerHigh => const Color(0xFFECE6F0);
  @override Color get cardSurface        => const Color(0xFFF7F2FA);
  @override Color get dropdownSurface    => const Color(0xFFECE6F0);

  @override Color get primaryText        => const Color(0xFF1C1B1F);
  @override Color get secondaryText      => const Color(0xFF49454F);
  @override Color get muted              => const Color(0xFF79747E);

  @override Color get outlineVariant     => const Color(0xFFCAC4D0);
  @override Color get border             => const Color(0xFFE5E0EC);

  @override Color get gold               => const Color(0xFF6750A4);  // primary purple in light
  @override Color get goldSoft           => const Color(0xFFEADDFF);  // soft purple tint

  @override Color get accentPrimary      => const Color(0xFF10B981);
  @override Color get accentPrimarySoft  => const Color(0xFF34D399);
  @override Color get accentTint10       => const Color(0x1A10B981);
  @override Color get accentTint20       => const Color(0x3310B981);

  @override Color get surfaceTintLow     => const Color(0x0D1F2937);
  @override Color get surfaceTintMid     => const Color(0x141F2937);
  @override Color get surfaceTintHigh    => const Color(0x1F1F2937);
  @override Color get borderSubtle       => const Color(0x33475569);

  @override Color get incomePositive     => const Color(0xFF059669);
  @override Color get expenseNegative    => const Color(0xFFE11D48);

  @override Color get accent             => const Color(0xFF6750A4);
  @override Color get accentContainer    => const Color(0xFFEADDFF);
  @override Color get onAccentContainer  => const Color(0xFF21005D);
  @override Color get accentText         => const Color(0xFFFFFFFF);

  @override Color get debit              => const Color(0xFFB3261E);
  @override Color get debitContainer     => const Color(0xFFF9DEDC);
  @override Color get onDebitContainer   => const Color(0xFF410E0B);

  @override Color get credit             => const Color(0xFF1B6B3A);

  @override Color get secondary          => const Color(0xFFE8DEF8);
  @override Color get onSecondary        => const Color(0xFF1D192B);

  @override
  CategoryPalette get categories => const CategoryPalette(
        blue: CategorySwatch(
          Color(0xFF2563EB),
          Color(0x1A2563EB),
          Color(0x332563EB),
        ),
        rose: CategorySwatch(
          Color(0xFFE11D48),
          Color(0x1AE11D48),
          Color(0x33E11D48),
        ),
        purple: CategorySwatch(
          Color(0xFF9333EA),
          Color(0x1A9333EA),
          Color(0x339333EA),
        ),
        orange: CategorySwatch(
          Color(0xFFEA580C),
          Color(0x1AEA580C),
          Color(0x33EA580C),
        ),
        indigo: CategorySwatch(
          Color(0xFF4F46E5),
          Color(0x1A4F46E5),
          Color(0x334F46E5),
        ),
        pink: CategorySwatch(
          Color(0xFFDB2777),
          Color(0x1ADB2777),
          Color(0x33DB2777),
        ),
        amber: CategorySwatch(
          Color(0xFFD97706),
          Color(0x1AD97706),
          Color(0x33D97706),
        ),
        emerald: CategorySwatch(
          Color(0xFF10B981),
          Color(0x1A10B981),
          Color(0x3310B981),
        ),
      );

  @override Color get error              => const Color(0xFFB3261E);
}

class AppColors {
  AppColors._();

  static AppColorsBase of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }

  static final dark  = DarkAppColors();
  static final light = LightAppColors();
}
