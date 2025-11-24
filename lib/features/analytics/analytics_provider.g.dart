// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnalyticsData)
const analyticsDataProvider = AnalyticsDataProvider._();

final class AnalyticsDataProvider
    extends $AsyncNotifierProvider<AnalyticsData, AnalyticsStats> {
  const AnalyticsDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsDataHash();

  @$internal
  @override
  AnalyticsData create() => AnalyticsData();
}

String _$analyticsDataHash() => r'38b2c338d77c46bb38d6916395d5fb2855f68291';

abstract class _$AnalyticsData extends $AsyncNotifier<AnalyticsStats> {
  FutureOr<AnalyticsStats> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AnalyticsStats>, AnalyticsStats>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AnalyticsStats>, AnalyticsStats>,
              AsyncValue<AnalyticsStats>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
