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

  static String m3(resourceName) => "New ${resourceName}";

  static String m4(elementName) =>
      "Are you sure you want to delete element \"${elementName}\"?";

  static String m5(length) => "Value too long. (> ${length})";

  static String m6(expression) => "Value must match the pattern: ${expression}";

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
    "date": MessageLookupByLibrary.simpleMessage("Date"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteScheduled": MessageLookupByLibrary.simpleMessage("Delete scheduled"),
    "draft": MessageLookupByLibrary.simpleMessage("Draft"),
    "emptyFile": MessageLookupByLibrary.simpleMessage("No file selected"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "fileSelected": MessageLookupByLibrary.simpleMessage("File selected"),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "liveFrom": MessageLookupByLibrary.simpleMessage("Live from"),
    "liveSince": MessageLookupByLibrary.simpleMessage("Live since"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "loginAuthcode": MessageLookupByLibrary.simpleMessage("Login via IDP"),
    "newResource": m3,
    "noElements": MessageLookupByLibrary.simpleMessage("No Elements"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "reallyDeleteElement": m4,
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "resourceDeleted": MessageLookupByLibrary.simpleMessage(
      "Resource Deleted.",
    ),
    "resourceSaved": MessageLookupByLibrary.simpleMessage("Saved!"),
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
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "timestamp": MessageLookupByLibrary.simpleMessage("Timestamp"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "validationMaxLength": m5,
    "validationPattern": m6,
    "validationRequired": MessageLookupByLibrary.simpleMessage(
      "Value is required.",
    ),
  };
}
