import 'package:flutter/material.dart';

class sunDialog extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunDialogSon();
  }
}

class sunDialogSon extends State{
  _alertDialog() async{
    var sunResult = await showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("提示信息"),
            content: Text("您确定要删除吗?"),
            actions: <Widget>[
              FlatButton(
                  child: Text("取消"),
                  onPressed: (){
                    print("取消");
                    Navigator.pop(context,"Cancle"); //关闭并传回来值
                  },
              ),
              FlatButton(
                child: Text("确定"),
                onPressed: (){
                  print("确定");
                  Navigator.pop(context,"Ok"); //关闭并传回来值
                },
              ),
            ],
          );
        }
    );
    print(sunResult);
  }
  _simpleDialog() async{
      var result = await showDialog(
        context: context,
        builder: (context){
          return SimpleDialog(
            title: Text("请选择"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Option A"),
                onPressed: (){
                  print("Option AA");
                  Navigator.pop(context,"A");  //关闭并传回来值
                },
              ),
              Divider(),
              SimpleDialogOption(
                child: Text("Option B"),
                onPressed: (){
                  print("Option BB");
                  Navigator.pop(context,"B"); //关闭并传回来值
                },
              ),
              Divider(),
              SimpleDialogOption(
                child: Text("Option C"),
                onPressed: (){
                  print("Option CC");
                  Navigator.pop(context,"C");  //关闭并传回来值
                },
              ),
              Divider(),
              SimpleDialogOption(
                child: Text("Option D"),
                onPressed: (){
                  print("Option DD");
                  Navigator.pop(context,"D");  //关闭并传回来值
                },
              )
            ],
          );
        }
      );
      print("result:"+result);
  }

  _sunShowModalBottomSheet() async{
    var result = await showModalBottomSheet(
      context:context,
      builder: (context){
        return Container(
          height: 260, //设置高度
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text("分享A"),
                onTap: (){
                  Navigator.pop(context,"A"); //关闭并传回来值
                },
              ),
              Divider(),
              ListTile(
                title: Text("分享B"),
                onTap: (){
                  Navigator.pop(context,"B"); //关闭并传回来值
                },
              ),
              Divider(),
              ListTile(
                title: Text("分享C"),
                onTap: (){
                  Navigator.pop(context,"C"); //关闭并传回来值
                },
              ),
              Divider(),
            ],
          ),
        );
      }
    );
    print(result);
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Scaffold(
      //appBar 导航
      appBar: AppBar(
        title: Text(
            "Dialog"
        ),
      ),
      //body 主体
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton(
              child: Text("alert弹出层-AlertDialog"),
              onPressed:_alertDialog
          ),
          RaisedButton(
              child: Text("alert弹出层-simpleDialog"),
              onPressed:_simpleDialog
          ),
          RaisedButton(
              child: Text("alert弹出层-showModalBottomSheet"),
              onPressed:_sunShowModalBottomSheet
          ),
        ],
      )
    );
  }

}