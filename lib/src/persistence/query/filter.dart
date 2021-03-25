import 'package:cl_datahub/src/persistence/database_adapter.dart';

/// Representing filter arguments in a uniform, abstract way.
///
/// To allow different [DatabaseAdapter] implementations to interpret or
/// implement filtering in different ways (e.g. convert to SQL statements)
/// this is a uniform representation of filter arguments.
///
/// All [Filter] implementations are immutable.
abstract class Filter {
  bool get isEmpty;

  /// Tries to simplify the Filter structure to avoid redundancy.
  Filter reduce();

  /// Returns the representation of "no filter".
  static Filter get empty => _EmptyFilter();

  /// Returns the smallest representation of the "And" group of [filters].
  ///
  /// See implementation of [_optimizedGroup] for details;
  static Filter and(List<Filter> filters) =>
      _optimizedGroup(filters, FilterGroupType.And);

  /// Returns the smallest representation of the "Or" group of [filters].
  ///
  /// See implementation of [_optimizedGroup] for details;
  static Filter or(List<Filter> filters) =>
      _optimizedGroup(filters, FilterGroupType.Or);

  /// Convenience method for creating a [PropertyCompare] filter
  /// with compare type [PropertyCompareType.Equals].
  static PropertyCompare equals(String propertyName, dynamic value) {
    return PropertyCompare(PropertyCompareType.Equals, propertyName, value);
  }

  /// Assembles the smallest representation of [filters] combined.
  static Filter _optimizedGroup(List<Filter> filters, FilterGroupType type) {
    final notEmpty = filters.where((element) => !element.isEmpty);
    if (notEmpty.isEmpty) {
      return Filter.empty;
    } else if (notEmpty.length == 1) {
      return notEmpty.single;
    } else {
      return FilterGroup(notEmpty.toList(growable: false), type);
    }
  }
}

enum FilterGroupType { And, Or }

/// Joins multiple [Filter] elements into a group using a [FilterGroupType].
///
/// Best practice: Use the convenience methods [Filter.and] / [Filter.or]
/// instead of instantiating [FilterGroup] directly.
class FilterGroup implements Filter {
  final List<Filter> filters;
  final FilterGroupType type;

  const FilterGroup(this.filters, this.type);

  @override
  bool get isEmpty => filters.every((element) => element.isEmpty);

  @override
  Filter reduce() {
    final reduced =
        filters.map((f) => f.reduce()).where((element) => !element.isEmpty);

    if (reduced.isEmpty) {
      return Filter.empty;
    } else if (reduced.length == 1) {
      return reduced.single;
    } else {
      return FilterGroup(reduced.toList(growable: false), type);
    }
  }
}

enum PropertyCompareType {
  Equals,
  GreaterThan,
  LessThan,
  GreaterOrEqual,
  LessOrEqual
}

class PropertyCompare implements Filter {
  final PropertyCompareType type;
  final String
      propertyName; //TODO maybe field object or something like that (string is sketchy)
  final dynamic value; //TODO dynamic? check if this holds up

  const PropertyCompare(this.type, this.propertyName, this.value);

  @override
  bool get isEmpty => false;

  @override
  Filter reduce() => this;
}

class _EmptyFilter implements Filter {
  const _EmptyFilter();

  @override
  final bool isEmpty = true;

  @override
  Filter reduce() => this;
}