class Embeddable {
  final String type;
  final dynamic data;

  Embeddable(this.type, this.data)
      : assert(type != null),
        assert(data != null);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = {type: data};
    return m;
  }

  static Embeddable fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> m = Map<String, dynamic>.from(json);
    assert(m.length == 1, 'Embeddable map has one key');

    return BlockEmbed(m.keys.first, m.values.first);
  }
}

class BlockEmbed extends Embeddable {
  BlockEmbed(String type, dynamic data) : super(type, data);

  static final BlockEmbed horizontalRule = BlockEmbed('divider', 'hr');

  static BlockEmbed image(dynamic imageUrl) => BlockEmbed('image', imageUrl);
}
