import 'dart:io';
import 'package:safecheck_server/src/common/links.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  const path = '/t/mock-token-from-this-database';
  test(
    'production uses exactly its configured HTTPS origin and existing token',
    () {
      for (final host in [
        'safecheck.serverpod.space',
        'another-deployment.example',
      ]) {
        expect(
          configuredPublicWebUrl(
            origin: Uri.parse('https://$host'),
            path: path,
            runMode: 'production',
          ),
          'https://$host$path',
        );
      }
    },
  );
  test('production never falls back to localhost or a relative link', () {
    for (final origin in <Uri?>[
      null,
      Uri.parse('http://localhost:8082'),
      Uri.parse('https://localhost'),
      Uri.parse('https://sub.localhost'),
      Uri.parse('https://127.0.0.1'),
      Uri.parse('https://[::1]'),
      Uri.parse('https://10.0.0.1'),
      Uri.parse('http://safecheck.serverpod.space'),
    ]) {
      expect(
        () => configuredPublicWebUrl(
          origin: origin,
          path: path,
          runMode: 'production',
        ),
        throwsStateError,
      );
    }
  });
  test('development link keeps local origin and token unchanged', () {
    expect(
      configuredPublicWebUrl(
        origin: Uri.parse('http://localhost:8082'),
        path: path,
        runMode: 'development',
      ),
      'http://localhost:8082$path',
    );
  });
  test('checked-in production YAML has a usable public HTTPS web origin', () {
    final file = File('config/production.yaml').existsSync()
        ? File('config/production.yaml')
        : File('safecheck_server/config/production.yaml');
    final web =
        (loadYaml(file.readAsStringSync()) as YamlMap)['webServer'] as YamlMap;
    final origin = Uri(
      scheme: web['publicScheme'] as String,
      host: web['publicHost'] as String,
      port: web['publicPort'] as int,
    );
    expect(
      configuredPublicWebUrl(origin: origin, path: path, runMode: 'production'),
      'https://safecheck.serverpod.space$path',
    );
  });
}
