import 'dart:convert';
import 'dart:io';

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';
import 'package:test/test.dart';

import 'utils.dart';
import 'utils.mocks.dart';

/// Tests for handling external paths (outside package boundaries)
void main() {
  group('External Path Handling', () {
    late String testOutputPath;
    late File cacheFile;
    var mockProcess = MockProcessRunner();

    setUpAll(() {
      testOutputPath = '${testSpecPath}external-path-output';
      cacheFile = File('$testOutputPath/cache.json');
    });

    setUp(() {
      if (!Directory(testOutputPath).existsSync()) {
        Directory(testOutputPath).createSync(recursive: true);
      }
      if (!cacheFile.existsSync()) {
        cacheFile.createSync(recursive: true);
      }
      cacheFile.writeAsStringSync(jsonEncode({'test': 'cache'}));
    });

    tearDown(() {
      if (Directory(testOutputPath).existsSync()) {
        Directory(testOutputPath).deleteSync(recursive: true);
      }
    });

    test('handles relative path going outside package without throwing error', () async {
      var annotation = Openapi(
        generatorName: Generator.dart,
        inputSpec: InputSpec(path: '../../backend/admin/openapi.yaml'),
        cachePath: '${cacheFile.path}',
        outputDirectory: testOutputPath,
      );

      // This should not throw an "Invalid argument" error
      var output = await generateFromAnnotation(annotation, process: mockProcess);
      
      // Should not contain the error message
      expect(output, isNot(contains('Invalid argument')));
      expect(output, isNot(contains('Asset paths may not reach outside the package')));
      
      // Should show warning about build.yaml configuration instead
      expect(output, contains('This is needed for this package to monitor changes to the spec file.'));
    });

    test('handles deeply nested relative path without error', () async {
      var annotation = Openapi(
        generatorName: Generator.dart,
        inputSpec: InputSpec(path: '../../../some/deep/path/openapi.yaml'),
        cachePath: '${cacheFile.path}',
        outputDirectory: testOutputPath,
      );

      var output = await generateFromAnnotation(annotation, process: mockProcess);
      
      expect(output, isNot(contains('Invalid argument')));
      expect(output, isNot(contains('Asset paths may not reach outside the package')));
    });

    test('handles parent directory references without error', () async {
      var annotation = Openapi(
        generatorName: Generator.dart,
        inputSpec: InputSpec(path: '../../openapi.yaml'),
        cachePath: '${cacheFile.path}',
        outputDirectory: testOutputPath,
      );

      var output = await generateFromAnnotation(annotation, process: mockProcess);
      
      expect(output, isNot(contains('Invalid argument')));
      expect(output, isNot(contains('Asset paths may not reach outside the package')));
    });

    test('still works normally with valid relative paths', () async {
      // Create a test spec file within the package
      final validSpecFile = File('${testSpecPath}valid_spec.yaml');
      validSpecFile.writeAsStringSync('''
openapi: 3.0.0
info:
  title: Test API
  version: 1.0.0
paths:
  /test:
    get:
      responses:
        '200':
          description: OK
''');

      var annotation = Openapi(
        generatorName: Generator.dart,
        inputSpec: InputSpec(path: 'test/specs/valid_spec.yaml'),
        cachePath: '${cacheFile.path}',
        outputDirectory: testOutputPath,
      );

      var output = await generateFromAnnotation(annotation, process: mockProcess);
      
      expect(output, isNot(contains('Invalid argument')));
      expect(output, contains('Openapi generator completed successfully.'));
      
      // Clean up
      if (validSpecFile.existsSync()) {
        validSpecFile.deleteSync();
      }
    });
  });
}