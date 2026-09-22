class RecommendResult {
  const RecommendResult({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productWidth,
    required this.productDepth,
    required this.productHeight,
    required this.imageUrl,
    required this.modelUrl,
  });

  final int productId;
  final String productName;
  final int productPrice;
  final double productWidth;
  final double productDepth;
  final double productHeight;
  final String imageUrl;
  final String modelUrl;
}
