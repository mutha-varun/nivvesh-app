import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences keys — also read by the background SMS handler.
const kSpendAlertThresholds = 'spend_alert_thresholds';
const kMonthlyIncome = 'bg_monthly_income';
const _kCategoryLimitPrefix = 'category_limit_';

final alertConfigProvider =
    ChangeNotifierProvider<AlertConfigController>((ref) {
  return AlertConfigController()..load();
});

class AlertConfigController extends ChangeNotifier {
  List<int> _thresholds = [];
  double _monthlyIncome = 0;
  bool _loaded = false;
  final Map<String, double> _categoryLimits = {};

  List<int> get thresholds => List.unmodifiable(_thresholds);

  /// Monthly income derived from credit transactions tracked by the SMS handler.
  double get monthlyIncome => _monthlyIncome;

  bool get loaded => _loaded;
  Map<String, double> get categoryLimits => Map.unmodifiable(_categoryLimits);

  double getCategoryLimit(String category) =>
      _categoryLimits[category] ?? 0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _monthlyIncome = prefs.getDouble(kMonthlyIncome) ?? 0;

    final raw = prefs.getString(kSpendAlertThresholds);
    if (raw != null && raw.isNotEmpty) {
      _thresholds = raw
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .toList()
        ..sort();
    } else {
      // Sensible defaults matching the old hardcoded behaviour
      _thresholds = [50, 80];
      await _saveThresholds();
    }

    // Load per-category limits
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_kCategoryLimitPrefix)) {
        final category = key.substring(_kCategoryLimitPrefix.length);
        _categoryLimits[category] = prefs.getDouble(key) ?? 0;
      }
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> addThreshold(int percent) async {
    if (percent <= 0 || percent > 100) return;
    if (_thresholds.contains(percent)) return;
    _thresholds.add(percent);
    _thresholds.sort();
    await _saveThresholds();
    notifyListeners();
  }

  Future<void> removeThreshold(int percent) async {
    if (!_thresholds.remove(percent)) return;
    await _saveThresholds();
    // Also clean up the alerted flag so it doesn't linger
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bg_alerted_$percent');
    notifyListeners();
  }

  Future<void> setCategoryLimit(String category, double amount) async {
    if (amount < 0) return;
    _categoryLimits[category] = amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_kCategoryLimitPrefix$category', amount);
    notifyListeners();
  }

  Future<void> _saveThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kSpendAlertThresholds, _thresholds.join(','));
  }
}
