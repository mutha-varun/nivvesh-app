import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nivvesh/data/api/auth_api.dart';
import 'package:nivvesh/data/api/http_client_interceptor.dart';
import 'package:nivvesh/data/cache/auth_cache.dart';
import 'package:nivvesh/data/repositories/auth_repository.dart';

// 1. Provider for flutter_secure_storage
final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

// 2. Provider for new local data source
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(ref.watch(secureStorageProvider));
});

// 2. Provider for API class
// This also creates a single instance.
final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Read the dependencies from the other providers.
  final api = ref.watch(authApiProvider);
  final client = ref.watch(httpClientProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);

  // Assemble the repository using the dependencies it was given.
  return AuthRepository(
    api: api,
    httpClient: client,
    localDataSource: localDataSource
  );
});