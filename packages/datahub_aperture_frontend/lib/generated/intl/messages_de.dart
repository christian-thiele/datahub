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

  static String m4(time) => "Fällig ${time}";

  static String m5(time) => "Abgelaufen ${time}";

  static String m6(time) => "Nächster Versuch ${time}";

  static String m7(worker) => "Läuft auf ${worker}";

  static String m8(step) => "„${step}“ verworfen";

  static String m9(step) => "„${step}“ aufgegeben";

  static String m10(state) => "Fortgesetzt in „${state}“";

  static String m11(step) => "„${step}“ wiederholt";

  static String m12(step) => "Signal „${step}“ empfangen";

  static String m13(state) => "Gestartet in „${state}“";

  static String m14(step) => "„${step}“ fehlgeschlagen";

  static String m15(step) => "„${step}“ ausgeführt";

  static String m16(resourceName) => "${resourceName} hinzufügen";

  static String m17(from, to) => "${from}–${to}";

  static String m18(from, to, total) => "${from}–${to} von ${total}";

  static String m19(elementName) =>
      "Sind Sie sicher, dass Sie Element \"${elementName}\" löschen möchten?";

  static String m20(step) => "„${step}“ verwerfen? Es wird nicht ausgeführt.";

  static String m21(state) =>
      "Die Schritte des Zustands „${state}“ erneut ausführen?";

  static String m22(action) => "„${action}“ ausführen?";

  static String m23(sort) => "Sortiert nach ${sort}";

  static String m24(duration) => "nach ${duration}";

  static String m25(state) => "Bei Fehler: ${state}";

  static String m26(state) => "Beim Eintritt in „${state}“";

  static String m27(states) => "Signal, angenommen in ${states}";

  static String m28(line, column) =>
      "Ungültiges JSON (Zeile ${line}, Spalte ${column}).";

  static String m29(length) => "Wert zu lang. (> ${length})";

  static String m30(expression) =>
      "Wert muss dem Muster entsprechen: ${expression}";

  static String m31(count) => "Alle ${count} anzeigen";

  static String m32(states) => "Wartet auf ${states}";

  static String m33(resource) => "Workflow: ${resource}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "actionCompleted": MessageLookupByLibrary.simpleMessage(
      "Aktion ausgeführt.",
    ),
    "actions": MessageLookupByLibrary.simpleMessage("Aktionen"),
    "all": MessageLookupByLibrary.simpleMessage("Alle"),
    "attempts": MessageLookupByLibrary.simpleMessage("Versuche"),
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
    "changes": MessageLookupByLibrary.simpleMessage("Änderungen"),
    "created": MessageLookupByLibrary.simpleMessage("Erstellt"),
    "dashboardSubtitle": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie eine Ressource um loszulegen.",
    ),
    "dashboardTitle": m3,
    "date": MessageLookupByLibrary.simpleMessage("Datum"),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "deleteScheduled": MessageLookupByLibrary.simpleMessage("Löschen planen"),
    "discard": MessageLookupByLibrary.simpleMessage("Verwerfen"),
    "done": MessageLookupByLibrary.simpleMessage("Fertig"),
    "draft": MessageLookupByLibrary.simpleMessage("Entwurf"),
    "due": MessageLookupByLibrary.simpleMessage("Fällig"),
    "element": MessageLookupByLibrary.simpleMessage("Element"),
    "emptyFile": MessageLookupByLibrary.simpleMessage("Keine Datei ausgewählt"),
    "error": MessageLookupByLibrary.simpleMessage("Fehler"),
    "errorOccurred": MessageLookupByLibrary.simpleMessage(
      "Etwas ist schiefgelaufen.",
    ),
    "eventDue": m4,
    "eventExpired": MessageLookupByLibrary.simpleMessage("Abgelaufen"),
    "eventExpiredAt": m5,
    "eventFailed": MessageLookupByLibrary.simpleMessage("Fehlgeschlagen"),
    "eventHandled": MessageLookupByLibrary.simpleMessage(
      "Das Ereignis wurde verarbeitet.",
    ),
    "eventNextAttempt": m6,
    "eventPending": MessageLookupByLibrary.simpleMessage("Ausstehend"),
    "eventRunning": MessageLookupByLibrary.simpleMessage("Läuft"),
    "eventRunningOn": m7,
    "events": MessageLookupByLibrary.simpleMessage("Ereignisse"),
    "expires": MessageLookupByLibrary.simpleMessage("Läuft ab"),
    "fileSelected": MessageLookupByLibrary.simpleMessage("Datei ausgewählt"),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "formatJson": MessageLookupByLibrary.simpleMessage(
      "JSON formatieren (Umschalt+Alt+F)",
    ),
    "heartbeat": MessageLookupByLibrary.simpleMessage("Lebenszeichen"),
    "history": MessageLookupByLibrary.simpleMessage("Verlauf"),
    "historyCancelled": m8,
    "historyNotWritten": MessageLookupByLibrary.simpleMessage(
      "Der Verlauf wird nicht aufgezeichnet.",
    ),
    "historyParked": m9,
    "historyResumed": m10,
    "historyRetried": m11,
    "historySignalReceived": m12,
    "historyStarted": m13,
    "historyStepFailed": m14,
    "historyStepSucceeded": m15,
    "linkedElementNotFound": MessageLookupByLibrary.simpleMessage(
      "Verknüpftes Element nicht gefunden",
    ),
    "live": MessageLookupByLibrary.simpleMessage("Live"),
    "liveFrom": MessageLookupByLibrary.simpleMessage("Live ab"),
    "liveSince": MessageLookupByLibrary.simpleMessage("Live seit"),
    "loadMore": MessageLookupByLibrary.simpleMessage("Mehr laden"),
    "log": MessageLookupByLibrary.simpleMessage("Log"),
    "login": MessageLookupByLibrary.simpleMessage("Anmelden"),
    "loginAuthcode": MessageLookupByLibrary.simpleMessage("Anmelden via IDP"),
    "logout": MessageLookupByLibrary.simpleMessage("Abmelden"),
    "newElement": MessageLookupByLibrary.simpleMessage("Neues Element"),
    "newResource": m16,
    "nextAttempt": MessageLookupByLibrary.simpleMessage("Nächster Versuch"),
    "noElements": MessageLookupByLibrary.simpleMessage("Keine Elemente"),
    "noEvents": MessageLookupByLibrary.simpleMessage("Keine Ereignisse."),
    "noHistory": MessageLookupByLibrary.simpleMessage("Noch kein Verlauf."),
    "noLog": MessageLookupByLibrary.simpleMessage("Nichts protokolliert."),
    "noOpenEvents": MessageLookupByLibrary.simpleMessage("Nichts offen."),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "openElement": MessageLookupByLibrary.simpleMessage("Element öffnen"),
    "openEvents": MessageLookupByLibrary.simpleMessage("Offen"),
    "outdated": MessageLookupByLibrary.simpleMessage("Veraltet"),
    "pageFrom": m17,
    "pageOf": m18,
    "password": MessageLookupByLibrary.simpleMessage("Passwort"),
    "reallyDeleteElement": m19,
    "reallyDiscardEvent": m20,
    "reallyResumeWorkflow": m21,
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
    "resume": MessageLookupByLibrary.simpleMessage("Fortsetzen"),
    "resumeWorkflow": MessageLookupByLibrary.simpleMessage(
      "Workflow fortsetzen",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Wiederholen"),
    "revert": MessageLookupByLibrary.simpleMessage("Zurücksetzen"),
    "revisionHistory": MessageLookupByLibrary.simpleMessage("Revisionsverlauf"),
    "revisionInfo": MessageLookupByLibrary.simpleMessage(
      "Revisionsinformationen",
    ),
    "revisionVersion": MessageLookupByLibrary.simpleMessage("Version #"),
    "revisions": MessageLookupByLibrary.simpleMessage("Revisionen"),
    "runAction": MessageLookupByLibrary.simpleMessage("Ausführen"),
    "runActionTitle": m22,
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
    "sendSignal": MessageLookupByLibrary.simpleMessage("Senden"),
    "sendSignalMenu": MessageLookupByLibrary.simpleMessage("Signal senden"),
    "signInSubtitle": MessageLookupByLibrary.simpleMessage(
      "Melden Sie sich mit Ihrem Organisationskonto an, um fortzufahren.",
    ),
    "signInTitle": MessageLookupByLibrary.simpleMessage("Willkommen zurück"),
    "signal": MessageLookupByLibrary.simpleMessage("Signal"),
    "signalSent": MessageLookupByLibrary.simpleMessage(
      "Signal gesendet. Der Workflow verarbeitet es im Hintergrund.",
    ),
    "sortedBy": m23,
    "started": MessageLookupByLibrary.simpleMessage("Gestartet"),
    "state": MessageLookupByLibrary.simpleMessage("Zustand"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "stepAfter": m24,
    "stepAtElementTime": MessageLookupByLibrary.simpleMessage(
      "zum Zeitpunkt des Elements",
    ),
    "stepFailureState": m25,
    "stepOnEnter": m26,
    "stepOnSignal": m27,
    "steps": MessageLookupByLibrary.simpleMessage("Schritte"),
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
    "validationJsonSyntax": m28,
    "validationMaxLength": m29,
    "validationPattern": m30,
    "validationRequired": MessageLookupByLibrary.simpleMessage(
      "Wert ist erforderlich.",
    ),
    "viewAll": MessageLookupByLibrary.simpleMessage("Alle anzeigen"),
    "viewAllCount": m31,
    "waitsFor": m32,
    "worker": MessageLookupByLibrary.simpleMessage("Worker"),
    "workflow": MessageLookupByLibrary.simpleMessage("Workflow"),
    "workflowOf": m33,
  };
}
