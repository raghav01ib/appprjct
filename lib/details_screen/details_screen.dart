import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/common.dart';
import '../common/criterias.dart';
import '../generated/locale_keys.g.dart';

class DetailsScreen extends StatelessWidget {
  final CriteriasState _state;

  DetailsScreen(this._state, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var temp = <String, double>{};
    for (var cat in _state.categorySet.categories) {
      if (cat.co2EqTonsPerYear() > 0) {
        temp.putIfAbsent(
            '${cat.title} (${cat.co2EqTonsPerYear().toStringAsFixed(1)}t)',
            () => cat.co2EqTonsPerYear().toDouble());
      }
    }
    final dataMap = temp.sort((a, b) => -a.value.compareTo(b.value));

    var footprint = _state.categorySet.getFormatedFootprint();

    return Scaffold(
      appBar: AppBar(
        title: const Image(
          height: 64,
          image: AssetImage('assets/text_logo_transparent_small.webp'),
          fit: BoxFit.contain,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Theme(
            data: ThemeData.light(),
            child: Builder(
              builder: (context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (dataMap.isNotEmpty)
                      _buildHeader(context, footprint, dataMap),
                    if (dataMap.isNotEmpty)
                      _buildCountriesCard(context),
                    _buildObjectivesCard(context),
//
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, String footprint, Map<String, double> dataMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            LocaleKeys.footprintRepartitionTitle.tr(args: [footprint]),
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(color: Colors.white),
          ),
        ),
        PieChart(
          dataMap: dataMap,
        ),
        Gaps.h16,
      ],
    );
  }

  Card _buildCountriesCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.otherCountriesComparaisonTitle.tr(),
              style: _buildTitleStyle(context),
            ),
            Gaps.h16,
            _buildCountriesDataTable(context),
            Gaps.h32,
            buildSmartText(context, LocaleKeys.otherCountriesMore.tr())
          ],
        ),
      ),
    );
  }

  Card _buildObjectivesCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.globalObjectivesTitle.tr(),
              style: _buildTitleStyle(context),
            ),
            Gaps.h16,
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: LocaleKeys.globalObjectivesPart1.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontWeight: FontWeight.w300),
                  ),
                  TextSpan(
                    text: LocaleKeys.globalObjectivesPart2.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: LocaleKeys.globalObjectivesPart3.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontWeight: FontWeight.w300),
                  ),
                  TextSpan(
                    text: LocaleKeys.globalObjectivesPart4.tr(),
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Colors.blue[400],
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w300,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch(
                            'https://www.ipcc.ch/site/assets/uploads/sites/2/2019/03/ST1.5_final_310119.pdf');
                      },
                  ),
                  TextSpan(
                    text: LocaleKeys.globalObjectivesPart5.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            Image(
              image: const AssetImage('assets/carbon_graph.webp'),
              fit: BoxFit.contain,
              height: 264,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountriesDataTable(BuildContext context) {
    final countriesList = _buildCountriesList(context);
    var rows = [
      for (String country in countriesList.keys)
        DataRow(cells: [
          DataCell(Text(country)),
          DataCell(Text(LocaleKeys.otherCountriesTonsValue
              .tr(args: [countriesList[country].toString()]))),
        ]),
    ];

    final yourCo2 = _state.categorySet.co2EqTonsPerYear();
    const yourTextStyle =
        TextStyle(color: warmdGreen, fontWeight: FontWeight.bold);
    final yourCell = DataRow(cells: [
      DataCell(Text('⮕ ${LocaleKeys.you.tr()}', style: yourTextStyle)),
      DataCell(Text(
          LocaleKeys.otherCountriesTonsValue
              .tr(args: [yourCo2.toStringAsFixed(1)]),
          style: yourTextStyle)),
    ]);

    var higherCountryIdx = countriesList.values
        .toList()
        .indexWhere((countryCo2) => countryCo2 < yourCo2);
    if (higherCountryIdx == -1) {
      rows.add(yourCell);
    } else {
      rows.insert(higherCountryIdx, yourCell);
    }

    return IgnorePointer(
      child: DataTable(
        columns: [
          DataColumn(
              label: Text(
            LocaleKeys.otherCountriesColumn1Title.tr(),
            style: Theme.of(context).textTheme.subtitle2,
          )),
          DataColumn(
              label: Text(
                LocaleKeys.otherCountriesColumn2Title.tr(),
                style: Theme.of(context).textTheme.subtitle2,
              ),
              numeric: true),
        ],
        rows: rows,
      ),
    );
  }

  List<Widget> _buildAdviceWidgets(BuildContext context) {
    var list = [
      for (CriteriaCategory cat in _state.categorySet.categories)
        ..._buildCategoryAdviceWidgets(context, cat),
    ];

    return list.length > 1
        ? list
        : [Text(LocaleKeys.noAdvicesExplanation.tr())];
  }

  List<Widget> _buildCategoryAdviceWidgets(
      BuildContext context, CriteriaCategory cat) {
    var list = [
      Gaps.h16,
      Text(
        cat.title,
        style: Theme.of(context)
            .textTheme
            .subtitle2
            .copyWith(fontWeight: FontWeight.bold),
      ),
      Gaps.h8,
      for (Criteria crit in cat.criterias)
        if (crit.advice() != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '• ${crit.advice()}',
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
            ),
          ),
      Gaps.h16,
    ];

    return list.length > 4 ? list : [];
  }

  TextStyle _buildTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.headline6.copyWith(
          color: warmdGreen,
        );
  }

  // coolclimate.org numbers..
  Map<String, int> _buildCountriesList(BuildContext context) {
    return {
      LocaleKeys.countryUSA.tr(): 54,
      LocaleKeys.countryCanada.tr(): 54,
      LocaleKeys.countryAustralia.tr(): 36,
      LocaleKeys.countrySaudiArabia.tr(): 35,
      LocaleKeys.countryUAE.tr(): 34,
      LocaleKeys.countryChina.tr(): 28,
      LocaleKeys.countryIsrael.tr(): 25,
      LocaleKeys.countrySouthKorea.tr(): 25,
      LocaleKeys.countryJapan.tr(): 23,
      LocaleKeys.countryGermany.tr(): 23,
      LocaleKeys.countrySouthAfrica.tr(): 23,
      LocaleKeys.countryRussia.tr(): 22,
      LocaleKeys.countryGreece.tr(): 20,
      LocaleKeys.countryUK.tr(): 19,
      LocaleKeys.countryNorway.tr(): 17,
      LocaleKeys.countryIndia.tr(): 16,
      LocaleKeys.countryFrance.tr(): 16,
      LocaleKeys.countryMexico.tr(): 16,
      LocaleKeys.countryBrasil.tr(): 15,
      LocaleKeys.countryEgypt.tr(): 14,
      LocaleKeys.countryVietnam.tr(): 13,
      LocaleKeys.countryMorocco.tr(): 13,
      LocaleKeys.countryPhilippines.tr(): 13,
      LocaleKeys.countryCongo.tr(): 13,
      LocaleKeys.countrySoudan.tr(): 12,
    };
  }
}
