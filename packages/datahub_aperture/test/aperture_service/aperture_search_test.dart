// Searching the elements of a resource, by default and with a custom
// search filter builder, through Aperture's HTTP API.
import 'dart:convert';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:test/test.dart';

import '../_mock/note.dart';
import '../_utils/aperture_sign_in.dart';
import '../scenarios/_utils/test_auth_service.dart';

const _apiPort = 18200;
const _authPort = 18201;
const _issuer = 'http://localhost:$_authPort/realms/test';

final _notes = [
  Note(
    title: 'Water plants',
    body: 'In the kitchen',
    secret: 'garden',
    priority: 1,
    created: DateTime.utc(2026),
  ),
  Note(
    title: 'Buy milk',
    body: 'Oat, not cow',
    secret: 'kitchen',
    priority: 2,
    created: DateTime.utc(2026),
  ),
  Note(
    title: 'Plant tree',
    body: 'In the garden',
    secret: 'water',
    priority: 3,
    created: DateTime.utc(2026),
  ),
];

List<Component> _components({SearchFilterBuilder? searchBuilder}) => [
  const KeyService(),
  const TestAuthService(issuer: Config.value(_issuer)),
  MemoryRepositoryService(bean: $Note.bean, initialData: _notes),
  ApiService(
    port: const Config.value(_apiPort),
    routes: [
      ApertureApi(
        oidcIssuer: const Config.value(_issuer),
        resources: [
          ApertureResource(
            repository: const Find<DataRepository<Note>>(),
            searchBuilder: searchBuilder,
          ),
        ],
      ),
    ],
  ),
];

/// Titles of the elements matching [filter], in creation order.
Future<List<String>> _titles(ResourceFilter filter) async {
  final client = await signInToAperture(issuer: _issuer, apiPort: _apiPort);
  final response = await client
      .get(
        '/api/resources/Note/elements',
        query: {
          'filter': [jsonEncode(filter.toJson())],
          'sort': ['id'],
        },
      )
      .thenGetData($ResourceElementsResponse.bean);
  return [for (final e in response.data) e.fieldData['title'] as String];
}

Future<List<String>> _search(String search) =>
    _titles(ResourceFilter(search: search));

/// Matches only elements whose title is exactly the search.
Filter _exactTitle(List<DataField> searchFields, List<String> words) =>
    Filter.equals($Note.$title, words.join(' '));

List<String>? _recordedFields;
List<String>? _recordedWords;

/// Records what it receives and matches everything.
Filter _recordingBuilder(List<DataField> searchFields, List<String> words) {
  _recordedFields = [for (final f in searchFields) f.name];
  _recordedWords = words;
  return Filter.empty;
}

void main() {
  group('default search', () {
    declareTest(
      'matches a word in any searchable field, ignoring case',
      _components(),
      () async {
        expect(await _search('plant'), ['Water plants', 'Plant tree']);
        expect(await _search('KITCHEN'), ['Water plants']);
      },
    );

    declareTest('requires every word to match', _components(), () async {
      expect(await _search('plant garden'), ['Plant tree']);
      expect(await _search('plant, milk'), isEmpty);
    });

    declareTest(
      'skips fields that do not allow search',
      _components(),
      () async {
        // "garden" and "water" also appear in the secrets of other notes.
        expect(await _search('garden'), ['Plant tree']);
        expect(await _search('water'), ['Water plants']);
      },
    );
  });

  group('custom search builder', () {
    declareTest(
      'receives the searchable fields and the words',
      _components(searchBuilder: _recordingBuilder),
      () async {
        await _search('water the-plants');

        // Neither the DateTime field nor the field disallowing search.
        expect(_recordedFields, ['id', 'title', 'body', 'priority']);
        expect(_recordedWords, ['water', 'the', 'plants']);
      },
    );

    declareTest(
      'is used instead of the default search',
      _components(searchBuilder: _exactTitle),
      () async {
        expect(await _search('plant'), isEmpty);
        expect(await _search('Plant tree'), ['Plant tree']);
      },
    );

    declareTest(
      'is used for searches nested in groups',
      _components(searchBuilder: _exactTitle),
      () async {
        const filter = ResourceFilter(
          or: [
            ResourceFilter(search: 'Buy milk'),
            ResourceFilter(search: 'plant'),
          ],
        );
        expect(await _titles(filter), ['Buy milk']);
      },
    );

    declareTest(
      'can extend the default search',
      _components(
        searchBuilder: (fields, words) => Filter.andGroup([
          defaultSearchFilterBuilder(fields, words),
          CompareFilter(
            $Note.$priority,
            CompareType.lessThan,
            const ValueExpression(3),
          ),
        ]),
      ),
      () async {
        expect(await _search('plant'), ['Water plants']);
      },
    );
  });
}
