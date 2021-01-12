import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';

import 'package:flutter/material.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';



class sunMy extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State with SingleTickerProviderStateMixin {
  FSBStatus drawerStatus;

  @override
  Widget build(BuildContext context) {
    return SafeArea(

      child: Scaffold(

        body: FoldableSidebarBuilder(
          drawerBackgroundColor: Colors.deepOrange,
          drawer: CustomDrawer(closeDrawer: (){
            setState(() {
              drawerStatus = FSBStatus.FSB_CLOSE;
            });
          },),
          screenContents: FirstScreen(),
          status: drawerStatus,
        ),
        floatingActionButton: FloatingActionButton(
            heroTag: 'other',
            backgroundColor: Colors.deepOrange,
            child: Icon(Icons.menu,color: Colors.white,),
            onPressed: () {
              setState(() {
                drawerStatus = drawerStatus == FSBStatus.FSB_OPEN ? FSBStatus.FSB_CLOSE : FSBStatus.FSB_OPEN;
              });
            }),
      ),
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal.withAlpha(200),
      child: Center(child: Text("Click on FAB to Open Drawer",style: TextStyle(fontSize: 20,color: Colors.white),),),
    );
  }
}


class CustomDrawer extends StatefulWidget {
  final Function closeDrawer;
  //退出操作
  const CustomDrawer({Key key, this.closeDrawer}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return CustomDrawerSon(closeDrawer: this.closeDrawer);
  }
}
class CustomDrawerSon extends State with SingleTickerProviderStateMixin{
  final Function closeDrawer;
  CustomDrawerSon({this.closeDrawer});

  _sunClear() async{
    SharedPreferences prefs=await SharedPreferences.getInstance(); //初始化
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

  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();


  @override
  void initState() {
    super.initState();
    initFromCache();
  }
  //获取用户登陆数据
  initFromCache() async {
    SharedPreferences prefs = await _sunPrefs;
    int intValue = prefs.getInt("sunId"); //获取用户登陆ID
    //print("${intValue}");
    if (intValue != "" && intValue != null) {
      return intValue;
    }else{
      //用户登陆
      //命名路由跳转到某个页面
      Navigator.pushNamed(context, '/sunLogin');
    }
  }
  @override
  Widget build(BuildContext context) {

    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Container(
      color: Colors.white,
      width: mediaQuery.size.width * 0.60,
      height: mediaQuery.size.height,
      child: Column(
        children: <Widget>[
          Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey.withAlpha(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/images/logo.png",
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("RetroPortal Studio")
                ],
              )),
          // ListTile(
          //   onTap: (){
          //     debugPrint("Tapped Profile");
          //   },
          //   leading: Icon(Icons.person),
          //   title: Text(
          //     "Your Profile",
          //   ),
          // ),
          // Divider(
          //   height: 1,
          //   color: Colors.grey,
          // ),
          ListTile(
            onTap: () {
              //命名路由跳转到某个页面
              Navigator.pushNamed(context, '/sunBreakdown');
            },
            leading: Icon(Icons.list),
            title: Text("收入明细"),
          ),
          Divider(
            height: 1,
            color: Colors.grey,
          ),
          ListTile(
            onTap: () {
              //命名路由跳转到某个页面
              Navigator.pushNamed(context, '/sunTeam');
              //debugPrint("我的团队");
            },
            leading: Icon(Icons.category),
            title: Text("我的团队"),
          ),
          Divider(
            height: 1,
            color: Colors.grey,
          ),
          ListTile(
            onTap: () {
              debugPrint("Tapped Payments");
            },
            leading: Icon(Icons.payment),
            title: Text("支付信息"),
          ),
          Divider(
            height: 1,
            color: Colors.grey,
          ),
          ListTile(
            onTap: () {
              debugPrint("规则说明");
            },
            leading: Icon(Icons.notifications),
            title: Text("规则说明"),
          ),
          Divider(
            height: 1,
            color: Colors.grey,
          ),
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
// class sunMy extends StatefulWidget{
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     //throw UnimplementedError();
//     return sunMySon();
//   }
//
// }
//
// class sunMySon extends State{
//   //获取数据
//   void initFromCache() async {
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     var sunEmail = prefs.getString("sunEmail");
//     var sunPhone =  prefs.getString("sunPhone");
//     var sunNickname = prefs.getString("sunNickname");
//     var sunAvailable_quota =  prefs.getString("sunAvailable_quota");
//     var sunId =  prefs.getInt("sunId");
//
//     print("持久化数据邮箱-:${sunEmail}");
//     print("持久化数据手机:${sunPhone}");
//     print("持久化数据昵称:${sunNickname}");
//     print("持久化数据额度:${sunAvailable_quota}");
//     print("持久化数据uid:${sunId}");
//
//   }
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     //throw UnimplementedError();
//     initFromCache();
//     return Container(
//       child: Column(
//         children: [
//           RaisedButton(
//             child: Text("注册"),
//             onPressed: (){
//               //命名路由跳转到某个页面
//               Navigator.pushNamed(context, '/sunRegister');
//             },
//             color: Theme.of(context).accentColor, //颜色主题
//             textTheme: ButtonTextTheme.primary, //文本主题
//           ),
//           RaisedButton(
//             child: Text("登陆"),
//             onPressed: (){
//               //命名路由跳转到某个页面
//               Navigator.pushNamed(context, '/sunLogin');
//             },
//             color: Theme.of(context).accentColor, //颜色主题
//             textTheme: ButtonTextTheme.primary, //文本主题
//           )
//         ],
//       ),
//
//     );
//   }
//
// }