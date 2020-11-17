import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'dart:developer' as developer;
import 'dart:async';

// ignore: public_member_api_docs
class FlutterAuthWebview extends StatefulWidget {
  final String url;
  final String redirectUrl;
  final bool clearCache;
  final String title;
  final String userAgent;
  final bool modal;

  // ignore: public_member_api_docs
  const FlutterAuthWebview(
      {Key key,
      @required this.url,
      @required this.redirectUrl,
      this.userAgent,
      this.clearCache = true,
      this.modal = false,
      this.title = ""})
      : super(key: key);

  @override
  State createState() => _FlutterAuthWebviewState();
}

class _FlutterAuthWebviewState extends State<FlutterAuthWebview> {
  final FlutterWebviewPlugin _wv = FlutterWebviewPlugin();

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;

  StreamSubscription<WebViewHttpError> _onHttpError;

  static const String _userAgentMacOSX =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36";

  @override
  void initState() {
    super.initState();
    _onHttpError = _wv.onHttpError.listen((httpError) {
      Uri httpErrorUri = Uri.parse(httpError.url);
      if (httpErrorUri.host == (Uri.parse(widget.redirectUrl)).host) {
        //skip
        return;
      }

      _wv.close();
      Navigator.of(context).pop(httpError);
    });

    _onUrlChanged = _wv.onUrlChanged.listen((url) {
      developer.log('onUrlChanged $url');
      if (url.startsWith(widget.redirectUrl)) {
        // success, return result
        _wv.close();
        Navigator.of(context).pop(url.toString());
      } else if (url.contains("error=")) {
        _wv.close();
        // throw exception
        Navigator.of(context)
            .pop(Exception(Uri.parse(url).queryParameters["error"]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget.url,
      appBar: new AppBar(
        leading: widget.modal ? backButton(context) : null,
        title: Text(widget.title),
      ),
      userAgent: widget.userAgent ?? _userAgentMacOSX,
      withZoom: false,
      withLocalStorage: false,
      withJavascript: true,
      hidden: true,
      clearCache: widget.clearCache,
      clearCookies: widget.clearCache,
      resizeToAvoidBottomInset: true,
    );
  }

  Widget backButton(BuildContext context) {
    IconButton(
      icon: Icon(Icons.close),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  void dispose() {
    _onHttpError.cancel();
    _onUrlChanged.cancel();
    _wv.close();
    _wv.dispose();

    super.dispose();
  }
}
