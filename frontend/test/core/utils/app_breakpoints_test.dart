import 'package:flutter_test/flutter_test.dart';
import 'package:vettrack_frontend/core/utils/app_breakpoints.dart';

void main() {
  test('classifies compact and expanded navigation breakpoints', () {
    expect(AppBreakpoints.isCompact(719), isTrue);
    expect(AppBreakpoints.isCompact(720), isFalse);
    expect(AppBreakpoints.usesExpandedNavigation(1099), isFalse);
    expect(AppBreakpoints.usesExpandedNavigation(1100), isTrue);
  });
}
