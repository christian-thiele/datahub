import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/data.dart';

/// Builds the filter for a search in a resource, given the fields that allow
/// search and the words of the search.
typedef SearchFilterBuilder = Filter Function(
  List<DataField> searchFields,
  List<String> words,
);

/// Matches elements in which every word is contained in any search field.
Filter defaultSearchFilterBuilder(
  List<DataField> searchFields,
  List<String> words,
) {
  return Filter.andGroup([
    for (final word in words)
      Filter.orGroup([
        for (final field in searchFields)
          ?ResourceUtils._tryCompareFilter(field, CompareType.contains, word),
      ]),
  ]);
}

class const ResourceUtils._() {
  static ResourceData toResourceData(
    DataRepository repo,
    dynamic object, [
    List<RevisionData>? revisions,
  ]) {
    if (object case RevisionData(:final data, :final version)) {
      return ResourceData(
        id: repo.bean.requireIdField.valueOf(data).toString(),
        fieldData: data.toJson(),
        version: version,
        revisions: [
          for (final revision in revisions ?? <RevisionData>[])
            ResourceRevisionInfo(
              version: revision.version,
              type: switch (revision) {
                RevisionData(isDeleted: true) => ResourceRevisionType.delete,
                RevisionData(version: 0) => ResourceRevisionType.create,
                _ => ResourceRevisionType.update,
              },
              timestamp: revision.created,
              live: revision.from,
              userId: revision.creator,
              userName: revision.creator,
            ),
        ],
      );
    }

    return ResourceData(
      id: repo.bean.requireIdField.valueOf(object).toString(),
      fieldData: object.toJson(),
    );
  }

  static Filter buildFilter(
    DataRepository repo,
    ResourceFilter? filter, {
    SearchFilterBuilder? searchBuilder,
  }) {
    try {
      final bean = repo.bean;
      if (filter == null) {
        return Filter.empty;
      }

      final Filter elementFilter;
      if (filter case ResourceFilter(:final search?)) {
        elementFilter = buildSearchFilter(repo, search, builder: searchBuilder);
      } else if (filter case ResourceFilter(
        :final type?,
        :final fieldId?,
        :final value,
      )) {
        elementFilter =
            _tryCompareFilter(
              bean.fields.firstWhere((e) => e.name == fieldId),
              switch (type) {
                ResourceFilterType.equals => CompareType.equals,
                ResourceFilterType.notEquals => CompareType.notEquals,
                ResourceFilterType.greaterThan => CompareType.greaterThan,
                ResourceFilterType.lessThan => CompareType.lessThan,
                ResourceFilterType.contains => CompareType.contains,
              },
              value,
            ) ??
            Filter.empty;
      } else {
        elementFilter = Filter.empty;
      }

      return Filter.andGroup([
        Filter.andGroup(
          (filter.and ?? <ResourceFilter>[]).map(
            (e) => buildFilter(repo, e, searchBuilder: searchBuilder),
          ),
        ),
        Filter.orGroup(
          (filter.or ?? <ResourceFilter>[]).map(
            (e) => buildFilter(repo, e, searchBuilder: searchBuilder),
          ),
        ),
        elementFilter,
      ]);
    } catch (e) {
      log.warn('Filter error: ${e.toString()}');
      return Filter.empty;
    }
  }

  static Filter buildSearchFilter(
    DataRepository repo,
    String search, {
    SearchFilterBuilder? builder,
  }) {
    final words = search.split(RegExp('\\W+'));

    final searchFields = <DataField>[];
    for (final field in repo.bean.fields) {
      final apertureField = field.metaOfType<ApertureField>();
      if (apertureField?.allowSearch == false) {
        continue;
      }

      bool isSearchField = switch (field) {
        DataField<dynamic, String?>() => true,
        DataField<dynamic, Enum?>() => true,
        DataField<dynamic, int?>() => true,
        DataField<dynamic, double?>() => true,
        DataField<dynamic, List<String?>?>() => true,
        _ => false,
      };

      if (isSearchField) {
        searchFields.add(field);
      }
    }

    final effectiveBuilder = builder ?? defaultSearchFilterBuilder;
    return effectiveBuilder(searchFields, words);
  }

  static Sort buildSort(DataRepository repo, String? fieldId, bool ascending) {
    if (fieldId == null) {
      return Sort.empty;
    }
    final field = repo.bean.fields.firstWhere((e) => e.name == fieldId);
    return field.sort(ascending);
  }

  static Filter? _tryCompareFilter(
    DataField<dynamic, dynamic> field,
    CompareType type,
    String? value,
  ) {
    try {
      return CompareFilter(
        field,
        type,
        ValueExpression(alignFieldValue(field, value)),
      );
    } on CodecException catch (e) {
      log.trace('Filter error. Discarding filter element.', error: e);
      return null;
    }
  }

  // TODO find a way not to need this?
  static dynamic alignFieldValue(
    DataField<dynamic, dynamic> field,
    String? value,
  ) {
    if (field.type.accepts(value)) {
      return value;
    }

    if (field.type.isSubtypeOf<List?>()) {
      return value;
    }

    if (field.type.isSubtypeOf<Enum?>()) {
      return value;
    }

    return const JsonDataCodec().decodeType(field.type, value);
  }
}
