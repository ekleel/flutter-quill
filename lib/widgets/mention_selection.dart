import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';

/// Builder function for mention suggestions for user.
typedef MentionSuggestionWidgetBuilder = Widget Function(
  BuildContext context,
  String trigger,
  String value,
);

class MentionSuggestion {
  const MentionSuggestion({
    @required this.values,
  });

  final List<Map<String, dynamic>> values;
}

class MentionSuggestionOverlay {
  final BuildContext context;
  final QuillController controller;
  final RenderEditor renderObject;
  final Widget debugRequiredFor;
  final TextEditingValue textEditingValue;
  final void Function(String, String, String) onSelected;
  final WidgetBuilder builder;
  OverlayEntry overlayEntry;

  MentionSuggestionOverlay({
    @required this.controller,
    @required this.textEditingValue,
    @required this.context,
    @required this.renderObject,
    @required this.debugRequiredFor,
    @required this.builder,
    this.onSelected,
  });

  void showSuggestions() {
    overlayEntry = OverlayEntry(
      builder: (context) => _MentionSuggestionList(
        controller: controller,
        renderObject: renderObject,
        textEditingValue: textEditingValue,
        onSelected: onSelected,
        builder: builder,
      ),
    );
    Overlay.of(context, rootOverlay: true, debugRequiredFor: debugRequiredFor).insert(overlayEntry);
  }

  void hide() {
    overlayEntry.remove();
  }

  void updateForScroll() {
    _markNeedsBuild();
  }

  void _markNeedsBuild() {
    overlayEntry.markNeedsBuild();
  }
}

const double listMaxHeight = 200;

class _MentionSuggestionList extends StatelessWidget {
  final QuillController controller;
  final RenderEditor renderObject;
  final TextEditingValue textEditingValue;
  final void Function(String, String, String) onSelected;
  final WidgetBuilder builder;

  const _MentionSuggestionList({
    Key key,
    @required this.controller,
    @required this.renderObject,
    @required this.textEditingValue,
    @required this.builder,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final endpoints = renderObject.getEndpointsForSelection(textEditingValue.selection);
    final editingRegion = Rect.fromPoints(
      renderObject.localToGlobal(Offset.zero),
      renderObject.localToGlobal(renderObject.size.bottomRight(Offset.zero)),
    );
    final baseLineHeight = renderObject.preferredLineHeight(textEditingValue.selection.base);
    final listMaxWidth = editingRegion.width / 2;
    final screenHeight = MediaQuery.of(context).size.height;

    var positionFromTop = endpoints[0].point.dy + editingRegion.top;
    var positionFromRight = editingRegion.width - endpoints[0].point.dx;
    double positionFromLeft;

    if (positionFromTop + listMaxHeight > screenHeight) {
      positionFromTop = positionFromTop - listMaxHeight - baseLineHeight;
    }
    if (positionFromRight + listMaxWidth > editingRegion.width) {
      positionFromRight = null;
      positionFromLeft = endpoints[0].point.dx;
    }

    return Positioned(
      top: positionFromTop,
      right: positionFromRight,
      left: positionFromLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: listMaxWidth, maxHeight: listMaxHeight),
        child: _buildOverlayWidget(context),
      ),
    );
  }

  Widget _buildOverlayWidget(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: IntrinsicWidth(
          child: builder(context),
        ),
      ),
    );
  }
}
