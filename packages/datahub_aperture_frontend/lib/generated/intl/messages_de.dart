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

  static String m3(appTitle) => "Willkommen bei ${appTitle}";

  static String m4(count) => "${count} Felder";

  static String m5(resourceName) => "${resourceName} hinzufügen";

  static String m6(from, to) => "${from}–${to}";

  static String m7(from, to, total) => "${from}–${to} von ${total}";

  static String m8(elementName) =>
      "Sind Sie sicher, dass Sie Element \"${elementName}\" löschen möchten?";

  static String m9(line, column) =>
      "Ungültiges JSON (Zeile ${line}, Spalte ${column}).";

  static String m10(length) => "Wert zu lang. (> ${length})";

  static String m11(expression) =>
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
    "dashboardSubtitle": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie eine Ressource oder ein Modul, um loszulegen.",
    ),
    "dashboardTitle": m3,
    "date": MessageLookupByLibrary.simpleMessage("Datum"),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "deleteScheduled": MessageLookupByLibrary.simpleMessage("Löschen planen"),
    "draft": MessageLookupByLibrary.simpleMessage("Entwurf"),
    "emptyFile": MessageLookupByLibrary.simpleMessage("Keine Datei ausgewählt"),
    "error": MessageLookupByLibrary.simpleMessage("Fehler"),
    "errorOccurred": MessageLookupByLibrary.simpleMessage(
      "Etwas ist schiefgelaufen.",
    ),
    "fieldCount": m4,
    "fileSelected": MessageLookupByLibrary.simpleMessage("Datei ausgewählt"),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "formatJson": MessageLookupByLibrary.simpleMessage(
      "JSON formatieren (Umschalt+Alt+F)",
    ),
    "linkedElementNotFound": MessageLookupByLibrary.simpleMessage(
      "Verknüpftes Element nicht gefunden",
    ),
    "live": MessageLookupByLibrary.simpleMessage("Live"),
    "liveFrom": MessageLookupByLibrary.simpleMessage("Live ab"),
    "liveSince": MessageLookupByLibrary.simpleMessage("Live seit"),
    "login": MessageLookupByLibrary.simpleMessage("Anmelden"),
    "loginAuthcode": MessageLookupByLibrary.simpleMessage("Anmelden via IDP"),
    "logout": MessageLookupByLibrary.simpleMessage("Abmelden"),
    "module": MessageLookupByLibrary.simpleMessage("Modul"),
    "modules": MessageLookupByLibrary.simpleMessage("Module"),
    "newElement": MessageLookupByLibrary.simpleMessage("Neues Element"),
    "newResource": m5,
    "noElements": MessageLookupByLibrary.simpleMessage("Keine Elemente"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "outdated": MessageLookupByLibrary.simpleMessage("Veraltet"),
    "pageFrom": m6,
    "pageOf": m7,
    "password": MessageLookupByLibrary.simpleMessage("Passwort"),
    "reallyDeleteElement": m8,
    "refresh": MessageLookupByLibrary.simpleMessage("Aktualisieren"),
    "reloadConfiguration": MessageLookupByLibrary.simpleMessage(
      "Konfiguration neu laden",
    ),
    "resourceDeleted": MessageLookupByLibrary.simpleMessage(
      "Ressource gelöscht.",
    ),
    "resourceSaved": MessageLookupByLibrary.simpleMessage("Gespeichert!"),
    "resources": MessageLookupByLibrary.simpleMessage("Ressourcen"),
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
    "scheduled": MessageLookupByLibrary.simpleMessage("Geplant"),
    "search": MessageLookupByLibrary.simpleMessage("Suche"),
    "signInSubtitle": MessageLookupByLibrary.simpleMessage(
      "Melden Sie sich mit Ihrem Organisationskonto an, um fortzufahren.",
    ),
    "signInTitle": MessageLookupByLibrary.simpleMessage("Willkommen zurück"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "time": MessageLookupByLibrary.simpleMessage("Uhrzeit"),
    "timestamp": MessageLookupByLibrary.simpleMessage("Zeitstempel"),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Erneut versuchen"),
    "username": MessageLookupByLibrary.simpleMessage("Benutzername"),
    "validationJson": MessageLookupByLibrary.simpleMessage("Ungültiges JSON."),
    "validationJsonArray": MessageLookupByLibrary.simpleMessage(
      "Wert muss ein JSON-Array sein.",
    ),
    "validationJsonObject": MessageLookupByLibrary.simpleMessage(
      "Wert muss ein JSON-Objekt sein.",
    ),
    "validationJsonSyntax": m9,
    "validationMaxLength": m10,
    "validationPattern": m11,
    "validationRequired": MessageLookupByLibrary.simpleMessage(
      "Wert ist erforderlich.",
    ),
  };
}
