import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class sunToast extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunToastSon();
  }


}
class sunToastSon extends State{

  _sunToast(){
    Fluttertoast.showToast(
        msg: "提示信息",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, //提示信息展示位置
        timeInSecForIos: 10, //显示时间，这个只在IOS上有效，android 是默认时间
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Scaffold(
      appBar: AppBar(
        title: Text("sunToastSon"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  child: Text("按钮"),
                  onPressed: _sunToast,
                )
              ],
            )
        ],
      ),
    );
  }

}