// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_recommendation_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiRecommendationService)
const aiRecommendationServiceProvider = AiRecommendationServiceProvider._();

final class AiRecommendationServiceProvider
    extends
        $FunctionalProvider<
          AiRecommendationService,
          AiRecommendationService,
          AiRecommendationService
        >
    with $Provider<AiRecommendationService> {
  const AiRecommendationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiRecommendationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiRecommendationServiceHash();

  @$internal
  @override
  $ProviderElement<AiRecommendationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AiRecommendationService create(Ref ref) {
    return aiRecommendationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiRecommendationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiRecommendationService>(value),
    );
  }
}

String _$aiRecommendationServiceHash() =>
    r'3f0839df34784b62a86a63673cfccb99bf05deff';
