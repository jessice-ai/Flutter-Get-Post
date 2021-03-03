
import 'package:flutter/material.dart';
class sunSearchContexts extends StatefulWidget{
  final arguments;
  sunSearchContexts({Key key, this.arguments}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunSearchContextsSon(arguments: this.arguments);
  }

}

class sunSearchContextsSon extends State{
  Map arguments;
  sunSearchContextsSon({this.arguments});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Scaffold(
      appBar: AppBar(
        title: Text("aaa"),
      ),
    );
  }

}