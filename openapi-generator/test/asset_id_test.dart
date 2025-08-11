import 'package:build/build.dart';
import 'package:test/test.dart';

/// Test to verify AssetId behavior with external paths
void main() {
  group('AssetId External Path Handling', () {
    test('AssetId throws error for paths outside package', () {
      // This test verifies the behavior we're handling in the try-catch
      expect(
        () => AssetId('test_package', '../../backend/admin/openapi.yaml'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('AssetId works fine with valid relative paths', () {
      expect(
        () => AssetId('test_package', 'lib/test.dart'),
        returnsNormally,
      );
    });

    test('AssetId works fine with valid paths in subdirectories', () {
      expect(
        () => AssetId('test_package', 'specs/openapi.yaml'),
        returnsNormally,
      );
    });

    test('AssetId throws error for deeply nested external paths', () {
      expect(
        () => AssetId('test_package', '../../../some/deep/path/openapi.yaml'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}