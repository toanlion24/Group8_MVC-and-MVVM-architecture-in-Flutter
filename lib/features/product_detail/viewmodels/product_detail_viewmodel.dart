import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/product_detail_service.dart';

/// ProductDetailViewModel - ViewModel theo kiến trúc MVVM
///
/// - Gọi Service để lấy dữ liệu
/// - Cung cấp State (AsyncValue<ProductModel?>) cho View
/// - Sử dụng Riverpod FutureProvider.family (productId)
final productDetailServiceProvider = Provider<ProductDetailService>((ref) {
  return ProductDetailService();
});

/// Provider cho ProductDetailViewModel
/// ViewModel gọi Service, cung cấp AsyncValue<ProductModel?> cho View
/// Sử dụng: ref.watch(productDetailViewModelProvider(productId))
final productDetailViewModelProvider =
    FutureProvider.autoDispose.family<ProductModel?, String>((ref, productId) async {
  if (productId.isEmpty) return null;
  return ref.read(productDetailServiceProvider).getProductById(productId);
});
