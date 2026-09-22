import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:roomfit_client/core/constants/app_api.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/platform/ar_launcher.dart';
import 'package:roomfit_client/features/product/presentation/provider/product_provider.dart';
import 'package:roomfit_client/shared/presentation/widgets/product_viewer_nav_bar.dart';

class Product3dViewerScreen extends ConsumerStatefulWidget {
  const Product3dViewerScreen({
    super.key,
    required this.productId,
    this.width = 0,
    this.height = 0,
    this.depth = 0,
  });

  final int productId;
  final double width;
  final double height;
  final double depth;

  @override
  ConsumerState<Product3dViewerScreen> createState() =>
      _Product3dViewerScreenState();
}

class _Product3dViewerScreenState extends ConsumerState<Product3dViewerScreen>
    with WidgetsBindingObserver {
  bool _showModelViewer = true;
  int _modelViewerVersion = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _showModelViewer || !mounted) {
      return;
    }

    setState(() {
      _modelViewerVersion++;
      _showModelViewer = true;
    });
  }

  Future<void> _launchAr(String modelUrl) async {
    final uri = Uri.parse(
      AppApi.arDetailLink(
        productId: widget.productId,
        modelUrl: modelUrl,
        width: widget.width,
        height: widget.height,
        depth: widget.depth,
      ),
    );

    if (mounted) {
      setState(() => _showModelViewer = false);
      await WidgetsBinding.instance.endOfFrame;
    }

    try {
      await ArLauncher.launch(uri);
    } catch (e) {
      debugPrint('🔴 [ERROR] AR 딥링크 호출 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final modelAsync = ref.watch(productModelProvider(widget.productId));

    return Scaffold(
      backgroundColor: AppColors.kBlack,
      body: modelAsync.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppColors.kWhite),
            ),
        error:
            (e, _) => SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.kWhite),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '3D 모델을 불러올 수 없습니다.',
                        style: TextStyle(color: AppColors.kWhite, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        data:
            (model) => Stack(
              children: [
                if (_showModelViewer)
                  ModelViewer(
                    key: ValueKey(_modelViewerVersion),
                    src: model.modelUrl,
                    ar: false,
                    autoRotate: false,
                    cameraControls: true,
                    backgroundColor: Colors.white,
                  )
                else
                  const ColoredBox(color: AppColors.kWhite),
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 2.5,
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.30),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        left: 15,
                        top: 15,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 26,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 15,
                        top: 15,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              '?',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 30,
                        child: Center(
                          child: ProductViewerNavBar(
                            onTap3d: () => Navigator.pop(context),
                            onTapAr: () => _launchAr(model.modelUrl),
                            active3d: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
