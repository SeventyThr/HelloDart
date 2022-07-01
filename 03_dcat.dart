// 命令行程序 （https://dart.dev/tutorials/server/cmdline）
//本教程介绍了一个名为dcat的小示例应用程序的详细信息，该应用程序显示命令行上列出的任何文件的内容。
//此应用程序使用命令行应用程序可用的各种类、函数和属性。
//有关应用程序关键功能的简要说明，请单击下面突出显示的代码。
import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';

const lineNumber = 'line-number';
//需要在终端处dart run 03_dcat.dart运行
void main(List<String> args) {
  exitCode = 0;
  final parser = ArgParser()..addFlag(lineNumber, negatable: false, abbr: 'n');

  ArgResults argResults = parser.parse(args);

  final paths = argResults.rest; // 剩余的命令行参数

  dcat(paths, showLineNumbers: argResults[lineNumber] as bool);
}

Future<void> dcat(List<String> paths, {bool showLineNumbers = false}) async {
  if (paths.isEmpty) {
    print('type exit to quit.');
    while (true) {
      stdout.write('> ');
      String? line = stdin.readLineSync();
      print('${line}\n');
      if (line?.toLowerCase() == 'Who') {
        print('I am Zheng');
      }
      if (line?.toLowerCase() == 'Nice') {
        print('Nice to meet you');
      }
      if (line?.toLowerCase() == 'exit') {
        print('goodbye,my friend.');
        break;
      }
    }
  } else {
    for (final path in paths) {
      var lineNumber = 1;
      final lines = utf8.decoder
          .bind(File(path).openRead())
          .transform(const LineSplitter());

      try {
        await for (final line in lines) {
          if (showLineNumbers) {
            stdout.write('${lineNumber++} ');
          }
          stdout.writeln(line);
        }
      } catch (_) {
        await _handleError(path);
      }
    }
  }
}

Future<void> _handleError(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.writeln('Error: $path is a directory.');
  } else {
    exitCode = 2;
  }
}
