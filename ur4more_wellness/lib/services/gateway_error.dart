/// Structured error information for gateway requests
class GatewayError {
  final String url;
  final GatewayErrorKind kind;
  final String rawException;
  final String? message;
  final int? statusCode;
  final String? origin; // Web origin when available

  const GatewayError({
    required this.url,
    required this.kind,
    required this.rawException,
    this.message,
    this.statusCode,
    this.origin,
  });

  /// Create a GatewayError from an exception
  factory GatewayError.fromException(
    Object exception,
    String url, {
    int? statusCode,
    String? origin,
  }) {
    final exceptionString = exception.toString();
    final message = exception is Exception ? exception.toString() : null;

    // Categorize the error
    GatewayErrorKind? kind;
    
    // Check HTTP status codes first
    if (statusCode != null) {
      if (statusCode == 401 || statusCode == 403) {
        kind = GatewayErrorKind.unauthorized;
      } else if (statusCode >= 400 && statusCode < 500) {
        kind = GatewayErrorKind.http;
      } else if (statusCode >= 500) {
        kind = GatewayErrorKind.http;
      }
    }
    
    // Map exception strings to error kinds
    if (kind == null) {
      final lowerException = exceptionString.toLowerCase();
      if (lowerException.contains('cors') ||
          lowerException.contains('cross-origin') ||
          lowerException.contains('access-control') ||
          lowerException.contains('failed to fetch') ||
          lowerException.contains('typeerror: failed to fetch') ||
          lowerException.contains('networkerror') ||
          lowerException.contains('network error')) {
        kind = GatewayErrorKind.cors;
      } else if (lowerException.contains('failed host lookup') ||
          lowerException.contains('getaddrinfo failed') ||
          lowerException.contains('dns') ||
          lowerException.contains('name or service not known') ||
          lowerException.contains('nodename nor servname provided')) {
        kind = GatewayErrorKind.dns;
      } else if (lowerException.contains('connection refused') ||
          lowerException.contains('econnrefused') ||
          lowerException.contains('refused') ||
          lowerException.contains('connection reset')) {
        kind = GatewayErrorKind.refused;
      } else if (lowerException.contains('timeout') ||
          lowerException.contains('timeoutexception') ||
          lowerException.contains('timed out')) {
        kind = GatewayErrorKind.timeout;
      } else {
        kind = GatewayErrorKind.unknown;
      }
    }

    // Ensure kind is never null
    final finalKind = kind ?? GatewayErrorKind.unknown;

    return GatewayError(
      url: url,
      kind: finalKind,
      rawException: exceptionString,
      message: message,
      statusCode: statusCode,
      origin: origin,
    );
  }

  /// Short user-friendly message
  String shortMessage() {
    switch (kind) {
      case GatewayErrorKind.cors:
        return 'Gateway not reachable from this origin';
      case GatewayErrorKind.dns:
        return 'Cannot resolve gateway address';
      case GatewayErrorKind.refused:
        return 'Gateway connection refused';
      case GatewayErrorKind.timeout:
        return 'Gateway request timed out';
      case GatewayErrorKind.unauthorized:
        return 'Authentication required';
      case GatewayErrorKind.http:
        return 'Gateway returned error ${statusCode ?? 'unknown'}';
      case GatewayErrorKind.unknown:
        return 'Gateway request failed';
    }
  }

  String get displayMessage => 'Gateway request failed: ${kind.toString()} $url';

  String get detailedMessage {
    final buffer = StringBuffer();
    buffer.writeln('URL: $url');
    buffer.writeln('Kind: ${kind.toString()}');
    if (statusCode != null) {
      buffer.writeln('Status Code: $statusCode');
    }
    if (origin != null) {
      buffer.writeln('Web Origin: $origin');
    }
    if (message != null) {
      buffer.writeln('Message: $message');
    }
    buffer.writeln('Exception: $rawException');
    return buffer.toString();
  }

  /// Check if this is a network-like error (not HTTP status codes)
  bool isNetworkLike() {
    return kind == GatewayErrorKind.cors ||
        kind == GatewayErrorKind.dns ||
        kind == GatewayErrorKind.refused ||
        kind == GatewayErrorKind.timeout;
  }

  /// Check if this is likely a CORS error
  bool isCorsLikely() {
    return kind == GatewayErrorKind.cors ||
        (kind == GatewayErrorKind.unknown && 
         rawException.toLowerCase().contains('failed to fetch'));
  }

  @override
  String toString() => displayMessage;
}

enum GatewayErrorKind {
  cors,
  dns,
  refused,
  timeout,
  unauthorized,
  http,
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
      case GatewayErrorKind.unauthorized:
        return 'Unauthorized';
      case GatewayErrorKind.http:
        return 'HTTP Error';
      case GatewayErrorKind.unknown:
        return 'Unknown';
    }
  }
}

