// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static String m0(appTitle) =>
      "Bei der Anmeldung ist ein Fehler aufgetreten. Bitte kehren Sie zu ${appTitle} zurück und versuchen Sie es erneut.";

  static String m1(appTitle) =>
      "Sie können diese Seite jetzt schließen und zu ${appTitle} zurückkehren.";

  static String m2(userName) => "von ${userName}";

  static String m3(resourceName) => "${resourceName} hinzufügen";

  static String m4(elementName) =>
      "Sind Sie sicher, dass Sie Element \"${elementName}\" löschen möchten?";

  static String m5(length) => "Wert zu lang. (> ${length})";

  static String m6(expression) =>
      "Wert muss dem Muster entsprechen: ${expression}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "actions": MessageLookupByLibrary.simpleMessage("Aktionen"),
    "authCallbackErrorMessage": m0,
    "authCallbackErrorTitle": MessageLookupByLibrary.simpleMessage(
      "Anmeldung fehlgeschlagen",
    ),
    "authCallbackSuccessMessage": m1,
    "authCallbackSuccessTitle": MessageLookupByLibrary.simpleMessage(
      "Anmeldung erfolgreich",
    ),
    "author": MessageLookupByLibrary.simpleMessage("Autor"),
    "byUsername": m2,
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "caution": MessageLookupByLibrary.simpleMessage("Achtung"),
    "date": MessageLookupByLibrary.simpleMessage("Datum"),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "deleteScheduled": MessageLookupByLibrary.simpleMessage("Löschen planen"),
    "draft": MessageLookupByLibrary.simpleMessage("Entwurf"),
    "emptyFile": MessageLookupByLibrary.simpleMessage("Keine Datei ausgewählt"),
    "error": MessageLookupByLibrary.simpleMessage("Fehler"),
    "fileSelected": MessageLookupByLibrary.simpleMessage("Datei ausgewählt"),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "liveFrom": MessageLookupByLibrary.simpleMessage("Live ab"),
    "liveSince": MessageLookupByLibrary.simpleMessage("Live seit"),
    "login": MessageLookupByLibrary.simpleMessage("Anmelden"),
    "loginAuthcode": MessageLookupByLibrary.simpleMessage("Anmelden via IDP"),
    "newResource": m3,
    "noElements": MessageLookupByLibrary.simpleMessage("Keine Elemente"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "password": MessageLookupByLibrary.simpleMessage("Passwort"),
    "reallyDeleteElement": m4,
    "refresh": MessageLookupByLibrary.simpleMessage("Aktualisieren"),
    "resourceDeleted": MessageLookupByLibrary.simpleMessage(
      "Ressource gelöscht.",
    ),
    "resourceSaved": MessageLookupByLibrary.simpleMessage("Gespeichert!"),
    "revert": MessageLookupByLibrary.simpleMessage("Zurücksetzen"),
    "revisionHistory": MessageLookupByLibrary.simpleMessage("Revisionsverlauf"),
    "revisionInfo": MessageLookupByLibrary.simpleMessage(
      "Revisionsinformationen",
    ),
    "revisionVersion": MessageLookupByLibrary.simpleMessage("Version #"),
    "save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "saveAndSchedule": MessageLookupByLibrary.simpleMessage(
      "Speichern und planen",
    ),
    "saveAsDraft": MessageLookupByLibrary.simpleMessage(
      "Als Entwurf Speichern",
    ),
    "scheduleRevision": MessageLookupByLibrary.simpleMessage("Revision planen"),
    "search": MessageLookupByLibrary.simpleMessage("Suche"),
    "time": MessageLookupByLibrary.simpleMessage("Uhrzeit"),
    "timestamp": MessageLookupByLibrary.simpleMessage("Zeitstempel"),
    "username": MessageLookupByLibrary.simpleMessage("Benutzername"),
    "validationMaxLength": m5,
    "validationPattern": m6,
    "validationRequired": MessageLookupByLibrary.simpleMessage(
      "Wert ist erforderlich.",
    ),
  };
}
