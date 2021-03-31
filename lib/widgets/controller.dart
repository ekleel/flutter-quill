import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/models/documents/nodes/embed.dart';
import 'package:flutter_quill/models/documents/style.dart';
import 'package:flutter_quill/models/quill_delta.dart';
import 'package:flutter_quill/utils/diff_delta.dart';
import 'package:tuple/tuple.dart';

class QuillController<MS> extends ChangeNotifier {
  final Document document;
  TextSelection selection;
  Style toggledStyle = Style();

  QuillController({
    @required this.document,
    @required this.selection,
    List<String> mentionTriggers,
  })  : _mentionTriggers = mentionTriggers ?? [],
        assert(document != null),
        assert(selection != null);

  factory QuillController.basic() {
    return QuillController(document: Document(), selection: TextSelection.collapsed(offset: 0));
  }

  // item1: Document state before [change].
  //
  // item2: Change delta applied to the document.
  //
  // item3: The source of this change.
  Stream<Tuple3<Delta, Delta, ChangeSource>> get changes => document.changes;

  TextEditingValue get plainTextEditingValue => TextEditingValue(
        text: document.toPlainText(),
        selection: selection,
        composing: TextRange.empty,
      );

  Style getSelectionStyle() {
    return document.collectStyle(selection.start, selection.end - selection.start).mergeAll(toggledStyle);
  }

  void undo() {
    Tuple2 tup = document.undo();
    if (tup.item1) {
      _handleHistoryChange(tup.item2);
    }
  }

  void _handleHistoryChange(int len) {
    if (len != 0) {
      final pLen = -len;
      if (this.selection.extentOffset >= document.length) {
        // cursor exceeds the length of document, position it in the end
        updateSelection(TextSelection.collapsed(offset: document.length), ChangeSource.LOCAL);
      } else {
        updateSelection(
          TextSelection.collapsed(
              offset: this.selection.baseOffset < pLen ? this.selection.baseOffset : this.selection.baseOffset + len),
          ChangeSource.LOCAL,
        );
      }
    } else {
      // no need to move cursor
      notifyListeners();
    }
  }

  void redo() {
    Tuple2 tup = document.redo();
    if (tup.item1) {
      _handleHistoryChange(tup.item2);
    }
  }

  get hasUndo => document.hasUndo;

  get hasRedo => document.hasRedo;

  replaceText(int index, int len, Object data, TextSelection textSelection) {
    assert(data is String || data is Embeddable);

    Delta delta;
    if (len > 0 || data is! String || (data as String).isNotEmpty) {
      delta = document.replace(index, len, data);
      bool shouldRetainDelta = toggledStyle.isNotEmpty && delta.isNotEmpty && delta.length <= 2 && delta.last.isInsert;
      if (shouldRetainDelta && toggledStyle.isNotEmpty && delta.length == 2 && delta.last.data == '\n') {
        // if all attributes are inline, shouldRetainDelta should be false
        final anyAttributeNotInline = toggledStyle.values.any((attr) => !attr.isInline);
        if (!anyAttributeNotInline) {
          shouldRetainDelta = false;
        }
      }
      if (shouldRetainDelta) {
        Delta retainDelta = Delta()..retain(index)..retain(data is String ? data.length : 1, toggledStyle.toJson());
        document.compose(retainDelta, ChangeSource.LOCAL);
      }
    }

    toggledStyle = Style();
    if (textSelection != null) {
      if (delta == null || delta.isEmpty) {
        _updateSelection(textSelection, ChangeSource.LOCAL);
      } else {
        Delta user = Delta()
          ..retain(index)
          ..insert(data)
          ..delete(len);
        int positionDelta = getPositionDelta(user, delta);
        _updateSelection(
          textSelection.copyWith(
            baseOffset: textSelection.baseOffset + positionDelta,
            extentOffset: textSelection.extentOffset + positionDelta,
          ),
          ChangeSource.LOCAL,
        );
      }
    }
    _checkForMentionTriggers();
    notifyListeners();
  }

  formatText(int index, int len, Attribute attribute) {
    if (len == 0 && attribute.isInline && attribute.key != Attribute.link.key) {
      toggledStyle = toggledStyle.put(attribute);
    }

    Delta change = document.format(index, len, attribute);
    TextSelection adjustedSelection = selection.copyWith(
        baseOffset: change.transformPosition(selection.baseOffset),
        extentOffset: change.transformPosition(selection.extentOffset));
    if (selection != adjustedSelection) {
      _updateSelection(adjustedSelection, ChangeSource.LOCAL);
    }
    _checkForMentionTriggers();
    notifyListeners();
  }

