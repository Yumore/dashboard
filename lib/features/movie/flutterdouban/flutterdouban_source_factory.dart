import 'package:dashboard/features/movie/flutterdouban/flutterdouban_api.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_data_source.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_mock_request.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_network_source.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_mock_source.dart';
import 'package:dio/dio.dart';

/// The single place the source's `useNetData` flag is turned into a backend.
///
/// Source (`lib/repository/movie_repository.dart:44-49`):
/// `_request = useNetData ? HttpRequest(API.BASE_URL) : MockRequest();`
///
/// This port resolves the same switch into the two [FlutterDouBanDataSource]
/// implementations. `useNetData` defaults to `true` in the host
/// ([FlutterDouBanSettingsStore.defaultUseNetData]) whereas the source
/// defaulted to `false`; the choice is still persisted under the source's own
/// `USE_NET_DATA` preferences key.
FlutterDouBanDataSource createFlutterDouBanSource({
  required bool useNetData,
  Dio? dio,
  FlutterDouBanAssetLoader? assetLoader,
}) => useNetData
    ? FlutterDouBanNetworkSource(api: FlutterDouBanApi(dio: dio))
    : FlutterDouBanMockSource(loader: assetLoader);
