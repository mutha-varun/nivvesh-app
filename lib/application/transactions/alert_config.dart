import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences keys — also read by the background SMS handler.
const kSpendAlertThresholds = 'spend_alert_thresholds';
const kUserSalary = 'user_salary';

final alertConfigProvider =
    ChangeNotifierProvider<AlertConfigController>((ref) {
  return AlertConfigController()..load();
});

class AlertConfigController extends ChangeNotifier {
  List<int> _thresholds = [];
  double _salary = 0;
  bool _loaded = false;

  List<int> get thresholds => List.unmodifiable(_thresholds);
  double get salary => _salary;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _salary = prefs.getDouble(kUserSalary) ?? 0;

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

  Future<void> setSalary(double value) async {
    if (value < 0) return;
    _salary = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(kUserSalary, value);
    notifyListeners();
  }

  Future<void> _saveThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kSpendAlertThresholds, _thresholds.join(','));
  }
}
