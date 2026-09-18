import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/resource_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Holds the value of a field like the form does, and records the values the
/// field emits.
class _Host extends StatefulWidget {
  final ResourceField field;
  final dynamic initialValue;
  final List<dynamic> emitted;

  const _Host({
    required this.field,
    required this.initialValue,
    required this.emitted,
  });

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late dynamic value = widget.initialValue;

  @override
  Widget build(BuildContext context) => ResourceFormField(
    field: widget.field,
    path: widget.field.id,
    value: value,
    onChanged: (v) => setState(() {
      widget.emitted.add(v);
      value = v;
    }),
  );
}

/// Pumps [field] with [value] and returns the values it emits.
Future<List<dynamic>> _pump(
  WidgetTester tester,
  ResourceField field, {
  dynamic value,
  ResourcesRepository? repository,
}) async {
  final emitted = [];
  final app = MaterialApp(
    localizationsDelegates: const [S.delegate],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(
      body: _Host(field: field, initialValue: value, emitted: emitted),
    ),
  );
  await tester.pumpWidget(
    repository != null
        ? RepositoryProvider<ResourcesRepository>.value(
            value: repository,
            child: app,
          )
        : app,
  );
  return emitted;
}

List<String> _texts(WidgetTester tester) => [
  for (final field in tester.widgetList<TextField>(find.byType(TextField)))
    field.controller!.text,
];

/// Serves a single person to look up.
class _People implements ResourcesRepository {
  final searches = <ResourceFilter?>[];

  @override
  Future<ResourceDescription> getDescription(String id) async =>
      const ResourceDescription(
        id: 'Person',
        name: 'Person',
        icon: 0xe491,
        fields: [
          ResourceField(id: 'id', name: 'Id', type: ResourceFieldType.int),
          ResourceField(
            id: 'name',
            name: 'Name',
            type: ResourceFieldType.string,
          ),
        ],
        relations: [],
        idField: 'id',
        displayField: 'name',
        readOnly: false,
        revisable: false,
        actions: [],
      );

  @override
  Future<ResourceElementsResponse> getResourceElements(
    String resourceId, {
    ResourceFilter? filter,
    String? sortFieldId,
    bool sortAscending = true,
    int offset = 0,
    int limit = 25,
  }) async {
    searches.add(filter);
    return ResourceElementsResponse(
      total: 1,
      hasNextPage: false,
      data: [
        ResourceData(id: '42', fieldData: {'id': 42, 'name': 'Ada'}),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  for (final (type, zero, value, text) in [
    (ResourceFieldType.int, 0, 5, '5'),
    (ResourceFieldType.double, 0.0, 2.5, '2.5'),
  ]) {
    group('${type.name} field', () {
      final field = ResourceField(id: 'count', name: 'Count', type: type);

      testWidgets('shows no value as empty text', (tester) async {
        await _pump(tester, field);

        expect(_texts(tester), ['']);
      });

      testWidgets('shows its value', (tester) async {
        await _pump(tester, field, value: value);

        expect(_texts(tester), [text]);
      });

      testWidgets('emits 0 when 0 is entered', (tester) async {
        final emitted = await _pump(tester, field);

        await tester.enterText(find.byType(TextField), '0');
        await tester.pump();

        expect(emitted, [zero]);
        expect(_texts(tester), ['0']);
      });

      testWidgets('emits null when cleared', (tester) async {
        final emitted = await _pump(tester, field, value: value);

        await tester.enterText(find.byType(TextField), '');
        await tester.pump();

        expect(emitted, [null]);
        expect(_texts(tester), ['']);
      });

      testWidgets('shows a value replaced from the outside', (tester) async {
        Future<void> pumpValue(dynamic value) => tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ResourceFormField(
                field: field,
                path: field.id,
                value: value,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        await pumpValue(null);
        await pumpValue(value);
        expect(_texts(tester), [text]);

        await pumpValue(null);
        expect(_texts(tester), ['']);
      });
    });
  }

  testWidgets('keeps unfinished decimals while they are typed', (tester) async {
    final emitted = await _pump(
      tester,
      const ResourceField(
        id: 'ratio',
        name: 'Ratio',
        type: ResourceFieldType.double,
      ),
    );

    await tester.enterText(find.byType(TextField), '1.');
    await tester.pump();
    await tester.enterText(find.byType(TextField), '1.5');
    await tester.pump();

    expect(emitted, [1.0, 1.5]);
    expect(_texts(tester), ['1.5']);
  });

  testWidgets('shows a new list element as empty', (tester) async {
    final emitted = await _pump(
      tester,
      const ResourceField(
        id: 'numbers',
        name: 'Numbers',
        type: ResourceFieldType.list,
        objectDescription: [
          ResourceField(id: 'element', name: '', type: ResourceFieldType.int),
        ],
      ),
      value: [1],
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(_texts(tester), ['1', '']);

    await tester.enterText(find.byType(TextField).last, '0');
    await tester.pump();
    expect(emitted, [
      [1, null],
      [1, 0],
    ]);
  });

  testWidgets('looks up relations for an empty value without a search', (
    tester,
  ) async {
    final people = _People();
    final emitted = await _pump(
      tester,
      const ResourceField(
        id: 'ownerId',
        name: 'Owner',
        type: ResourceFieldType.int,
        nullable: true,
        lookup: ResourceFieldLookup(
          resourceId: 'Person',
          resourceFieldId: 'id',
          filter: ResourceRelationFilter(),
        ),
      ),
      repository: people,
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(people.searches.single?.and, isEmpty);

    await tester.tap(find.text('Ada'));
    await tester.pumpAndSettle();
    expect(emitted, [42]);
    expect(_texts(tester), ['42']);
  });
}
