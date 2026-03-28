// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nivvesh/mobile/domain/models/filter_model.dart';
// import 'package:nivvesh/mobile/domain/models/finance_model.dart';
// import 'package:nivvesh/mobile/presentation/spend/filter_provider.dart';
// import 'package:nivvesh/mobile/presentation/spend/spend_provider.dart';

// final filteredFinanceProvider = Provider((ref) {
//   final allMessages = ref.watch(financeControllerProvider).messages;
//   final filter = ref.watch(filterProvider); // Assume you have this provider

//   // 1. Filter by Date (e.g., only March 2026)
//   var filtered = allMessages.where((m) {
//     if (filter.selectedDate == null) return true;
//     return m.date.month == filter.selectedDate!.month && 
//            m.date.year == filter.selectedDate!.year;
//   }).toList();

//   // 2. Filter by Category if specific ones are selected
//   if (filter.selectedCategories.isNotEmpty) {
//     filtered = filtered.where((m) => filter.selectedCategories.contains(m.category)).toList();
//   }

//   // 3. Grouping Logic
//   Map<String, List<FinanceModel>> grouped = {};
  
//   for (var m in filtered) {
//     String key;
//     if (filter.grouping == GroupingType.category) {
//       key = m.category;
//     } else {
//       // Logic for Weekly/Monthly headers
//       key = "${m.date.day}/${m.date.month}"; 
//     }
//     grouped.putIfAbsent(key, () => []).add(m);
//   }

//   return grouped;
// });