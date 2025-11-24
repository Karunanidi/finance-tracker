// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecommendationData)
const recommendationDataProvider = RecommendationDataProvider._();

final class RecommendationDataProvider
    extends $AsyncNotifierProvider<RecommendationData, SpendingRecommendation> {
  const RecommendationDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendationDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendationDataHash();

  @$internal
  @override
  RecommendationData create() => RecommendationData();
}

String _$recommendationDataHash() =>
    r'1fa92933f531cb1caeb7b299c5e63fb492c158bc';

abstract class _$RecommendationData
    extends $AsyncNotifier<SpendingRecommendation> {
  FutureOr<SpendingRecommendation> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<SpendingRecommendation>, SpendingRecommendation>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SpendingRecommendation>,
                SpendingRecommendation
              >,
              AsyncValue<SpendingRecommendation>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
