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

const DELTA_SAMPLE = [
  {
    "insert":
        "البُن (الاسم العلمي: Coffea) هو جنس من النباتات يتبع الفصيلة الفوية من رتبة الجنطيانيات. والبن شجرة دائمة الخضرة ذات ثمار حمراء اللون في حالة نضجها، وتحتوي على مكونات قد تكون ضارة بالصحة مثل الكافيين. غير أن إحدى أحدث الأبحاث العلمية أشارت إلى انخفاض في نسبة المصابين بالنوع الثاني من داء السكري بين الذين يتناولون القهوة، وبالأخص القهوة منزوعة الكافيين. كما أن له تأثيرات سلبية سيئة على الذاكرة المؤقتة، فقد نشرت إذاعة بي بي سي على موقعها بتاريخ 20 يوليو 2004 خبر دراسة من المدرسة الدولية للدراسات المتقدمة في إيطاليا يقول بأن الكافيين يمكن أن يعيق الذاكرة المؤقتة وتذكر بعض الأسماء. لذلك يشار للطلاب باجتناب شرب القهوة والشاي والكوكا وغيرها من الأشياء المحتوية على مادة الكافيين دائماً وخاصة أيام الامتحانات.\n"
  },
  {
    "insert": {"divider": true}
  },
  {
    "insert": {
      "image": {"nid": "1y8FVAEzn#un(_wkd7XBRfU4)", "user": "9ukEt3oZUGUdzHz2JhElKKkGuw42", "dims": null}
    }
  },
  {"insert": "شجرة البن"},
  {
    "insert": "\n",
    "attributes": {"h2": true}
  },
  {
    "insert":
        "تنمو شجرة البن طبيعياً في المناخ الاستوائي الذي يكون حاراً رطباً في موسم النمو، وحاراً جافاً في موسم القطاف.\nالقهوة بالعربية هي كل ما يشرب على مهل وبعد اكتشاف البن انحسر الاسم على المشروب المصنوع من البن. أما الاسم كافي فقد أتى من اسم مكتشف القهوة أو من اكتشفها والذي سمي المشروب باسمه بادِئ الأمر وهو الشيخ الصوفي الكاف وكانت تسمى قهوة الكاف وحينما أتى البرتغاليون لليمن واحتلوا المكلا وعدن وجدوا المشروب فحملوه للعالم وباسمه الأصلي مع تحريفات بسيطة.\n"
  },
  {
    "insert": {"divider": true}
  },
  {"insert": "القهوة من راعي الغنم إلى الكاباتشينو"},
  {
    "insert": "\n",
    "attributes": {"h2": true}
  },
  {
    "insert":
        "تُروى حكاية قديمة عن أن راعياً فُوجئ بغنمه، وقد اعترتها حالة غير عادية من الحيوية والنشاط، عندما أكلت من شجيرة معينة. لم يستغرق الأمر من الراعي وقتا طويلا حتى قرر أن يتناول هو الآخر بعضاً من هذه البذور؛ ليجربها بنفسه، ويكتشف الأثر الواضح لزيادة نشاطه وحيويته، وكان هذا سبباً في اكتشاف شجرة البن التي يُصنع منها مشروب القهوة، الذي يعد من أكثر المشروبات انتشارا واستهلاكا في العالم. وقد قيل أن أول من اهتدى إليها هو أبو بكر بن عبد الله العيدروس وكان أصل اتخاذه لهذه البذرة أنه مر في أحد سياحاته (وقد كان صوفيا) بشجرة فأكل من ثمرها حين رآه متروكاً لا ينتفع به أحد مع كثرته فوجد به تجفيفا للدماغ واجتلاباً للسهر وتنشيطاً للعبادة فاتخذه قوتاً وشراباً وطعاماً وأرشد أتباعه إليه ثم نشر ذلك في الحجاز واليمن ومصر.\n"
  },
  {
    "insert": {
      "image": {"nid": "jhydlb@0I#un(fANEvguCIXE)", "user": "9ukEt3oZUGUdzHz2JhElKKkGuw42", "dims": null}
    }
  },
  {"insert": "أنواع القهوة"},
  {
    "insert": "\n",
    "attributes": {"h2": true}
  },
  {
    "insert": "القهوة العربية",
    "attributes": {"bold": true}
  },
  {
    "insert":
        ": قهوة خفيفة التركيز توضع فيها حبات الهيل والبهار أو البزار المستخدم لإضافة نكهة ورائحة زكية ومميزة عند أهل البادية والحضر من العرب عامة وأهل الخليج خاصة، والتي تكون قهوتهم صفراء مائلة للّون البني الذهبي وهناك القهوة الشماليّة الغامقة اللون والأكثر تركيزاً التي تعتبر قهوة أهل العراق وبلاد الشام، وعادة تكون مرة وليس فيها سكر أبداً، وتقدم في فنجان يختلف عن فنجان القهوة المتعارف عليه في تركيا وأوروبا حيث يكون فمه أوسع من قاعدته وتقدم به القهوة بحيث لا تملأ إلا نصفه على أكثر تقدير."
  },
  {
    "insert": "\n",
    "attributes": {"list": "bullet"}
  },
  {
    "insert": "القهوة الأمريكية",
    "attributes": {"bold": true}
  },
  {"insert": ": تطلق على قهوة الفلتر مجازاً. وهي تصنع غالباً من حبات القهوة الكولومبية."},
  {
    "insert": "\n",
    "attributes": {"list": "bullet"}
  },
  {
    "insert": "القهوة التركية",
    "attributes": {"bold": true}
  },
  {
    "insert":
        ": هي قهوة ثقيلة غامقة، تصنع على الأغلب من حبات القهوة البرازيلية. تطحن بدرجة ناعمة جداً وتختلف في درجة تحضيرها بغليها جيداً أو الغلي السريع. تقدم في فنجان صغير بيد مع صحن صغير، وتعتبر فناجين القهوة التركية الأكثر شهرة واستخداما وتتميز بزخرفتها، كما يقدم معها السكر بدرجات متفاوتة حسب الرغبة."
  },
  {
    "insert": "\n",
    "attributes": {"list": "bullet"}
  },
  {
    "insert": {"video": "https://www.youtube.com/embed/YIHBJE4llnY?showinfo=0"}
  },
  {"insert": "هذه القصة معاينة لمحرر \"كلمة\". المصدر: "},
  {
    "insert": "ويكيبيدا",
    "attributes": {"link": "https://ar.wikipedia.org/wiki/%D8%A8%D9%86"}
  },
  {
    "insert": "\n",
    "attributes": {"blockquote": true}
  }
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
      final doc = Document.fromJson(DELTA_SAMPLE);
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
              textSelectionControls: materialTextSelectionControls,
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
