import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nima/nima_actor.dart';

import 'common/common.dart';
import 'common/criterias.dart';
import 'criterias_screen/criterias_page.dart';
import 'generated/codegen_loader.g.dart';

void main() async {
  runApp(EasyLocalization(
    child: MyApp(),
    supportedLocales: [const Locale('en'), const Locale('fr')],
    fallbackLocale: const Locale('en'),
    saveLocale: false,
    path: 'resources/langs',
    assetLoader: const CodegenLoader(),
    useOnlyLangCode: true,
  ));

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: MaterialApp(
        title: 'Carbon+',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: warmdGreen,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.blueGrey[900],
          sliderTheme: SliderTheme.of(context).copyWith(
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
        ),
        home: Builder(
          builder: (context) {
            return ChangeNotifierProvider(
              create: (_) => CriteriasState(context),
              child: CriteriasPage(),
            );
          },
        ),
      ),
    );
  }
}
