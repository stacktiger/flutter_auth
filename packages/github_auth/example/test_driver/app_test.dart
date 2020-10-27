import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Github Auth App', () {
    final titleTextFinder = find.byValueKey('title');

    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('get title', () async {
      expect(await driver.getText(titleTextFinder), "Plugin example app");
    });
  });
}
