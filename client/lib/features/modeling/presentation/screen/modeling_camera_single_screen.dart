import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:roomfit_client/core/constants/app_colors.dart';
import 'package:roomfit_client/core/constants/app_strings.dart';
import 'package:roomfit_client/core/router/app_router.dart';

class ModelingCameraSingleScreen extends StatefulWidget {
  const ModelingCameraSingleScreen({super.key});

  @override
  State<ModelingCameraSingleScreen> createState() =>
      _ModelingCameraSingleScreenState();
}

class _ModelingCameraSingleScreenState
    extends State<ModelingCameraSingleScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  String? _errorMessage;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  bool _isLevel = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initAccelerometer();
  }

  // 카메라 초기화
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = '카메라를 찾을 수 없습니다.');
        return;
      }
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = '카메라 초기화에 실패했습니다.\n$e');
    }
  }

  // 가속도 센서로 수평 감지
  // x축 기울기(좌우)와 y축 기울기(앞뒤)가 모두 ±5도 이내이면 수평으로 판단
  void _initAccelerometer() {
    _accelSub = accelerometerEventStream().listen((AccelerometerEvent e) {
      final xAngle = atan2(e.x, sqrt(e.y * e.y + e.z * e.z)) * 180 / pi;
      final yAngle = atan2(e.z, sqrt(e.x * e.x + e.y * e.y)) * 180 / pi;
      final isLevel = xAngle.abs() < 5.0 && yAngle.abs() < 5.0;
      if (isLevel != _isLevel) setState(() => _isLevel = isLevel);
    });
  }

  // 셔터: 사진 캡처 후 모델 생성 화면으로 이동
  Future<void> _onShutter() async {
    if (_controller == null || !_isInitialized) return;
    try {
      final file = await _controller!.takePicture();
      if (mounted) context.push(AppPaths.modelingCreateSingle, extra: file);
    } catch (_) {}
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildPreview()),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // 상단 헤더: 뒤로가기 + 제목 + 힌트
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.kWhite,
                size: 20,
              ),
            ),
          ),
          const Text(
            AppStrings.kModelingCameraSingleTitle,
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            AppStrings.kModelingCameraHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.kWhite,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // 카메라 프리뷰 + 수평 감지 오버레이
  Widget _buildPreview() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.kWhite),
          ),
        ),
      );
    }
    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.kWhite),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            CameraPreview(_controller!),
            _LevelIndicator(isLevel: _isLevel),
          ],
        ),
      ),
    );
  }

  // 하단 셔터 버튼 영역
  Widget _buildBottomBar() {
    return Container(
      color: Colors.black,
      height: 160,
      child: Center(child: _ShutterButton(onTap: _onShutter)),
    );
  }
}

// ── Private Widgets ──────────────────────────────────────────────────────────

// 수평 감지 오버레이: 원형 반투명 컨테이너 + 3개의 수평선
class _LevelIndicator extends StatelessWidget {
  const _LevelIndicator({required this.isLevel});

  final bool isLevel;

  @override
  Widget build(BuildContext context) {
    final lineColor = isLevel ? AppColors.k3dButtonBg : AppColors.kWhite;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          _LevelLine(color: lineColor),
          _LevelLine(color: lineColor),
          _LevelLine(color: lineColor),
        ],
      ),
    );
  }
}

// 수평선 (AnimatedContainer로 색상 전환 애니메이션)
class _LevelLine extends StatelessWidget {
  const _LevelLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 36,
      height: 2,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

// 셔터 버튼: 흰색 원형 + 내부 스캔 아이콘
class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          color: AppColors.kWhite,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.crop_free_rounded,
            color: AppColors.k3dButtonBg,
            size: 34,
          ),
        ),
      ),
    );
  }
}
