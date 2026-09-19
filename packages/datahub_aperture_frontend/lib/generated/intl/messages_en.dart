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

  static String m4(count) => "${count} fields";

  static String m5(resourceName) => "New ${resourceName}";

  static String m6(from, to) => "${from}–${to}";

  static String m7(from, to, total) => "${from}–${to} of ${total}";

  static String m8(elementName) =>
      "Are you sure you want to delete element \"${elementName}\"?";

  static String m9(line, column) =>
      "Invalid JSON (line ${line}, column ${column}).";

  static String m10(length) => "Value too long. (> ${length})";

  static String m11(expression) =>
      "Value must match the pattern: ${expression}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "actions": MessageLookupByLibrary.simpleMessage("Actions"),
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
    "dashboardSubtitle": MessageLookupByLibrary.simpleMessage(
      "Pick a resource or module to get started.",
    ),
    "dashboardTitle": m3,
    "date": MessageLookupByLibrary.simpleMessage("Date"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteScheduled": MessageLookupByLibrary.simpleMessage("Delete scheduled"),
    "draft": MessageLookupByLibrary.simpleMessage("Draft"),
    "emptyFile": MessageLookupByLibrary.simpleMessage("No file selected"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "errorOccurred": MessageLookupByLibrary.simpleMessage(
      "Something went wrong.",
    ),
    "fieldCount": m4,
    "fileSelected": MessageLookupByLibrary.simpleMessage("File selected"),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "formatJson": MessageLookupByLibrary.simpleMessage(
      "Format JSON (Shift+Alt+F)",
    ),
    "linkedElementNotFound": MessageLookupByLibrary.simpleMessage(
      "Linked element not found",
    ),
    "live": MessageLookupByLibrary.simpleMessage("Live"),
    "liveFrom": MessageLookupByLibrary.simpleMessage("Live from"),
    "liveSince": MessageLookupByLibrary.simpleMessage("Live since"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "loginAuthcode": MessageLookupByLibrary.simpleMessage("Login via IDP"),
    "logout": MessageLookupByLibrary.simpleMessage("Sign out"),
    "module": MessageLookupByLibrary.simpleMessage("Module"),
    "modules": MessageLookupByLibrary.simpleMessage("Modules"),
    "newElement": MessageLookupByLibrary.simpleMessage("New element"),
    "newResource": m5,
    "noElements": MessageLookupByLibrary.simpleMessage("No Elements"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "outdated": MessageLookupByLibrary.simpleMessage("Outdated"),
    "pageFrom": m6,
    "pageOf": m7,
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "reallyDeleteElement": m8,
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "reloadConfiguration": MessageLookupByLibrary.simpleMessage(
      "Reload configuration",
    ),
    "resourceDeleted": MessageLookupByLibrary.simpleMessage(
      "Resource Deleted.",
    ),
    "resourceSaved": MessageLookupByLibrary.simpleMessage("Saved!"),
    "resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "revert": MessageLookupByLibrary.simpleMessage("Revert"),
    "revisionHistory": MessageLookupByLibrary.simpleMessage("Revision History"),
    "revisionInfo": MessageLookupByLibrary.simpleMessage("Revision Info"),
    "revisionVersion": MessageLookupByLibrary.simpleMessage("Version #"),
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
    "signInSubtitle": MessageLookupByLibrary.simpleMessage(
      "Sign in with your organization account to continue.",
    ),
    "signInTitle": MessageLookupByLibrary.simpleMessage("Welcome back"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "timestamp": MessageLookupByLibrary.simpleMessage("Timestamp"),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Try again"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "validationJson": MessageLookupByLibrary.simpleMessage("Invalid JSON."),
    "validationJsonArray": MessageLookupByLibrary.simpleMessage(
      "Value must be a JSON array.",
    ),
    "validationJsonObject": MessageLookupByLibrary.simpleMessage(
      "Value must be a JSON object.",
    ),
    "validationJsonSyntax": m9,
    "validationMaxLength": m10,
    "validationPattern": m11,
    "validationRequired": MessageLookupByLibrary.simpleMessage(
      "Value is required.",
    ),
  };
}
