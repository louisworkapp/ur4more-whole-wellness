/// Structured error information for gateway requests
class GatewayError {
  final String url;
  final GatewayErrorKind kind;
  final String rawException;
  final String? message;
  final int? statusCode;

  const GatewayError({
    required this.url,
    required this.kind,
    required this.rawException,
    this.message,
    this.statusCode,
  });

  /// Create a GatewayError from an exception
  factory GatewayError.fromException(
    Object exception,
    String url, {
    int? statusCode,
  }) {
    final exceptionString = exception.toString();
    final message = exception is Exception ? exception.toString() : null;

    // Categorize the error
    GatewayErrorKind kind;
    if (exceptionString.contains('CORS') ||
        exceptionString.contains('cross-origin') ||
        exceptionString.contains('Access-Control')) {
      kind = GatewayErrorKind.cors;
    } else if (exceptionString.contains('Failed host lookup') ||
        exceptionString.contains('getaddrinfo failed') ||
        exceptionString.contains('DNS') ||
        exceptionString.contains('Name or service not known')) {
      kind = GatewayErrorKind.dns;
    } else if (exceptionString.contains('Connection refused') ||
        exceptionString.contains('ECONNREFUSED') ||
        exceptionString.contains('refused')) {
      kind = GatewayErrorKind.refused;
    } else if (exceptionString.contains('timeout') ||
        exceptionString.contains('TimeoutException') ||
        exceptionString.contains('timed out')) {
      kind = GatewayErrorKind.timeout;
    } else {
      kind = GatewayErrorKind.unknown;
    }

    return GatewayError(
      url: url,
      kind: kind,
      rawException: exceptionString,
      message: message,
      statusCode: statusCode,
    );
  }

  String get displayMessage => 'Gateway request failed: $kind $url';

  String get detailedMessage {
    final buffer = StringBuffer();
    buffer.writeln('URL: $url');
    buffer.writeln('Kind: $kind');
    if (statusCode != null) {
      buffer.writeln('Status: $statusCode');
    }
    if (message != null) {
      buffer.writeln('Message: $message');
    }
    buffer.writeln('Exception: $rawException');
    return buffer.toString();
  }

  @override
  String toString() => displayMessage;
}

enum GatewayErrorKind {
  cors,
  dns,
  refused,
  timeout,
  unknown;

  @override
  String toString() {
    switch (this) {
      case GatewayErrorKind.cors:
        return 'CORS';
      case GatewayErrorKind.dns:
        return 'DNS';
      case GatewayErrorKind.refused:
        return 'Connection Refused';
      case GatewayErrorKind.timeout:
        return 'Timeout';
      case GatewayErrorKind.unknown:
        return 'Unknown';
    }
  }
}

