import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roomfit_client/core/network/dio_client.dart';
import 'package:roomfit_client/features/product/data/repositories/product_repository_impl.dart';
import 'package:roomfit_client/features/product/data/sources/remote/product_remote_source.dart';
import 'package:roomfit_client/features/product/domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(ProductRemoteSource(ref.watch(dioProvider))),
);
