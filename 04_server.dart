// 静态服务器 （https://github.com/dart-lang/samples/blob/master/server/simple/bin/server.dart）

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:shelf_static/shelf_static.dart' as shelf_static;

//  快捷操作符 (https://blog.csdn.net/nimeghbia/article/details/100921620)
Future main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8081');

  // 将请求按顺序转发给好几个处理器，链式地返回第一个能够正确处理该请求的响应
  final cascade = Cascade().add(_staticHandler).add(_router);

  // 启动一个 HTTP 服务
  final server = await shelf_io.serve(
      logRequests().addHandler(cascade.handler), // 使用一个记录日志的中间件
      InternetAddress.anyIPv4,
      port);

  print(
      'Serving at http://${server.address.host}:${server.port}, CTRL+C to stop.');
}

final _staticHandler =
    shelf_static.createStaticHandler('public', defaultDocument: 'index.html');

// 将不同地址路由到对应的类
final _router = shelf_router.Router()
  ..get('/YNU', _helloWorldHandler)
  ..get(
    '/time',
    (request) => Response.ok(DateTime.now().toUtc().toIso8601String()),
  )
  ..get('/del/<a|[0-9]+>/<b|[0-9]+>', _mulHandler); // 正则表达式把动态转为静态，静态时会有缓存，提高访问速度

Response _helloWorldHandler(Request request) => Response.ok('YNU');

// 将两个数相减的处理器
Response _mulHandler(request, String a, String b) {
  final aNum = int.parse(a);
  final bNum = int.parse(b);
  return Response.ok(
    const JsonEncoder.withIndent(' ')
        .convert({'a': aNum, 'b': bNum, 'del': aNum - bNum}),
    headers: {
      // 设置一些头信息，声明存活时间
      'content-type': 'application/json',
      'Cache-Control': 'public, max-age=604800',
    },
  );
}
