import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' show relative;
import 'package:yaml/yaml.dart' show loadYaml;

import '../libs/config.dart' show Config;

Future main(List<String> args) async {
  // Set arguments parser
  final parser = new ArgParser()
    ..addOption('config', defaultsTo: relative('config.yml'), abbr: 'c')
    ..addFlag('download', abbr: 'd');

  // Parse arguments
  final ArgResults params = parser.parse(args);

  // Load config
  final File file = new File(params['config']);
  if (await file.exists() == false) throw "Config file doesn't exist";

  // Init rsync wrapper and run commands
  final Config config = new Config(loadYaml(await file.readAsString()));
  config.schemeOptions(params['download']).forEach((options) {
    Process.start('rsync', options).then((Process process) {
      process.stdout.transform(UTF8.decoder).listen((data) => print(data));
    });
  });
}
