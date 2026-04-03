import 'package:get_it/get_it.dart';
import 'package:indigo_insights/api/indigo_api/services/asset_price_service.dart';
import 'package:indigo_insights/api/indigo_api/services/asset_status_service.dart';
import 'package:indigo_insights/api/indigo_api/services/cdp_service.dart';
import 'package:indigo_insights/api/indigo_api/services/dex_yield_service.dart';
import 'package:indigo_insights/api/indigo_api/services/indigo_asset_service.dart';
import 'package:indigo_insights/api/indigo_api/services/indy_service.dart';
import 'package:indigo_insights/api/indigo_api/services/liquidation_service.dart';
import 'package:indigo_insights/api/indigo_api/services/redemption_service.dart';
import 'package:indigo_insights/api/indigo_api/services/stability_pool_account_service.dart';
import 'package:indigo_insights/api/indigo_api/services/stability_pool_service.dart';
import 'package:indigo_insights/api/indigo_api/services/stake_history_service.dart';
import 'package:indigo_insights/repositories/asset_price_repository.dart';
import 'package:indigo_insights/repositories/asset_status_repository.dart';
import 'package:indigo_insights/repositories/cdp_repository.dart';
import 'package:indigo_insights/repositories/dex_yield_repository.dart';
import 'package:indigo_insights/repositories/indigo_asset_repository.dart';
import 'package:indigo_insights/repositories/indy_price_repository.dart';
import 'package:indigo_insights/repositories/liquidation_repository.dart';
import 'package:indigo_insights/repositories/redemption_repository.dart';
import 'package:indigo_insights/repositories/solvency_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_account_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_repository.dart';
import 'package:indigo_insights/repositories/stake_history_repository.dart';
import 'package:indigo_insights/repositories/strategy_repository.dart';

final GetIt sl = GetIt.instance;

void setupServiceLocator() {
  // Services
  sl.registerLazySingleton(() => AssetPriceService());
  sl.registerLazySingleton(() => AssetStatusService());
  sl.registerLazySingleton(() => CdpService());
  sl.registerLazySingleton(() => DexYieldService());
  sl.registerLazySingleton(() => IndigoAssetService());
  sl.registerLazySingleton(() => IndyService());
  sl.registerLazySingleton(() => LiquidationService());
  sl.registerLazySingleton(() => RedemptionService());
  sl.registerLazySingleton(() => StabilityPoolService());
  sl.registerLazySingleton(() => StabilityPoolAccountService());
  sl.registerLazySingleton(() => StakeHistoryService());

  // Base repositories — lazy singletons (created on first access, live for app lifetime)
  sl.registerLazySingleton(() => AssetPriceRepository(sl()));
  sl.registerLazySingleton(() => AssetStatusRepository(sl()));
  sl.registerLazySingleton(() => CdpRepository(sl()));
  sl.registerLazySingleton(() => DexYieldRepository(sl()));
  sl.registerLazySingleton(() => IndigoAssetRepository(sl()));
  sl.registerLazySingleton(() => IndyPriceRepository(sl()));
  sl.registerLazySingleton(() => LiquidationRepository(sl()));
  sl.registerLazySingleton(() => RedemptionRepository(sl()));
  sl.registerLazySingleton(() => StabilityPoolRepository(sl()));
  sl.registerLazySingleton(() => StabilityPoolAccountRepository(sl()));
  sl.registerLazySingleton(() => StakeHistoryRepository(sl()));

  // Composed repositories — inject their base repository dependencies
  sl.registerLazySingleton(
    () => SolvencyRepository(sl(), sl(), sl()),
  );
  sl.registerLazySingleton(
    () => StrategyRepository(sl(), sl(), sl(), sl(), sl(), sl()),
  );
}