  formatSelection(Attribute attribute) {
    formatText(selection.start, selection.end - selection.start, attribute);
  }

  updateSelection(TextSelection textSelection, ChangeSource source) {
    _updateSelection(textSelection, source);
    notifyListeners();
  }

  compose(Delta delta, TextSelection textSelection, ChangeSource source) {
    if (delta.isNotEmpty) {
      document.compose(delta, source);
    }
    if (textSelection != null) {
      _updateSelection(textSelection, source);
    } else {
      textSelection = selection.copyWith(
          baseOffset: delta.transformPosition(selection.baseOffset, force: false),
          extentOffset: delta.transformPosition(selection.extentOffset, force: false));
      if (selection != textSelection) {
        _updateSelection(textSelection, source);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    document.close();
    super.dispose();
  }

  _updateSelection(TextSelection textSelection, ChangeSource source) {
    assert(textSelection != null);
    assert(source != null);
    selection = textSelection;
    int end = document.length - 1;
    selection = selection.copyWith(
        baseOffset: math.min(selection.baseOffset, end), extentOffset: math.min(selection.extentOffset, end));
    // _checkForMentionTriggers();
  }

  final List<String> _mentionTriggers;
  List<MS> _mentionSuggestions = [];
  bool _isInMentionMode = false;
  bool _isMentionLoading = false;
  String _mentionedText;
  String _mentionTrigger;

  bool get isInMentionMode => _isInMentionMode;
  bool get isMentionLoading => _isMentionLoading;
  List<MS> get mentionSuggestions => _mentionSuggestions;
  String get mentionTrigger => _mentionTrigger;
  String get mentionedText => _mentionedText;

  bool get hasMention => isInMentionMode && mentionTrigger != null && mentionedText != null;

  void updateMentionSuggestions(List<MS> suggestions) {
    _mentionSuggestions = suggestions ?? [];
    notifyListeners();
  }

  void toggleMentionLoading(bool value) {
    _isMentionLoading = value;
    notifyListeners();
  }

  void updateMention(String trigger, String value) {
    _isInMentionMode = true;
    _mentionTrigger = trigger;
    _mentionedText = value;
    notifyListeners();
  }

  void addMention(Attribute attribute, String replacement) {
    final mentionStartIndex = selection.end - mentionedText.length - 1;
    final mentionedTextLength = mentionedText.length + 1;
    final replacementText = mentionTrigger + replacement + ' ';

    replaceText(
      mentionStartIndex,
      mentionedTextLength,
      replacementText,
      TextSelection.collapsed(
        offset: mentionStartIndex + replacementText.length,
      ),
    );
    formatText(
      mentionStartIndex,
      replacementText.length - 1,
      attribute,
    );

    resetMention();
  }

  void resetMention() {
    _isInMentionMode = false;
    _isMentionLoading = false;
    _mentionSuggestions = [];
    _mentionTrigger = null;
    _mentionedText = null;
    notifyListeners();
  }

  /// Checks if collapsed cursor is after a mention trigger
  /// which isn't submitted yet
  void _checkForMentionTriggers() {
    resetMention();

    if (_mentionTriggers.isEmpty || !selection.isCollapsed) {
      return;
    }

    final plainText = document.toPlainText();
    final indexOfLastMentionTrigger = plainText.substring(0, selection.end).lastIndexOf(
          RegExp(_mentionTriggers.join('|')),
        );

    if (indexOfLastMentionTrigger < 0) {
      return;
    }

    if (plainText.substring(indexOfLastMentionTrigger, selection.end).contains(RegExp(r'\n'))) {
      return;
    }

    final isMentionSubmitted = document.collectStyle(indexOfLastMentionTrigger, 0);
    if (isMentionSubmitted.keys.contains(Attribute.mention.key)) {
      return;
    }

    updateMention(
      plainText.substring(indexOfLastMentionTrigger, indexOfLastMentionTrigger + 1),
      plainText.substring(indexOfLastMentionTrigger + 1, selection.end),
    );
  }
}
