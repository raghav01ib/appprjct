import 'package:flutter/material.dart';
import 'package:smart_text_view/smart_text_view.dart';
import 'package:url_launcher/url_launcher.dart';

class Gaps {
  static const Widget h4 = SizedBox(height: 4);
  static const Widget h8 = SizedBox(height: 8);
  static const Widget h16 = SizedBox(height: 16);
  static const Widget h24 = SizedBox(height: 24);
  static const Widget h32 = SizedBox(height: 32);
  static const Widget w4 = SizedBox(width: 4);
  static const Widget w8 = SizedBox(width: 8);
  static const Widget w16 = SizedBox(width: 16);
  static const Widget w24 = SizedBox(width: 24);
  static const Widget w32 = SizedBox(width: 32);
}

extension ListExtension<E> on List<E> {
  List<E> clone() => List.from(this);

  Iterable<T> mapIndexed<T>(T Function(int idx, E element) f) => asMap()
      .map(
        (idx, element) => MapEntry(
          idx,
          f(idx, element),
        ),
      )
      .values;
}

extension MapExtension<K, V> on Map<K, V> {
  Map<K, V> sort([int Function(MapEntry<K, V> a, MapEntry<K, V> b) compare]) {
    var entries = this.entries.toList();
    entries.sort(compare);
    return Map<K, V>.fromEntries(entries);
  }
}

const MaterialColor warmdGreen = MaterialColor(
  _warmdGreenPrimaryValue,
  <int, Color>{
    50: Color(_warmdGreenPrimaryValue),
    100: Color(_warmdGreenPrimaryValue),
    200: Color(_warmdGreenPrimaryValue),
    300: Color(_warmdGreenPrimaryValue),
    400: Color(_warmdGreenPrimaryValue),
    500: Color(_warmdGreenPrimaryValue),
    600: Color(_warmdGreenPrimaryValue),
    700: Color(_warmdGreenPrimaryValue),
    800: Color(_warmdGreenPrimaryValue),
    900: Color(_warmdGreenPrimaryValue),
  },
);
const int _warmdGreenPrimaryValue = 0xff41cd8c;

SmartText buildSmartText(BuildContext context, String text) {
  return SmartText(
    linkStyle: Theme.of(context).textTheme.bodyText2.copyWith(
          color: Colors.blue[500],
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w300,
        ),
    text: text,
    style: Theme.of(context)
        .textTheme
        .bodyText2
        .copyWith(fontWeight: FontWeight.w300),
    onOpen: (url) {
      launchUrl(url);
    },
  );
}

void launchUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  }
}
