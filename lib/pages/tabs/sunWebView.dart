import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class sunWebView extends StatefulWidget{
  final arguments;
  sunWebView({Key key, this.arguments}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunWebViewSon(arguments: this.arguments);
  }

}

class sunWebViewSon extends State{
  String _url;
  Map arguments;
  sunWebViewSon({this.arguments});
  @override
  Widget build(BuildContext context) {
    _url = this.arguments["url"];
    // TODO: implement build
    //throw UnimplementedError();
    return Scaffold(
      appBar: AppBar(
        title: Text("aaa"),
      ),
      body: WebView(
        initialUrl: _url,
        //JS执行模式 是否允许JS执行
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }

}