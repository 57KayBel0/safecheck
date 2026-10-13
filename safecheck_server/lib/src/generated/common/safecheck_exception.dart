/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

/// A user-facing error raised by SafeCheck endpoints. The [message] is safe to
/// show in the app, and [code] lets the client react to specific failures.
abstract class SafeCheckException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  SafeCheckException._({
    required this.message,
    required this.code,
  });

  factory SafeCheckException({
    required String message,
    required String code,
  }) = _SafeCheckExceptionImpl;

  factory SafeCheckException.fromJson(Map<String, dynamic> jsonSerialization) {
    return SafeCheckException(
      message: jsonSerialization['message'] as String,
      code: jsonSerialization['code'] as String,
    );
  }

  /// Human-readable explanation of what went wrong.
  String message;

  /// Machine-readable error code, e.g. `validation`, `not_found`, `conflict`.
  String code;

  /// Returns a shallow copy of this [SafeCheckException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SafeCheckException copyWith({
    String? message,
    String? code,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SafeCheckException',
      'message': message,
      'code': code,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SafeCheckException',
      'message': message,
      'code': code,
    };
  }

  @override
  String toString() {
    return 'SafeCheckException(message: $message, code: $code)';
  }
}

class _SafeCheckExceptionImpl extends SafeCheckException {
  _SafeCheckExceptionImpl({
    required String message,
    required String code,
  }) : super._(
         message: message,
         code: code,
       );

  /// Returns a shallow copy of this [SafeCheckException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SafeCheckException copyWith({
    String? message,
    String? code,
  }) {
    return SafeCheckException(
      message: message ?? this.message,
      code: code ?? this.code,
    );
  }
}
