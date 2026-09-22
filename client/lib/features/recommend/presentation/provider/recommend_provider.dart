import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roomfit_client/features/recommend/data/repositories/recommend_repository_provider.dart';
import 'package:roomfit_client/features/recommend/domain/entities/recommend_request_params.dart';
import 'package:roomfit_client/features/recommend/domain/entities/recommend_result.dart';
import 'package:roomfit_client/features/recommend/domain/usecases/recommend_usecase.dart';

final _recommendUseCaseProvider = Provider.autoDispose<RecommendUseCase>(
  (ref) => RecommendUseCase(ref.watch(recommendRepositoryProvider)),
);

class RecommendNotifier
    extends AutoDisposeAsyncNotifier<List<RecommendResult>> {
  @override
  Future<List<RecommendResult>> build() async => [];

  Future<void> recommend(RecommendRequestParams params) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(_recommendUseCaseProvider).call(params),
    );
  }
}

final recommendProvider = AsyncNotifierProvider.autoDispose<RecommendNotifier,
    List<RecommendResult>>(
  RecommendNotifier.new,
);
