import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'local_cache.dart';
import 'routevia_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
final localCacheProvider = Provider<LocalCache>((ref) => LocalCache());
final repositoryProvider = Provider<RouteviaRepository>(
  (ref) => RouteviaRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(localCacheProvider),
  ),
);
