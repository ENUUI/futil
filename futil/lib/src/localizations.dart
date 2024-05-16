import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ChineseCupertinoLocalizations implements CupertinoLocalizations {
  final materialDelegate = GlobalMaterialLocalizations.delegate;
  final widgetsDelegate = GlobalWidgetsLocalizations.delegate;
  final local = const Locale('zh');

  late MaterialLocalizations ml;

  Future init() async {
    ml = await materialDelegate.load(local);
    if (kDebugMode) {
      print(ml.pasteButtonLabel);
    }
  }

  @override
  String get alertDialogLabel => ml.alertDialogLabel;

  @override
  String get anteMeridiemAbbreviation => ml.anteMeridiemAbbreviation;

  @override
  String get copyButtonLabel => ml.copyButtonLabel;

  @override
  String get cutButtonLabel => ml.cutButtonLabel;

  @override
  DatePickerDateOrder get datePickerDateOrder => DatePickerDateOrder.ymd;

  @override
  DatePickerDateTimeOrder get datePickerDateTimeOrder => DatePickerDateTimeOrder.date_time_dayPeriod;

  @override
  String datePickerMonth(int monthIndex) {
    return '${monthIndex.toString().padLeft(2, '0')}月';
  }

  @override
  String datePickerYear(int yearIndex) {
    return '$yearIndex' '年';
  }

  @override
  String datePickerHour(int hour) {
    return hour.toString().padLeft(2, '0');
  }

  @override
  String datePickerHourSemanticsLabel(int hour) {
    return '$hour' '时';
  }

  @override
  String datePickerMediumDate(DateTime date) {
    return ml.formatMediumDate(date);
  }

  @override
  String datePickerMinute(int minute) {
    return minute.toString().padLeft(2, '0');
  }

  @override
  String datePickerMinuteSemanticsLabel(int minute) {
    return '$minute' '分';
  }

  @override
  String get pasteButtonLabel => ml.pasteButtonLabel;

  @override
  String get postMeridiemAbbreviation => ml.postMeridiemAbbreviation;

  @override
  String get selectAllButtonLabel => ml.selectAllButtonLabel;

  @override
  String timerPickerHour(int hour) {
    return hour.toString();
  }

  @override
  String timerPickerHourLabel(int hour) {
    return '小时';
  }

  @override
  String timerPickerMinute(int minute) {
    return minute.toString();
  }

  @override
  String timerPickerMinuteLabel(int minute) {
    return '分钟';
  }

  @override
  String timerPickerSecond(int second) {
    return second.toString();
  }

  @override
  String timerPickerSecondLabel(int second) {
    return '秒';
  }

  static const LocalizationsDelegate<CupertinoLocalizations> delegate = _ChineseDelegate();

  static Future<CupertinoLocalizations> load(Locale locale) async {
    var localizaltions = ChineseCupertinoLocalizations();
    await localizaltions.init();
    return SynchronousFuture<CupertinoLocalizations>(localizaltions);
  }

  @override
  String get todayLabel => '今天';

  @override
  String get modalBarrierDismissLabel => '关闭';

  @override
  String tabSemanticsLabel({required int tabIndex, required int tabCount}) {
    return 'Tab $tabIndex of $tabCount';
  }

  @override
  String get searchTextFieldPlaceholderLabel => '搜索';

  @override
  List<String> get timerPickerHourLabels => const <String>['小时'];

  @override
  List<String> get timerPickerMinuteLabels => const <String>['分钟'];

  @override
  List<String> get timerPickerSecondLabels => const <String>['秒'];

  @override
  String datePickerDayOfMonth(int dayIndex, [int? weekDay]) {
    return '${dayIndex.toString().padLeft(2, '0')}日';
  }

  @override
  String get noSpellCheckReplacementsLabel => '';

  @override
  String datePickerStandaloneMonth(int monthIndex) {
    return '${monthIndex + 1}月';
  }

  @override
  String get lookUpButtonLabel => '查看';

  @override
  String get menuDismissLabel => '取消';

  @override
  String get searchWebButtonLabel => '搜索';

  @override
  String get shareButtonLabel => '分享';

  @override
  String get clearButtonLabel => '清除';
}

class _ChineseDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _ChineseDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'zh';
  }

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return ChineseCupertinoLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<CupertinoLocalizations> old) {
    return false;
  }
}
