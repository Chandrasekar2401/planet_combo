import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps the app so that physical-keyboard arrow keys, Page Up/Down, Home/End
/// and Space scroll the currently visible vertical scrollable on web.
///
/// Skipped when focus is inside a text input so caret movement still works.
class KeyboardScrollWrapper extends StatefulWidget {
  final Widget child;
  const KeyboardScrollWrapper({super.key, required this.child});

  @override
  State<KeyboardScrollWrapper> createState() => _KeyboardScrollWrapperState();
}

class _KeyboardScrollWrapperState extends State<KeyboardScrollWrapper> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      HardwareKeyboard.instance.addHandler(_onKey);
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      HardwareKeyboard.instance.removeHandler(_onKey);
    }
    super.dispose();
  }

  bool _isEditingText() {
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null) return false;
    final ctx = primary.context;
    if (ctx == null) return false;
    return ctx.findAncestorStateOfType<EditableTextState>() != null;
  }

  bool _isVerticalAndVisible(ScrollableState s) {
    final axis = s.axisDirection;
    if (axis != AxisDirection.down && axis != AxisDirection.up) return false;
    if (!s.position.hasViewportDimension) return false;
    if (s.position.viewportDimension <= 0) return false;
    if (!s.position.hasContentDimensions) return false;
    if (s.position.maxScrollExtent <= s.position.minScrollExtent) return false;
    return true;
  }

  /// A Scrollable counts as "on the current page" only if its enclosing
  /// ModalRoute is the topmost route on the Navigator. This is what makes
  /// keyboard scroll follow the user as they navigate: routes underneath
  /// are still in the widget tree but `isCurrent == false`, so we skip them.
  bool _isOnCurrentRoute(BuildContext scrollableContext) {
    final route = ModalRoute.of(scrollableContext);
    if (route == null) return false;
    return route.isCurrent;
  }

  ScrollableState? _scrollableFromFocus() {
    final ctx = FocusManager.instance.primaryFocus?.context;
    if (ctx == null) return null;
    final s = Scrollable.maybeOf(ctx);
    if (s == null) return null;
    if (!_isVerticalAndVisible(s)) return null;
    if (!_isOnCurrentRoute(s.context)) return null;
    return s;
  }

  ScrollableState? _findScrollableInTree() {
    ScrollableState? best;
    double bestArea = -1;

    void visit(Element el) {
      if (el.widget is Scrollable && el is StatefulElement) {
        final state = el.state;
        if (state is ScrollableState &&
            _isVerticalAndVisible(state) &&
            _isOnCurrentRoute(state.context)) {
          final ro = el.findRenderObject();
          if (ro is RenderBox && ro.hasSize) {
            final size = ro.size;
            final area = size.width * size.height;
            if (area > bestArea) {
              bestArea = area;
              best = state;
            }
          }
        }
      }
      el.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return best;
  }

  ScrollableState? _findActiveScrollable() {
    return _scrollableFromFocus() ?? _findScrollableInTree();
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;

    final key = event.logicalKey;
    final isArrowDown = key == LogicalKeyboardKey.arrowDown;
    final isArrowUp = key == LogicalKeyboardKey.arrowUp;
    final isPageDown = key == LogicalKeyboardKey.pageDown;
    final isPageUp = key == LogicalKeyboardKey.pageUp;
    final isHome = key == LogicalKeyboardKey.home;
    final isEnd = key == LogicalKeyboardKey.end;
    final isSpace = key == LogicalKeyboardKey.space;

    if (!isArrowDown &&
        !isArrowUp &&
        !isPageDown &&
        !isPageUp &&
        !isHome &&
        !isEnd &&
        !isSpace) {
      return false;
    }

    if (_isEditingText()) return false;

    final scrollable = _findActiveScrollable();
    if (scrollable == null) return false;

    final pos = scrollable.position;
    final viewport = pos.viewportDimension;
    final pageStep = viewport * 0.9;

    double? target;
    if (isArrowDown || isPageDown) {
      target = pos.pixels + pageStep;
    } else if (isArrowUp || isPageUp) {
      target = pos.pixels - pageStep;
    } else if (isHome) {
      target = pos.minScrollExtent;
    } else if (isEnd) {
      target = pos.maxScrollExtent;
    } else if (isSpace) {
      final shift = HardwareKeyboard.instance.isShiftPressed;
      target = pos.pixels + (shift ? -pageStep : pageStep);
    }

    if (target == null) return false;

    final clamped =
        target.clamp(pos.minScrollExtent, pos.maxScrollExtent).toDouble();
    if ((clamped - pos.pixels).abs() < 0.5) return true;

    pos.animateTo(
      clamped,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
