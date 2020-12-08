
import 'package:flutter/material.dart';

class sunCategoriesList extends StatefulWidget{

  final arguments;
  sunCategoriesList({Key key,this.arguments}) : super(key:key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunCategoriesListSon(arguments:this.arguments);
  }

}
class sunCategoriesListSon extends State{
  Map arguments;
  int _sunCatid;
  String _sunName;
  @override
  sunCategoriesListSon({this.arguments});
  Widget build(BuildContext context) {
    _sunCatid = this.arguments["catid"];
    _sunName = this.arguments["name"];
    print("${_sunCatid}");
    // TODO: implement build
    //throw UnimplementedError();

    return Scaffold(
      appBar: AppBar(
        title: Text("${_sunName}"),
      ),
      body: Text("${_sunCatid}"),
    );
  }

}