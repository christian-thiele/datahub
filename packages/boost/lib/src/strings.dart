/// Returns true if string is either null or empty.
bool nullOrEmpty(String? source) => source?.isEmpty ?? true;

/// Returns true if string is either null or entirely whitespace.
bool nullOrWhitespace(String? source) => source?.trim().isEmpty ?? true;
