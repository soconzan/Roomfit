import 'package:roomfit_client/features/auth/domain/entities/auth_tokens.dart';

class CheckResultResponse {
  const CheckResultResponse({required this.success, required this.message});

  factory CheckResultResponse.fromJson(Map<String, dynamic> json) =>
      CheckResultResponse(
        success: json['success'] as bool,
        message: json['message'] as String? ?? '',
      );

  final bool success;
  final String message;

  CheckResult toEntity() => CheckResult(success: success, message: message);
}
