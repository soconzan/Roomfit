import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_sizes.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/features/product/domain/entities/labeled_photo.dart';

// 촬영 각도 정의
enum _CameraAngle {
  front('앞면', 'front'),
  right('우측', 'right'),
  left('좌측', 'left'),
  back('뒷면', 'back');

  const _CameraAngle(this.label, this.key);

  final String label;
  final String key;
}

class ModelingCameraMultiScreen extends StatefulWidget {
  const ModelingCameraMultiScreen({super.key});

  @override
  State<ModelingCameraMultiScreen> createState() =>
      _ModelingCameraMultiScreenState();
}

class _ModelingCameraMultiScreenState extends State<ModelingCameraMultiScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  _CameraAngle _selectedAngle = _CameraAngle.front;
  final Map<_CameraAngle, XFile> _capturedPhotos = {};

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = '카메라를 찾을 수 없습니다.');
        return;
      }
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = '카메라 초기화에 실패했습니다.\n$e');
    }
  }

  // 현재 각도 촬영
  Future<void> _onShutter() async {
    if (_controller == null || !_isInitialized) return;
    try {
      final file = await _controller!.takePicture();
      setState(() => _capturedPhotos[_selectedAngle] = file);
    } catch (_) {}
  }

  // 현재 각도 재촬영
  void _onRetry() {
    setState(() => _capturedPhotos.remove(_selectedAngle));
  }

  // 갤러리에서 이미지 선택
  Future<void> _pickFromGallery() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() => _capturedPhotos[_selectedAngle] = file);
  }

  // 3D 모델 생성 — 라벨링된 사진 목록을 이전 화면(modeling_method)으로 반환
  void _onGenerate() {
    final photos =
        _capturedPhotos.entries
            .map((e) => LabeledPhoto(label: e.key.key, file: e.value))
            .toList();
    context.pop(photos);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final capturedCount = _capturedPhotos.length;
    final hasFront = _capturedPhotos.containsKey(_CameraAngle.front);
    final canGenerate = hasFront && capturedCount >= 2;
    final currentCapture = _capturedPhotos[_selectedAngle];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildPreviewArea(currentCapture),
            Expanded(
              child: _buildBottomBar(
                currentCapture,
                capturedCount,
                canGenerate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 상단 헤더: 닫기 버튼 + 제목 + 각도 선택 버튼
  Widget _buildHeader() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(AppSizes.kSpaceLg),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(Icons.close, color: AppColors.kWhite, size: 22),
            ),
          ),
          Text(
            '가구 ${_selectedAngle.label} 촬영',
            style: const TextStyle(
              color: AppColors.kWhite,
              fontSize: AppSizes.kFontLg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 카메라 프리뷰 or 캡처 이미지 (3:4 비율)
  Widget _buildPreviewArea(XFile? currentCapture) {
    final aspectRatio =
        (_isInitialized && _controller != null)
            ? 1 / _controller!.value.aspectRatio
            : 3 / 4;
    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (currentCapture != null)
              Image.file(File(currentCapture.path), fit: BoxFit.cover)
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.kWhite),
                  ),
                ),
              )
            else if (_isInitialized && _controller != null)
              CameraPreview(_controller!)
            else
              const Center(
                child: CircularProgressIndicator(color: AppColors.kWhite),
              ),

            // 각도 선택 버튼 오버레이
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      _CameraAngle.values
                          .map(
                            (angle) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: _AngleButton(
                                angle: angle,
                                isSelected: _selectedAngle == angle,
                                isCaptured: _capturedPhotos.containsKey(angle),
                                onTap:
                                    () =>
                                        setState(() => _selectedAngle = angle),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),

            // 힌트 텍스트 오버레이 (촬영 전에만 표시)
            if (currentCapture == null)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(153),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      AppStrings.kModelingCameraHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE2EBE9),
                        fontSize: AppSizes.kFontSm,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 하단 바: 셔터/재촬영 버튼 + 액션 버튼
  Widget _buildBottomBar(
    XFile? currentCapture,
    int capturedCount,
    bool canGenerate,
  ) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        children: [
          // 3D 모델 생성 버튼 (2장 이상 시 활성화)
          GestureDetector(
            onTap: canGenerate ? _onGenerate : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.kSpaceSm),
              decoration: BoxDecoration(
                color:
                    canGenerate
                        ? AppColors.k3dButtonBg
                        : Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(7),
                border:
                    canGenerate
                        ? null
                        : Border.all(color: Colors.white.withAlpha(102)),
              ),
              child: Text(
                canGenerate
                    ? '촬영한 사진으로 3D 모델 생성하기 ($capturedCount/4)'
                    : '앞면 포함 2장 이상 ($capturedCount/4)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      canGenerate ? Colors.black : Colors.white.withAlpha(153),
                  fontSize: AppSizes.kFontSm,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // 셔터 or 재촬영 버튼 — 중앙, 갤러리 아이콘 왼쪽
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: GestureDetector(
                        onTap: _pickFromGallery,
                        child: SvgPicture.asset(
                          'assets/icons/ic_gallery_outline.svg',
                          width: 35,
                          height: 35,
                          colorFilter: ColorFilter.mode(
                            Colors.white.withAlpha(200),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                currentCapture != null
                    ? _RetryButton(onTap: _onRetry)
                    : _ShutterButton(onTap: _onShutter),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private Widgets ──────────────────────────────────────────────────────────

// 각도 선택 버튼
class _AngleButton extends StatelessWidget {
  const _AngleButton({
    required this.angle,
    required this.isSelected,
    required this.isCaptured,
    required this.onTap,
  });

  final _CameraAngle angle;
  final bool isSelected;
  final bool isCaptured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 선택됨: 밝은 흰색 / 촬영됨(미선택): 중간 / 미촬영 미선택: 어두운
    final bgAlpha = isSelected ? 128 : 64;
    final borderAlpha = isSelected ? 255 : (isCaptured ? 178 : 128);
    final textAlpha = isSelected ? 255 : (isCaptured ? 192 : 156);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(bgAlpha),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.white.withAlpha(borderAlpha)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            // 상태 인디케이터 원
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: isCaptured ? AppColors.k3dButtonBg : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border:
                    isCaptured
                        ? null
                        : Border.all(
                          color: Colors.white.withAlpha(borderAlpha),
                        ),
              ),
              child:
                  isCaptured
                      ? const Icon(Icons.check, size: 10, color: Colors.black)
                      : null,
            ),
            Text(
              angle.label,
              style: TextStyle(
                color: Colors.white.withAlpha(textAlpha),
                fontSize: AppSizes.kFontXs,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 셔터 버튼: 흰색 원형 이중 테두리
class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65,
        height: 65,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 2, color: Colors.white),
          boxShadow: const [
            BoxShadow(color: Color(0x2698AEAE), blurRadius: 15),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// 재촬영 버튼: 흰색 테두리 원형 + refresh 아이콘
class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 2, color: Colors.white),
          boxShadow: const [
            BoxShadow(color: Color(0x2698AEAE), blurRadius: 15),
          ],
        ),
        child: const Center(
          child: Icon(Icons.refresh_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
