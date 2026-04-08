import 'package:flutter/material.dart';

class CategorySwatch {
  final Color base;
  final Color tint10;
  final Color tint20;

  const CategorySwatch(this.base, this.tint10, this.tint20);
}

class CategoryPalette {
  final CategorySwatch blue;
  final CategorySwatch rose;
  final CategorySwatch purple;
  final CategorySwatch orange;
  final CategorySwatch indigo;
  final CategorySwatch pink;
  final CategorySwatch amber;
  final CategorySwatch emerald;

  const CategoryPalette({
    required this.blue,
    required this.rose,
    required this.purple,
    required this.orange,
    required this.indigo,
    required this.pink,
    required this.amber,
    required this.emerald,
  });

  CategorySwatch forCategory(String category) {
    final value = category.toLowerCase();

    if (value.contains('food')) return orange;
    if (value.contains('shopping')) return pink;
    if (value.contains('transport')) return blue;
    if (value.contains('entertainment')) return purple;
    if (value.contains('bill')) return amber;
    if (value.contains('health')) return rose;
    if (value.contains('investment')) return emerald;

    return indigo;
  }
}
