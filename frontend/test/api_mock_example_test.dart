
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('mock API returns a list of tasks', () async {
    final mockClient = MockClient((request) async {
      if (request.url.path == '/tasks') {
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'title': 'Study Python',
              'completed': false
            }
          ]),
          200,
          headers: {
            'content-type': 'application/json'
          },
        );
      }

      return http.Response('Not found', 404);
    });

    final response = await mockClient.get(
      Uri.parse('http://localhost/tasks'),
    );

    expect(response.statusCode, 200);

    final tasks = jsonDecode(response.body);

    expect(tasks.length, 1);
    expect(tasks[0]['title'], 'Study Python');

    mockClient.close();
  });
}
