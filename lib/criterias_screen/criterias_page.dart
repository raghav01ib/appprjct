import 'dart:ui';

import 'package:gradient_text/gradient_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../common/common.dart';
import '../common/criterias.dart';
import '../details_screen/details_screen.dart';
import '../generated/locale_keys.g.dart';
import 'earth_anim_controller.dart';

class CriteriasPage extends StatelessWidget {
  final String title;
  final _animController = EarthAnimController();

  CriteriasPage({this.title, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state = context.watch<CriteriasState>();
    _animController.score = state.categorySet.co2EqTonsPerYear().toInt();

    return _buildContent(context, state);
  }

  Scaffold _buildContent(BuildContext context, CriteriasState state) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, state),
            Expanded(
              child: ListView(
                  key: ValueKey(state.categorySet),
                  padding: const EdgeInsets.all(8.0),
                  scrollDirection: Axis.vertical,
                  children: [
                    ..._buildCategories(context, state),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 64, right: 64, bottom: 32),
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailsScreen(state)),
                          );
                        },
                        child: Text(LocaleKeys.seeResults.tr()),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    )
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CriteriasState state) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GradientText("Carbon+",
                gradient: LinearGradient(colors: [
                  Colors.deepPurple,
                  Colors.deepOrange,
                  Colors.pink
                ]),
                style: TextStyle(
                  fontSize: 62,
                  letterSpacing: 5,
                ),
                textAlign: TextAlign.center),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: Container(
                      height: 128,
                      width: 128,
                      child: FlareActor(
                        'assets/global_warming.flr',
                        controller: _animController,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.yourCarbonFootprint.tr(),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${state.categorySet.getFormatedFootprint()}',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                    Gaps.h8,
                    InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          LocaleKeys.knowMore.tr(),
                          style: const TextStyle(color: warmdGreen),
                        ),
                      ),
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailsScreen(state)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategories(BuildContext context, CriteriasState state) {
    return [
      for (CriteriaCategory cat in state.categorySet.categories)
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Theme(
            data: ThemeData(
              brightness: Brightness.light,
              primarySwatch: warmdGreen,
              sliderTheme: SliderTheme.of(context).copyWith(
                valueIndicatorTextStyle: const TextStyle(color: Colors.white),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              // Not using Card to avoid a small display issue with images
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.0),
                child: Container(
                  margin: const EdgeInsets.all(1.0),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Image(
                        image: AssetImage('assets/${cat.key}.webp'),
                        fit: BoxFit.cover,
                        height: 164,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 24.0, right: 24.0, bottom: 24.0),
                        child: Builder(
                          builder: (context) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (Criteria crit in cat.criterias)
                                  ..._buildCriteria(context, state, crit),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildCriteria(
      BuildContext context, CriteriasState state, Criteria c) {
    var unit = c.unit != null ? ' ' + c.unit : '';
    var valueWithUnit =
        NumberFormat.decimalPattern().format(c.currentValue.abs()).toString() +
            unit;

    return [
      Gaps.h32,
      Text(
        c.title,
        style: Theme.of(context).textTheme.subtitle1,
      ),
      if (c.labels != null)
        _buildDropdown(context, c, state)
      else
        _buildSlider(c, valueWithUnit, context, state),
      if (c.explanation != null)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: buildSmartText(context, c.explanation),
        ),
    ];
  }

  Widget _buildDropdown(
      BuildContext context, Criteria c, CriteriasState state) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: DropdownButton<int>(
            isExpanded: true,
            selectedItemBuilder: (BuildContext context) {
              return c.labels.map((String item) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                );
              }).toList();
            },
            value: c.currentValue.toInt(),
            underline: Container(),
            onChanged: (int value) {
              c.currentValue = value.toDouble();
              state.persist(c);
            },
            items: c.labels
                .mapIndexed((index, label) => DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        label,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .copyWith(color: _getDropdownTextColor(c, index)),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Color _getDropdownTextColor(Criteria c, int value) {
    if (c is UnitCriteria || c is MoneyChangeCriteria) return Colors.black;

    if (value == c.minValue) {
      return Colors.green;
    } else if (value == c.maxValue) {
      return Colors.orange;
    } else {
      return Colors.black;
    }
  }

  Widget _buildSlider(Criteria c, String valueWithUnit, BuildContext context,
      CriteriasState state) {
    return Row(
      children: [
        Icon(
          c.leftIcon,
          color: Colors.black54,
        ),
        Expanded(
          child: Slider(
            min: c.minValue,
            max: c.maxValue,
            divisions: (c.maxValue - c.minValue) ~/ c.step,
            label: c.labels != null
                ? c.labels[c.currentValue.toInt()]
                : c.currentValue != c.maxValue || c is CleanElectricityCriteria
                    ? valueWithUnit
                    : LocaleKeys.valueWithMore.tr(args: [valueWithUnit]),
            value: c.currentValue,
            onChanged: (double value) {
              c.currentValue = value;
              state.persist(c);
            },
          ),
        ),
        Icon(
          c.rightIcon,
          color: Colors.black54,
        ),
      ],
    );
  }
}
