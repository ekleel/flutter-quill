import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';

/// Builder function for mention suggestions for user.
typedef MentionSuggestionWidgetBuilder = Widget Function(
  BuildContext context,
  // List<T> suggestions,
  // bool isLoading,
);

class MentionSuggestionOverlay {
  final BuildContext context;
  final QuillController controller;
  final RenderEditor renderObject;
  final Widget debugRequiredFor;
  final TextEditingValue textEditingValue;
  final void Function(String, String, String) onSelected;
  final MentionSuggestionWidgetBuilder overlayBuilder;
  OverlayEntry overlayEntry;

  MentionSuggestionOverlay({
    @required this.controller,
    @required this.textEditingValue,
    @required this.context,
    @required this.renderObject,
    @required this.debugRequiredFor,
    @required this.overlayBuilder,
    this.onSelected,
  });

  void showSuggestions() {
    overlayEntry = OverlayEntry(
      builder: (context) => _MentionSuggestionList(
        controller: controller,
        renderObject: renderObject,
        textEditingValue: textEditingValue,
        onSelected: onSelected,
        overlayBuilder: overlayBuilder,
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
  final MentionSuggestionWidgetBuilder overlayBuilder;

  const _MentionSuggestionList({
    Key key,
    @required this.controller,
    @required this.renderObject,
    @required this.textEditingValue,
    @required this.overlayBuilder,
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
    final listMaxWidth = editingRegion.width / 1.7;
    final screenHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;

    var positionFromTop = endpoints[0].point.dy + editingRegion.top;
    var positionFromRight = editingRegion.width - endpoints[0].point.dx;
    double positionFromLeft;

    if (positionFromTop + listMaxHeight > screenHeight) {
      positionFromTop = positionFromTop - listMaxHeight - baseLineHeight;
    }

    // print(
    //     'MentionSuggestionList - edit:${editingRegion.width}, max:$listMaxWidth - (r:$positionFromRight/l:$positionFromLeft)');

    if (positionFromRight + listMaxWidth > editingRegion.width) {
      positionFromRight = null;
      // positionFromLeft = endpoints[0].point.dx;
      positionFromLeft = positionFromRight;
    }

    return Positioned(
      top: positionFromTop,
      right: positionFromRight,
      left: positionFromLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: min(listMaxWidth, 215.0),
          maxHeight: listMaxHeight,
        ),
        child: overlayBuilder(context),
      ),
    );
  }
}
