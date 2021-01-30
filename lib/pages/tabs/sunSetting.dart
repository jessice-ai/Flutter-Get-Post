
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class sunSetting extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunSettingSon();
  }

}

class sunSettingSon extends State{
  _sunClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); //初始化
    //prefs.clear();//全部删除
    prefs.remove('sunEmail'); //删除指定key键
    prefs.remove('sunPhone'); //删除指定key键
    prefs.remove('sunNickname'); //删除指定key键
    prefs.remove('sunAvailable_quota'); //删除指定key键
    prefs.remove('sunId'); //删除指定key键
    //命名路由跳转到某个页面
    Navigator.pushNamed(context, '/sunLogin');
    //命名路由跳转到某个页面
    //     var sunEmail = prefs.getString("sunEmail");
    //     var sunPhone =  prefs.getString("sunPhone");
    //     var sunNickname = prefs.getString("sunNickname");
    //     var sunAvailable_quota =  prefs.getString("sunAvailable_quota");
    //     var sunId =  prefs.getInt("sunId");
    //     setState(() {
    //       testList = [];
    //     });
  }
  @override
  Widget build(BuildContext context) {

    // TODO: implement build


    //throw UnimplementedError();
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "设置"
        ),
      ),
      body: Column(
        children: [

          ListTile(
            onTap: () {
              _sunClear();
              //debugPrint("Tapped Log Out");
            },
            leading: Icon(Icons.exit_to_app),
            title: Text("退出"),
          ),
        ],
      ),
    );
  }

}
