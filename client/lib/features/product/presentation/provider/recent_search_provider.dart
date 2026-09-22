import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchNotifier extends AsyncNotifier<List<String>> {
  static const _key = 'recent_searches';
  static const _maxItems = 10;

  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final current = state.valueOrNull ?? [];
    final updated = [trimmed, ...current.where((e) => e != trimmed)]
        .take(_maxItems)
        .toList();
    await prefs.setStringList(_key, updated);
    state = AsyncData(updated);
  }

  Future<void> remove(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final updated =
        (state.valueOrNull ?? []).where((e) => e != query).toList();
    await prefs.setStringList(_key, updated);
    state = AsyncData(updated);
  }
}

final recentSearchProvider =
    AsyncNotifierProvider<RecentSearchNotifier, List<String>>(
  RecentSearchNotifier.new,
);
