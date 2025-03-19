import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// Global GetIt instance
final getIt = GetIt.instance;

/// Environment configuration for dependency injection
enum Env {
  dev,
  staging,
  prod,
}

/// Extension to convert enum to string
extension EnvExt on Env {
  String get name => toString().split('.').last;
}

/// Configure dependencies for the app
@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies({
  required Env environment,
}) async {
  await getIt.init(environment: environment.name);
} 