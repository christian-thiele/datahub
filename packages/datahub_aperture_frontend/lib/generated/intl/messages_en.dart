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

  static String m8(step) => "\"${step}\" discarded";

  static String m9(step) => "\"${step}\" given up";

  static String m10(state) => "Resumed in \"${state}\"";

  static String m11(step) => "\"${step}\" retried";

  static String m12(step) => "Signal \"${step}\" received";

  static String m13(state) => "Started in \"${state}\"";

  static String m14(step) => "\"${step}\" failed";

  static String m15(step) => "\"${step}\" ran";

  static String m16(resourceName) => "New ${resourceName}";

  static String m17(from, to) => "${from}–${to}";

  static String m18(from, to, total) => "${from}–${to} of ${total}";

  static String m19(elementName) =>
      "Are you sure you want to delete element \"${elementName}\"?";

  static String m20(step) => "Discard \"${step}\"? It will not be handled.";

  static String m21(state) => "Run the steps of state \"${state}\" again?";

  static String m22(action) => "Run \"${action}\"?";

  static String m23(sort) => "Sorted by ${sort}";

  static String m24(duration) => "after ${duration}";

  static String m25(state) => "On failure: ${state}";

  static String m26(state) => "On entering \"${state}\"";

  static String m27(states) => "Signal, accepted in ${states}";

  static String m28(line, column) =>
      "Invalid JSON (line ${line}, column ${column}).";

  static String m29(length) => "Value too long. (> ${length})";

  static String m30(expression) =>
      "Value must match the pattern: ${expression}";

  static String m31(count) => "View all ${count}";

  static String m32(states) => "Waits for ${states}";

  static String m33(resource) => "${resource} workflow";

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
    "fileSelected": MessageLookupByLibrary.simpleMessage("File selected"),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "formatJson": MessageLookupByLibrary.simpleMessage(
      "Format JSON (Shift+Alt+F)",
    ),
    "heartbeat": MessageLookupByLibrary.simpleMessage("Heartbeat"),
    "history": MessageLookupByLibrary.simpleMessage("History"),
    "historyCancelled": m8,
    "historyNotWritten": MessageLookupByLibrary.simpleMessage(
      "The history is not recorded.",
    ),
    "historyParked": m9,
    "historyResumed": m10,
    "historyRetried": m11,
    "historySignalReceived": m12,
    "historyStarted": m13,
    "historyStepFailed": m14,
    "historyStepSucceeded": m15,
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
    "newResource": m16,
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
    "pageFrom": m17,
    "pageOf": m18,
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "reallyDeleteElement": m19,
    "reallyDiscardEvent": m20,
    "reallyResumeWorkflow": m21,
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
    "runActionTitle": m22,
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
    "sortedBy": m23,
    "started": MessageLookupByLibrary.simpleMessage("Started"),
    "state": MessageLookupByLibrary.simpleMessage("State"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "stepAfter": m24,
    "stepAtElementTime": MessageLookupByLibrary.simpleMessage(
      "at the time of the element",
    ),
    "stepFailureState": m25,
    "stepOnEnter": m26,
    "stepOnSignal": m27,
    "steps": MessageLookupByLibrary.simpleMessage("Steps"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
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
    "validationJsonSyntax": m28,
    "validationMaxLength": m29,
    "validationPattern": m30,
    "validationRequired": MessageLookupByLibrary.simpleMessage(
      "Value is required.",
    ),
    "viewAll": MessageLookupByLibrary.simpleMessage("View all"),
    "viewAllCount": m31,
    "waitsFor": m32,
    "worker": MessageLookupByLibrary.simpleMessage("Worker"),
    "workflow": MessageLookupByLibrary.simpleMessage("Workflow"),
    "workflowOf": m33,
  };
}
