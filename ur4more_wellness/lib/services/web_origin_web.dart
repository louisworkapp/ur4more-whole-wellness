/// Web implementation for origin detection
import 'package:universal_html/html.dart' as html;

String? getWebOrigin() {
  try {
    return html.window.location.origin;
  } catch (e) {
    return null;
  }
}

