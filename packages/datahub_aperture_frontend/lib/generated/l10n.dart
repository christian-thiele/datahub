// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `New {resourceName}`
  String newResource(Object resourceName) {
    return Intl.message(
      'New $resourceName',
      name: 'newResource',
      desc: '',
      args: [resourceName],
    );
  }

  /// `Saved!`
  String get resourceSaved {
    return Intl.message('Saved!', name: 'resourceSaved', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Value is required.`
  String get validationRequired {
    return Intl.message(
      'Value is required.',
      name: 'validationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Value must match the pattern: {expression}`
  String validationPattern(Object expression) {
    return Intl.message(
      'Value must match the pattern: $expression',
      name: 'validationPattern',
      desc: '',
      args: [expression],
    );
  }

  /// `Value too long. (> {length})`
  String validationMaxLength(Object length) {
    return Intl.message(
      'Value too long. (> $length)',
      name: 'validationMaxLength',
      desc: '',
      args: [length],
    );
  }

  /// `No file selected`
  String get emptyFile {
    return Intl.message(
      'No file selected',
      name: 'emptyFile',
      desc: '',
      args: [],
    );
  }

  /// `Save and Schedule`
  String get saveAndSchedule {
    return Intl.message(
      'Save and Schedule',
      name: 'saveAndSchedule',
      desc: '',
      args: [],
    );
  }

  /// `Save as Draft`
  String get saveAsDraft {
    return Intl.message(
      'Save as Draft',
      name: 'saveAsDraft',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message('Filter', name: 'filter', desc: '', args: []);
  }

  /// `No Elements`
  String get noElements {
    return Intl.message('No Elements', name: 'noElements', desc: '', args: []);
  }

  /// `Actions`
  String get actions {
    return Intl.message('Actions', name: 'actions', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Schedule Revision`
  String get scheduleRevision {
    return Intl.message(
      'Schedule Revision',
      name: 'scheduleRevision',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Live since`
  String get liveSince {
    return Intl.message('Live since', name: 'liveSince', desc: '', args: []);
  }

  /// `Live from`
  String get liveFrom {
    return Intl.message('Live from', name: 'liveFrom', desc: '', args: []);
  }

  /// `Timestamp`
  String get timestamp {
    return Intl.message('Timestamp', name: 'timestamp', desc: '', args: []);
  }

  /// `Revision Info`
  String get revisionInfo {
    return Intl.message(
      'Revision Info',
      name: 'revisionInfo',
      desc: '',
      args: [],
    );
  }

  /// `Version #`
  String get revisionVersion {
    return Intl.message(
      'Version #',
      name: 'revisionVersion',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get author {
    return Intl.message('Author', name: 'author', desc: '', args: []);
  }

  /// `Revision History`
  String get revisionHistory {
    return Intl.message(
      'Revision History',
      name: 'revisionHistory',
      desc: '',
      args: [],
    );
  }

  /// `by {userName}`
  String byUsername(Object userName) {
    return Intl.message(
      'by $userName',
      name: 'byUsername',
      desc: '',
      args: [userName],
    );
  }

  /// `Draft`
  String get draft {
    return Intl.message('Draft', name: 'draft', desc: '', args: []);
  }

  /// `Refresh`
  String get refresh {
    return Intl.message('Refresh', name: 'refresh', desc: '', args: []);
  }

  /// `Resource Deleted.`
  String get resourceDeleted {
    return Intl.message(
      'Resource Deleted.',
      name: 'resourceDeleted',
      desc: '',
      args: [],
    );
  }

  /// `File selected`
  String get fileSelected {
    return Intl.message(
      'File selected',
      name: 'fileSelected',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Delete scheduled`
  String get deleteScheduled {
    return Intl.message(
      'Delete scheduled',
      name: 'deleteScheduled',
      desc: '',
      args: [],
    );
  }

  /// `Login via IDP`
  String get loginAuthcode {
    return Intl.message(
      'Login via IDP',
      name: 'loginAuthcode',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Revert`
  String get revert {
    return Intl.message('Revert', name: 'revert', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
