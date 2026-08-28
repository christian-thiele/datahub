import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

import '_fixture/pet.dart';

void main() {
  test('bean schema conversion', () {
    final registry = OpenApiSchemaRegistry();
    final ref = registry.referenceBean($Pet.bean);

    expect(ref, equals({r'$ref': '#/components/schemas/Pet'}));

    final pet = registry.schemas['Pet']!;
    expect(pet['type'], equals('object'));
    expect(pet['title'], equals('Pet'));
    expect(pet['description'], equals('A pet in the store.'));
    expect(
      pet['required'],
      equals(['id', 'name', 'kind', 'vaccinated', 'tags']),
    );

    final props = pet['properties'] as Map<String, dynamic>;
    expect(props['id'], equals({'type': 'integer'}));
    expect(
      props['name'],
      equals({'type': 'string', 'minLength': 3, 'maxLength': 30}),
    );
    expect(props['kind'], containsPair('type', 'string'));
    expect(props['kind'], containsPair('enum', ['cat', 'dog', 'other']));
    expect(
      props['age'],
      equals({
        'type': 'integer',
        'minimum': 0,
        'maximum': 100,
        'nullable': true,
        'description': 'Age in years.',
      }),
    );
    expect(props['vaccinated'], equals({'type': 'boolean'}));
    expect(
      props['born'],
      equals({'type': 'string', 'format': 'date-time', 'nullable': true}),
    );
    expect(
      props['tags'],
      equals({
        'type': 'array',
        'items': {'type': 'string', 'pattern': r'^[a-z]+$'},
      }),
    );
    expect(
      props['owner'],
      equals({
        'nullable': true,
        'allOf': [
          {r'$ref': '#/components/schemas/Owner'},
        ],
      }),
    );

    // cyclic reference Pet -> Owner -> Pet resolves
    final owner = registry.schemas['Owner']!;
    final ownerProps = owner['properties'] as Map<String, dynamic>;
    expect(
      ownerProps['pets'],
      equals({
        'type': 'array',
        'items': {r'$ref': '#/components/schemas/Pet'},
      }),
    );
  });

  test('schema for plain types', () {
    final registry = OpenApiSchemaRegistry();
    expect(
      registry.schemaForType(const TypeCheck<String>()),
      equals({'type': 'string'}),
    );
    expect(
      registry.schemaForType(const TypeCheck<int?>()),
      equals({'type': 'integer'}),
    );
    expect(
      registry.schemaForType(const TypeCheck<double>()),
      equals({'type': 'number'}),
    );
    expect(
      registry.schemaForType(const TypeCheck<bool?>()),
      equals({'type': 'boolean'}),
    );
    expect(
      registry.schemaForType(const TypeCheck<DateTime>()),
      equals({'type': 'string', 'format': 'date-time'}),
    );
    expect(
      registry.schemaForType(const TypeCheck<List<String>?>()),
      equals({
        'type': 'array',
        'items': {'type': 'string'},
      }),
    );
  });
}
