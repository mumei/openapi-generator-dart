library test_external_path;

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

/// Test annotation with external path to verify error handling
@Openapi(
  generatorName: Generator.dart,
  inputSpec: InputSpec(path: '../../backend/admin/openapi.yaml'),
  outputDirectory: './test/specs/output-external',
  cachePath: './test/specs/output-external/cache.json',
)
class ExternalPathTestConfig extends OpenapiGeneratorConfig {}

/// Test annotation with deeply nested external path
@Openapi(
  generatorName: Generator.dart,
  inputSpec: InputSpec(path: '../../../some/deep/path/openapi.yaml'),
  outputDirectory: './test/specs/output-deep',
  cachePath: './test/specs/output-deep/cache.json',
)
class DeepPathTestConfig extends OpenapiGeneratorConfig {}

/// Test annotation with valid internal path for comparison
@Openapi(
  generatorName: Generator.dart,
  inputSpec: InputSpec(path: './test/specs/openapi.test.yaml'),
  outputDirectory: './test/specs/output-internal',
  cachePath: './test/specs/output-internal/cache.json',
)
class ValidPathTestConfig extends OpenapiGeneratorConfig {}