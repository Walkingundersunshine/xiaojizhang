import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jizhangben/core/database/app_database.dart';
import 'package:jizhangben/core/logging/app_logging.dart';
import 'package:jizhangben/features/categories/data/local_category_repository.dart';
import 'package:jizhangben/features/data_management/data/data_management_file_controller.dart';
import 'package:jizhangben/features/data_management/data/data_management_service.dart';
import 'package:jizhangben/features/exchange_rates/data/frankfurter_exchange_rate_source.dart';
import 'package:jizhangben/features/exchange_rates/data/local_exchange_rate_repository.dart';
import 'package:jizhangben/features/expenses/data/local_expense_repository.dart';
import 'package:jizhangben/features/diagnostics/data/diagnostic_log_file_controller.dart';
import 'package:jizhangben/features/settings/data/local_settings_repository.dart';
import 'package:jizhangben/features/sync/data/local_paired_device_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.open();
  ref.onDispose(database.close);
  return database;
});

final localExpenseRepositoryProvider = Provider<LocalExpenseRepository>((ref) {
  return LocalExpenseRepository(ref.watch(appDatabaseProvider));
});

final localCategoryRepositoryProvider = Provider<LocalCategoryRepository>((
  ref,
) {
  return LocalCategoryRepository(ref.watch(appDatabaseProvider));
});

final frankfurterExchangeRateSourceProvider =
    Provider<FrankfurterExchangeRateSource>((ref) {
      final source = FrankfurterExchangeRateSource();
      ref.onDispose(source.close);
      return source;
    });

final localExchangeRateRepositoryProvider =
    Provider<LocalExchangeRateRepository>((ref) {
      return LocalExchangeRateRepository(
        ref.watch(appDatabaseProvider),
        ref.watch(frankfurterExchangeRateSourceProvider),
      );
    });

final localSettingsRepositoryProvider = Provider<LocalSettingsRepository>((
  ref,
) {
  return LocalSettingsRepository(ref.watch(appDatabaseProvider));
});

final localPairedDeviceRepositoryProvider =
    Provider<LocalPairedDeviceRepository>((ref) {
      return LocalPairedDeviceRepository(ref.watch(appDatabaseProvider));
    });

final dataManagementServiceProvider = Provider<DataManagementService>((ref) {
  return DataManagementService(ref.watch(appDatabaseProvider));
});

final dataManagementFileControllerProvider =
    Provider<DataManagementFileController>((ref) {
      return DataManagementFileController(
        ref.watch(dataManagementServiceProvider),
      );
    });

final diagnosticLogFileControllerProvider =
    Provider<DiagnosticLogFileController>((ref) {
      final manager = AppLogging.manager;
      if (manager == null) {
        throw StateError('诊断日志当前不可用');
      }
      return DiagnosticLogFileController(manager);
    });

final baseCurrencyCodeProvider = StreamProvider.autoDispose<String>((ref) {
  return ref.watch(localSettingsRepositoryProvider).watchBaseCurrencyCode();
});
