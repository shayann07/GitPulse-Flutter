import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

void showLoading(WidgetRef ref) {
  ref.read(loadingProvider.notifier).state = true;
}

void hideLoading(WidgetRef ref) {
  ref.read(loadingProvider.notifier).state = false;
}
