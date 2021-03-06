import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/models/documents/nodes/embed.dart';
import 'package:flutter_quill/models/documents/nodes/leaf.dart' as leaf;
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/default_styles.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';

import 'read_only_page.dart';

Widget defaultEmbedBuilder(BuildContext context, leaf.Embed embed) {
  switch (embed.value.type) {
    // case 'video':
    //   return EditorVideo(id: 'bczyP-kDwSA');
    //   break;
    default:
      return Text('مرفق! ${embed.value.type}');
  }
}

const QUILL_TO_ZEFYR_COMPLEX_JSON_3 = [
  {
    "insert":
        "السلام عليكم ورحمة الله وبركاته،\nبعد طرح نسخة 1.0.8 عملنا بجهد على تحسين تجربة استخدام تطبيق كلمة على نظامي iOS و Android لضمان تجربة استخدام مستقرة وآمنة. قمنا خلال هذه الفترة بتحسين آداء التطبيق خصوصاً للأجهزة ذات الاصدارات القديمة.\nكما بدأنا بالعمل على الخطوات الأساسية لدعم منصات إضافية وأهمها macOS و Windows في خطوة توسع للمنصات المدعومة من قبل تطبيقات كلمة لتتمكن من الاستمتاع بكتابة قصصك من خلال الويب وكل من أنظمة iOS - Android - macOS - Windows.\nوفي هذه النسخة بالتحديد قمنا بإضافة عدد من المميزات الجديدة  وإليكم أهمها:\n"
  },
  {
    "insert": {"divider": "true"}
  },
  {"insert": "دعم iPad و الأجهزة اللوحية"},
  {
    "insert": "\n",
    "attributes": {"header": 2}
  },
  {"insert": "دعم iPad و الأجهزة اللوحية"},
  {
    "insert": "\n",
    "attributes": {"h2": true}
  },
  {
    "insert": {
      // "image":
      //     "https://images.unsplash.com/photo-1614750281988-b6cba453da50?ixid=MXwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwyfHx8ZW58MHx8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
      "image": {
        "nid": "a7yFQYViv#up",
        "user": "dYsxj0xN8hMubzQP0gDFwJ3BYUC3",
        "dims": "{\"width\":2000.0,\"height\":2000.0,\"aspectRatio\":1.0}"
      }
    }
  },
  {
    "insert":
        "الآن يمكنك الاستمتاع بكتابة قصصك وقراءة قصص كتابك المفضلين من خلال أجهزة iPad وأجهزة Android اللوحية من خلال تجربة استخدام مصممة خصيصاً للشاشة الكبيرة والتي تسمح لك بوصول أسرع لقصصك وكتابة أكثر راحة.\n"
  },
  {
    "insert": {"divider": "true"}
  },
  {"insert": "الثيم الداكن"},
  {
    "insert": "\n",
    "attributes": {"header": 2}
  },
  {'insert': '\n'},
  {
    "insert": {"tweet": "1282747519626350592"}
  },
  {'insert': '\n'},
  {
    "insert": {"video": "https://www.youtube.com/embed/bczyP-kDwSA"}
  },
  {
    "insert":
        "في هذا التحديث قمنا بطرح خاصية أخرى لضمان تجربة استخدام أروع وقراءة أكثر راحة على كلمة، فيمكنك تغيير نمط الألوان للون "
  },
  {
    "insert": "الداكن",
    "attributes": {"bold": true}
  },
  {
    "insert":
        " للاستمتاع بالقراءة بعيداً عن تشتيت الإضاءة العالية والألوان الساطعة.\nلتغيير نمط الألوان كل ماعليك فعله التوجه إلى صفحة الإعدادات وتحديد خيارات المظهر واختيار النمط المناسب لك. كما يمكنك تحديد الخيار التلقائي ليتم تحديد نمط الألوان بناءً على إعدادات الهاتف.\n"
  },
  {
    "insert": {"divider": "true"}
  },
  {"insert": "تحديثات أخرى"},
  {
    "insert": "\n",
    "attributes": {"header": 2}
  },
  {"insert": "تم إصلاح مشكلة تحديد النص للنسخ واللصق والتي كانت تظهر في محرر القصص."},
  {
    "insert": "\n",
    "attributes": {"list": "bullet"}
  },
  {"insert": "تم إصلاح مشكلة عدم ظهور الردود من أول زيارة."},
  {
    "insert": "\n",
    "attributes": {"list": "bullet"}
  },
  {"insert": "تم إضافة خاصية لتغيير حجم النصوص لضمان تجربة قراءة أفضل."},
  {
    "insert": "\n",
    "attributes": {"list": "bullet"}
  },
  {"insert": " تم تغيير آلية اقتصاص الصور وتقديم واجهة أبسط للاستخدام."},
  {
    "insert": "\n",
    "attributes": {"list": "bullet"}
  },
  {"insert": "كما قمنا  بحل عشرات المشاكل التي تم الإبلاغ عنها من قبل الأعضاء ولهم جزيل الشكر 🌹.\n"},
  {
    "insert": {"divider": "true"}
  },
  {"insert": "عندك خاصيّة ترى أنها مناسبة لكلمة؟ شاركها مع فريقنا على help@kilma.app أو بالرد على هذه القصة!"},
  {
    "insert": "\n",
    "attributes": {"blockquote": true}
  },
  {"insert": "مع التحية، فريق كلمة."},
  {
    "insert": "\n",
  },
];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QuillController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadFromAssets();
  }

  Future<void> _loadFromAssets() async {
    try {
      // final result = await rootBundle.loadString('assets/sample_data.json');
      // final doc = Document.fromJson(jsonDecode(result));
      final doc = Document.fromJson(QUILL_TO_ZEFYR_COMPLEX_JSON_3);
      setState(() {
        _controller = QuillController(document: doc, selection: TextSelection.collapsed(offset: 0));
      });
    } catch (error) {
      print('error: $error');
      final doc = Document()..insert(0, 'Empty asset');
      setState(() {
        _controller = QuillController(document: doc, selection: TextSelection.collapsed(offset: 0));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Scaffold(body: Center(child: Text('Loading...')));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Flutter Quill',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              final delta = _controller.document.toDelta();
              final json = delta.toJson();
              await Clipboard.setData(
                ClipboardData(text: jsonEncode(json)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.image),
            onPressed: () {
              final index = _controller.selection.baseOffset;
              final length = _controller.selection.extentOffset - index;
              _controller.replaceText(
                index,
                length,
                BlockEmbed('video', {
                  'source': 'https://www.youtube.com/embed/bczyP-kDwSA',
                }),
                null,
              );
            },
          ),
        ],
      ),
      drawer: Material(
        color: Colors.grey.shade800,
        child: _buildMenuBar(context),
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event.data.isControlPressed && event.character == 'b') {
            if (_controller.getSelectionStyle().attributes.keys.contains("bold")) {
              _controller.formatSelection(Attribute.clone(Attribute.bold, null));
            } else {
              _controller.formatSelection(Attribute.bold);
              print("not bold");
            }
          }
        },
        child: _buildWelcomeEditor(context),
      ),
    );
  }

  Widget _buildWelcomeEditor(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.88,
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: QuillEditor(
              controller: _controller,
              scrollController: ScrollController(),
              scrollable: true,
              focusNode: _focusNode,
              autoFocus: false,
              readOnly: false,
              placeholder: 'Add content',
              enableInteractiveSelection: true,
              expands: false,
              padding: EdgeInsets.zero,
              embedBuilder: defaultEmbedBuilder,
              onTap: (details, segment) {
                if (segment.value is BlockEmbed) {
                  final embed = segment.value as BlockEmbed;
                  print('onTap embed: ${embed.data}');
                }
              },
              customStyles: DefaultStyles(
                h1: DefaultTextBlockStyle(
                  TextStyle(
                    fontSize: 25.0,
                    color: Colors.black,
                    height: 1.15,
                    fontWeight: FontWeight.w300,
                  ),
                  Tuple2(16.0, 0.0),
                  Tuple2(0.0, 0.0),
                  null,
                ),
                h2: DefaultTextBlockStyle(
                  TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    height: 1.15,
                    fontWeight: FontWeight.w300,
                  ),
                  Tuple2(16.0, 0.0),
                  Tuple2(0.0, 0.0),
                  null,
                ),
                sizeSmall: TextStyle(fontSize: 9.0),
                quote: DefaultTextBlockStyle(
                  TextStyle(
                    // fontSize: 20.0,
                    color: Colors.black,
                    height: 1.15,
                    fontWeight: FontWeight.w300,
                  ),
                  Tuple2(12.0, 12.0),
                  Tuple2(12.0, 12.0),
                  BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: QuillToolbar.basic(
              controller: _controller,
              onImagePickCallback: _onImagePickCallback,
              showHorizontalRule: true,
            ),
          ),
        ],
      ),
    );
  }

  // Renders the image picked by imagePicker from local file storage
  // You can also upload the picked image to any server (eg : AWS s3 or Firebase) and then return the uploaded image URL
  Future<String> _onImagePickCallback(File file) async {
    if (file == null) return null;
    // Copies the picked file from temporary cache to applications directory
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File copiedFile = await file.copy('${appDocDir.path}/${basename(file.path)}');
    return copiedFile.path.toString();
  }

  Widget _buildMenuBar(BuildContext context) {
    final itemStyle = TextStyle(color: Colors.white);
    return ListView(
      children: [
        ListTile(
          title: Text('Read only demo', style: itemStyle),
          dense: true,
          visualDensity: VisualDensity.compact,
          onTap: _readOnly,
        )
      ],
    );
  }

  void _readOnly() {
    Navigator.push(
      super.context,
      MaterialPageRoute(
        builder: (BuildContext context) => ReadOnlyPage(),
      ),
    );
  }
}
