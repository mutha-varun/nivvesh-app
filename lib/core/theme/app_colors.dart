import 'package:flutter/material.dart';

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
