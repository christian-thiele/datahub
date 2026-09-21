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

  static String m4(resourceName) => "${resourceName} hinzufügen";

  static String m5(from, to) => "${from}–${to}";

  static String m6(from, to, total) => "${from}–${to} von ${total}";

  static String m7(elementName) =>
      "Sind Sie sicher, dass Sie Element \"${elementName}\" löschen möchten?";

  static String m8(action) => "„${action}“ ausführen?";

  static String m9(sort) => "Sortiert nach ${sort}";

  static String m10(line, column) =>
      "Ungültiges JSON (Zeile ${line}, Spalte ${column}).";

  static String m11(length) => "Wert zu lang. (> ${length})";

  static String m12(expression) =>
      "Wert muss dem Muster entsprechen: ${expression}";

  static String m13(count) => "Alle ${count} anzeigen";

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
    "done": MessageLookupByLibrary.simpleMessage("Fertig"),
    "draft": MessageLookupByLibrary.simpleMessage("Entwurf"),
    "emptyFile": MessageLookupByLibrary.simpleMessage("Keine Datei ausgewählt"),
    "error": MessageLookupByLibrary.simpleMessage("Fehler"),
    "errorOccurred": MessageLookupByLibrary.simpleMessage(
      "Etwas ist schiefgelaufen.",
    ),
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
    "modules": MessageLookupByLibrary.simpleMessage("Module"),
    "newElement": MessageLookupByLibrary.simpleMessage("Neues Element"),
    "newResource": m4,
    "noElements": MessageLookupByLibrary.simpleMessage("Keine Elemente"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "outdated": MessageLookupByLibrary.simpleMessage("Veraltet"),
    "pageFrom": m5,
    "pageOf": m6,
    "password": MessageLookupByLibrary.simpleMessage("Passwort"),
    "reallyDeleteElement": m7,
    "refresh": MessageLookupByLibrary.simpleMessage("Aktualisieren"),
    "reloadConfiguration": MessageLookupByLibrary.simpleMessage(
      "Konfiguration neu laden",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Zurücksetzen"),
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
    "runAction": MessageLookupByLibrary.simpleMessage("Ausführen"),
    "runActionTitle": m8,
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
    "sortedBy": m9,
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "time": MessageLookupByLibrary.simpleMessage("Uhrzeit"),
    "timestamp": MessageLookupByLibrary.simpleMessage("Zeitstempel"),
    "total": MessageLookupByLibrary.simpleMessage("Gesamt"),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Erneut versuchen"),
    "username": MessageLookupByLibrary.simpleMessage("Benutzername"),
    "validationJson": MessageLookupByLibrary.simpleMessage("Ungültiges JSON."),
    "validationJsonArray": MessageLookupByLibrary.simpleMessage(
      "Wert muss ein JSON-Array sein.",
    ),
    "validationJsonObject": MessageLookupByLibrary.simpleMessage(
      "Wert muss ein JSON-Objekt sein.",
    ),
    "validationJsonSyntax": m10,
    "validationMaxLength": m11,
    "validationPattern": m12,
    "validationRequired": MessageLookupByLibrary.simpleMessage(
      "Wert ist erforderlich.",
    ),
    "viewAll": MessageLookupByLibrary.simpleMessage("Alle anzeigen"),
    "viewAllCount": m13,
  };
}
