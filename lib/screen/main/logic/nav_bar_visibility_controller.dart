import 'package:flutter/foundation.dart';

class NavBarVisibilityController extends ChangeNotifier {
  bool _isVisible = true;
  double _lastOffset = 0.0;

  bool get isVisible => _isVisible;

  /// Call this method with the current scroll offset.
  void onScroll(double offset) {
    if (offset > _lastOffset && _isVisible) {
      // User is scrolling down - hide nav bar.
      _isVisible = false;
      notifyListeners();
    } else if (offset < _lastOffset && !_isVisible) {
      // User is scrolling up - show nav bar.
      _isVisible = true;
      notifyListeners();
    }
    _lastOffset = offset;
  }
}
