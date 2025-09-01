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

  static String m0(userName) => "by ${userName}";

  static String m1(resourceName) => "New ${resourceName}";

  static String m2(length) => "Value too long. (> ${length})";

  static String m3(expression) => "Value must match the pattern: ${expression}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "actions": MessageLookupByLibrary.simpleMessage("Actions"),
    "author": MessageLookupByLibrary.simpleMessage("Author"),
    "byUsername": m0,
    "date": MessageLookupByLibrary.simpleMessage("Date"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "draft": MessageLookupByLibrary.simpleMessage("Draft"),
    "emptyFile": MessageLookupByLibrary.simpleMessage("No file selected"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "liveFrom": MessageLookupByLibrary.simpleMessage("Live from"),
    "liveSince": MessageLookupByLibrary.simpleMessage("Live since"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "newResource": m1,
    "noElements": MessageLookupByLibrary.simpleMessage("No Elements"),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "resourceDeleted": MessageLookupByLibrary.simpleMessage(
      "Resource Deleted.",
    ),
    "resourceSaved": MessageLookupByLibrary.simpleMessage("Saved!"),
    "revisionHistory": MessageLookupByLibrary.simpleMessage("Revision History"),
    "revisionId": MessageLookupByLibrary.simpleMessage("Revision ID"),
    "revisionInfo": MessageLookupByLibrary.simpleMessage("Revision Info"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveAndSchedule": MessageLookupByLibrary.simpleMessage(
      "Save and Schedule",
    ),
    "saveAsDraft": MessageLookupByLibrary.simpleMessage("Save as Draft"),
    "scheduleRevision": MessageLookupByLibrary.simpleMessage(
      "Schedule Revision",
    ),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "timestamp": MessageLookupByLibrary.simpleMessage("Timestamp"),
    "validationMaxLength": m2,
    "validationPattern": m3,
    "validationRequired": MessageLookupByLibrary.simpleMessage(
      "Value is required.",
    ),
  };
}
