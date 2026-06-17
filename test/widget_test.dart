import 'package:flutter_test/flutter_test.dart';
import 'package:memoquest/core/utils/xp_utils.dart';

void main() {
  test('calculate level from xp', () {
    expect(XpUtils.calculateLevel(0), 1);
    expect(XpUtils.calculateLevel(99), 1);
    expect(XpUtils.calculateLevel(100), 2);
    expect(XpUtils.calculateLevel(250), 3);
  });
}
