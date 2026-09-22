import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roomfit_client/core/network/dio_client.dart';
import 'package:roomfit_client/features/category/data/repositories/category_repository_impl.dart';
import 'package:roomfit_client/features/category/data/sources/remote/category_remote_source.dart';
import 'package:roomfit_client/features/category/domain/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(
    CategoryRemoteSource(ref.watch(dioProvider)),
  ),
);
