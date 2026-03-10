import 'package:arcon_travel_app/data/repositories/document_repository.dart';
import 'package:arcon_travel_app/data/repositories/feedback_repository.dart';
import 'package:arcon_travel_app/data/repositories/incident_repository.dart';
import 'package:arcon_travel_app/data/repositories/travels_repository.dart';
import 'package:arcon_travel_app/data/services/document_api_service.dart';
import 'package:arcon_travel_app/data/services/feedback_service.dart';
import 'package:arcon_travel_app/data/services/incident_service.dart';
import 'package:arcon_travel_app/data/services/travel_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/storage_repository.dart';
import '../../data/services/api_client.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import '../constants/api_constant.dart';

final GetIt locator = GetIt.instance;

/// Initialize dependencies
Future<void> setupDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();

  // Register shared preferences
  locator.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register repositories
  locator.registerSingleton<StorageRepository>(
    StorageRepository(sharedPreferences),
  );

  // Register base services
  final baseApiService = ApiService(baseUrl: ApiConstants.baseUrl);
  locator.registerSingleton<ApiService>(baseApiService);

  // Register API client with token refresh
  locator.registerSingleton<ApiClient>(
    ApiClient(storageRepository: locator<StorageRepository>()),
  );

  // Register feature services
  locator.registerSingleton<AuthService>(
    AuthService(
      apiService: locator<ApiClient>(),
      storageRepository: locator<StorageRepository>(),
    ),
  );

  locator.registerSingleton<AuthRepository>(
    AuthRepository(locator<AuthService>()),
  );

  locator.registerSingleton<IncidentService>(
    IncidentService(apiService: locator<ApiClient>()),
  );

  // Register repositories that use services
  locator.registerSingleton<IncidentRepository>(
    IncidentRepository(locator<IncidentService>()),
  );

  locator.registerSingleton<TravelService>(
    TravelService(apiService: locator<ApiClient>()),
  );

  locator.registerSingleton<TravelsRepository>(
    TravelsRepository(locator<TravelService>()),
  );

  locator.registerSingleton<FeedbackService>(
    FeedbackService(apiService: locator<ApiClient>()),
  );

  locator.registerSingleton<FeedbackRepository>(
    FeedbackRepository(locator<FeedbackService>()),
  );

  locator.registerSingleton<DocumentApiService>(
    DocumentApiService(apiService: locator<ApiClient>()),
  );

  locator.registerSingleton<DocumentRepository>(
    DocumentRepository(locator<DocumentApiService>()),
  );
}
