// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(appTitle) =>
      "There was an error trying to sign you in. Please return to ${appTitle} and try again.";

  static String m1(appTitle) =>
      "You can close this page now and return to ${appTitle}.";

  static String m2(userName) => "by ${userName}";

  static String m3(appTitle) => "Welcome to ${appTitle}";

  static String m4(time) => "Due ${time}";

  static String m5(time) => "Expired ${time}";

  static String m6(time) => "Next attempt ${time}";

  static String m7(worker) => "Running on ${worker}";

  static String m8(fileName) => "Saved ${fileName}.";

  static String m9(step) => "\"${step}\" discarded";

  static String m10(step) => "\"${step}\" given up";

  static String m11(state) => "Resumed in \"${state}\"";

  static String m12(step) => "\"${step}\" retried";

  static String m13(step) => "Signal \"${step}\" received";

  static String m14(state) => "Started in \"${state}\"";

  static String m15(step) => "\"${step}\" failed";

  static String m16(step) => "\"${step}\" ran";

  static String m17(resourceName) => "New ${resourceName}";

  static String m18(from, to) => "${from}–${to}";

  static String m19(from, to, total) => "${from}–${to} of ${total}";

  static String m20(elementName) =>
      "Are you sure you want to delete element \"${elementName}\"?";

  static String m21(step) => "Discard \"${step}\"? It will not be handled.";

  static String m22(state) => "Run the steps of state \"${state}\" again?";

  static String m23(action) => "Run \"${action}\"?";

  static String m24(sort) => "Sorted by ${sort}";

  static String m25(duration) => "after ${duration}";

  static String m26(state) => "On failure: ${state}";

  static String m27(state) => "On entering \"${state}\"";

  static String m28(states) => "Signal, accepted in ${states}";

  static String m29(offset) => "Local (${offset})";

  static String m30(line, column) =>
      "Invalid JSON (line ${line}, column ${column}).";

  static String m31(length) => "Value too long. (> ${length})";

  static String m32(expression) =>
      "Value must match the pattern: ${expression}";

  static String m33(count) => "View all ${count}";

  static String m34(states) => "Waits for ${states}";

  static String m35(resource) => "${resource} workflow";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "actionCompleted": MessageLookupByLibrary.simpleMessage(
      "Action completed.",
    ),
    "actions": MessageLookupByLibrary.simpleMessage("Actions"),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "attempts": MessageLookupByLibrary.simpleMessage("Attempts"),
    "authCallbackErrorMessage": m0,
    "authCallbackErrorTitle": MessageLookupByLibrary.simpleMessage(
      "Sign-in failed",
    ),
    "authCallbackSuccessMessage": m1,
    "authCallbackSuccessTitle": MessageLookupByLibrary.simpleMessage(
      "Signed in successfully",
    ),
    "author": MessageLookupByLibrary.simpleMessage("Author"),
    "byUsername": m2,
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "caution": MessageLookupByLibrary.simpleMessage("Warning"),
    "changes": MessageLookupByLibrary.simpleMessage("Changes"),
    "created": MessageLookupByLibrary.simpleMessage("Created"),
    "dashboardSubtitle": MessageLookupByLibrary.simpleMessage(
      "Pick a resource to get started.",
    ),
    "dashboardTitle": m3,
    "date": MessageLookupByLibrary.simpleMessage("Date"),
    "dateAndTime": MessageLookupByLibrary.simpleMessage("Date & time"),
    "dateTimeFormat": MessageLookupByLibrary.simpleMessage("Format"),
    "dateTimeFormatIso": MessageLookupByLibrary.simpleMessage("ISO 8601"),
    "dateTimeFormatLocalized": MessageLookupByLibrary.simpleMessage(
      "Localized",
    ),
    "dateTimeFormatNumeric": MessageLookupByLibrary.simpleMessage("Numeric"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteScheduled": MessageLookupByLibrary.simpleMessage("Delete scheduled"),
    "discard": MessageLookupByLibrary.simpleMessage("Discard"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "draft": MessageLookupByLibrary.simpleMessage("Draft"),
    "due": MessageLookupByLibrary.simpleMessage("Due"),
    "element": MessageLookupByLibrary.simpleMessage("Element"),
    "emptyFile": MessageLookupByLibrary.simpleMessage("No file selected"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "errorOccurred": MessageLookupByLibrary.simpleMessage(
      "Something went wrong.",
    ),
    "eventDue": m4,
    "eventExpired": MessageLookupByLibrary.simpleMessage("Expired"),
    "eventExpiredAt": m5,
    "eventFailed": MessageLookupByLibrary.simpleMessage("Failed"),
    "eventHandled": MessageLookupByLibrary.simpleMessage(
      "The event was handled.",
    ),
    "eventNextAttempt": m6,
    "eventPending": MessageLookupByLibrary.simpleMessage("Pending"),
    "eventRunning": MessageLookupByLibrary.simpleMessage("Running"),
    "eventRunningOn": m7,
    "events": MessageLookupByLibrary.simpleMessage("Events"),
    "expires": MessageLookupByLibrary.simpleMessage("Expires"),
    "fileSaved": m8,
    "fileSelected": MessageLookupByLibrary.simpleMessage("File selected"),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "formatJson": MessageLookupByLibrary.simpleMessage(
      "Format JSON (Shift+Alt+F)",
    ),
    "heartbeat": MessageLookupByLibrary.simpleMessage("Heartbeat"),
    "history": MessageLookupByLibrary.simpleMessage("History"),
    "historyCancelled": m9,
    "historyNotWritten": MessageLookupByLibrary.simpleMessage(
      "The history is not recorded.",
    ),
    "historyParked": m10,
    "historyResumed": m11,
    "historyRetried": m12,
    "historySignalReceived": m13,
    "historyStarted": m14,
    "historyStepFailed": m15,
    "historyStepSucceeded": m16,
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "linkedElementNotFound": MessageLookupByLibrary.simpleMessage(
      "Linked element not found",
    ),
    "live": MessageLookupByLibrary.simpleMessage("Live"),
    "liveFrom": MessageLookupByLibrary.simpleMessage("Live from"),
    "liveSince": MessageLookupByLibrary.simpleMessage("Live since"),
    "loadMore": MessageLookupByLibrary.simpleMessage("Load more"),
    "log": MessageLookupByLibrary.simpleMessage("Log"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "loginAuthcode": MessageLookupByLibrary.simpleMessage("Login via IDP"),
    "logout": MessageLookupByLibrary.simpleMessage("Sign out"),
    "newElement": MessageLookupByLibrary.simpleMessage("New element"),
    "newResource": m17,
    "nextAttempt": MessageLookupByLibrary.simpleMessage("Next attempt"),
    "noElements": MessageLookupByLibrary.simpleMessage("No Elements"),
    "noEvents": MessageLookupByLibrary.simpleMessage("No events."),
    "noHistory": MessageLookupByLibrary.simpleMessage("No history yet."),
    "noLog": MessageLookupByLibrary.simpleMessage("Nothing logged."),
    "noOpenEvents": MessageLookupByLibrary.simpleMessage("Nothing open."),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "openElement": MessageLookupByLibrary.simpleMessage("Open element"),
    "openEvents": MessageLookupByLibrary.simpleMessage("Open"),
    "outdated": MessageLookupByLibrary.simpleMessage("Outdated"),
    "pageFrom": m18,
    "pageOf": m19,
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "preferences": MessageLookupByLibrary.simpleMessage("Preferences"),
    "preferencesHint": MessageLookupByLibrary.simpleMessage(
      "Your preferences are saved on this device.",
    ),
    "reallyDeleteElement": m20,
    "reallyDiscardEvent": m21,
    "reallyResumeWorkflow": m22,
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "reloadConfiguration": MessageLookupByLibrary.simpleMessage(
      "Reload configuration",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resourceDeleted": MessageLookupByLibrary.simpleMessage(
      "Resource Deleted.",
    ),
    "resourceSaved": MessageLookupByLibrary.simpleMessage("Saved!"),
    "resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "resume": MessageLookupByLibrary.simpleMessage("Resume"),
    "resumeWorkflow": MessageLookupByLibrary.simpleMessage("Resume workflow"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "revert": MessageLookupByLibrary.simpleMessage("Revert"),
    "revisionHistory": MessageLookupByLibrary.simpleMessage("Revision History"),
    "revisionInfo": MessageLookupByLibrary.simpleMessage("Revision Info"),
    "revisionVersion": MessageLookupByLibrary.simpleMessage("Version #"),
    "revisions": MessageLookupByLibrary.simpleMessage("Revisions"),
    "runAction": MessageLookupByLibrary.simpleMessage("Run"),
    "runActionTitle": m23,
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveAndSchedule": MessageLookupByLibrary.simpleMessage(
      "Save and Schedule",
    ),
    "saveAsDraft": MessageLookupByLibrary.simpleMessage("Save as Draft"),
    "scheduleRevision": MessageLookupByLibrary.simpleMessage(
      "Schedule Revision",
    ),
    "scheduled": MessageLookupByLibrary.simpleMessage("Scheduled"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "sendSignal": MessageLookupByLibrary.simpleMessage("Send"),
    "sendSignalMenu": MessageLookupByLibrary.simpleMessage("Send signal"),
    "signInSubtitle": MessageLookupByLibrary.simpleMessage(
      "Sign in with your organization account to continue.",
    ),
    "signInTitle": MessageLookupByLibrary.simpleMessage("Welcome back"),
    "signal": MessageLookupByLibrary.simpleMessage("Signal"),
    "signalSent": MessageLookupByLibrary.simpleMessage(
      "Signal sent. The workflow handles it in the background.",
    ),
    "sortedBy": m24,
    "started": MessageLookupByLibrary.simpleMessage("Started"),
    "state": MessageLookupByLibrary.simpleMessage("State"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "stepAfter": m25,
    "stepAtElementTime": MessageLookupByLibrary.simpleMessage(
      "at the time of the element",
    ),
    "stepFailureState": m26,
    "stepOnEnter": m27,
    "stepOnSignal": m28,
    "steps": MessageLookupByLibrary.simpleMessage("Steps"),
    "systemLanguage": MessageLookupByLibrary.simpleMessage("System language"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "timeZone": MessageLookupByLibrary.simpleMessage("Time zone"),
    "timeZoneHint": MessageLookupByLibrary.simpleMessage(
      "Dates and times are shown and entered in this time zone.",
    ),
    "timeZoneLocal": m29,
    "timeZoneUtc": MessageLookupByLibrary.simpleMessage("UTC"),
    "timestamp": MessageLookupByLibrary.simpleMessage("Timestamp"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Try again"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "validationJson": MessageLookupByLibrary.simpleMessage("Invalid JSON."),
    "validationJsonArray": MessageLookupByLibrary.simpleMessage(
      "Value must be a JSON array.",
    ),
    "validationJsonObject": MessageLookupByLibrary.simpleMessage(
      "Value must be a JSON object.",
    ),
    "validationJsonSyntax": m30,
    "validationMaxLength": m31,
    "validationPattern": m32,
    "validationRequired": MessageLookupByLibrary.simpleMessage(
      "Value is required.",
    ),
    "viewAll": MessageLookupByLibrary.simpleMessage("View all"),
    "viewAllCount": m33,
    "waitsFor": m34,
    "worker": MessageLookupByLibrary.simpleMessage("Worker"),
    "workflow": MessageLookupByLibrary.simpleMessage("Workflow"),
    "workflowOf": m35,
  };
}
