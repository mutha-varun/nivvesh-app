import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nivvesh/application/auth/auth_provider.dart';
import 'package:nivvesh/data/api/http_client_interceptor.dart';
import 'package:nivvesh/data/api/user_api.dart';
import 'package:nivvesh/data/cache/user_cache.dart';
import 'package:nivvesh/data/repositories/user_repository.dart';

final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  return UserLocalDataSource(ref.watch(secureStorageProvider));
});

final userApiProvider = Provider<UserApi>((ref) => UserApi());

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    api: ref.watch(userApiProvider),
    httpClient: ref.watch(httpClientProvider),
    localDataSource: ref.watch(userLocalDataSourceProvider),
  );
});
