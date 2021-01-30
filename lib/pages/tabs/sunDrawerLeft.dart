
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class sunDrawerLeft extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunDrawerLeftSon();
  }

}
class sunDrawerLeftSon extends State{
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();
  int _sunUserID;
  List _secondaryCouponCate = []; //二级分类
  List _sonCate = [];
  String _sunLoadingData = "Loading...";
  bool sunLoginStatus = false;

  //获取用户登陆数据
  void initFromCache() async {
    SharedPreferences prefs = await _sunPrefs;
    int intValue = prefs.getInt("sunId"); //获取用户登陆ID
    this._sunUserID = intValue;
    this.sunLoginStatus = true;
    //intValue = 0;
    // ignore: unrelated_type_equality_checks
    if (intValue != "" && intValue != null) {
      this._sunUserID = intValue;
      _sunSecondaryColumn(catid: 6);  //初始化热门推荐
    } else {
      //命名路由跳转到某个页面
      Navigator.pushNamed(context, '/sunLogin');
    }
  }
  @override
  void initState() {
    super.initState();
    initFromCache();
  }
  //获取二级分类
  _sunSecondaryColumn({catid = 0}) async {
    Map sunJsonData = {"catid": catid, "uid": _sunUserID};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tbcouponseconday/secla",
        // ignore: missing_return
        data: sunJsonData)
    // ignore: missing_return
        .then((value) {
      if (value.data['code'] == 200) {
        //print("数据:${sunResponse.data['data']}");
        if (mounted) {
          setState(() {
            this._secondaryCouponCate = value.data['data'];
          });
        }
        //print("${this._secondaryCouponCate}");
      } else {
        if (mounted) {
          setState(() {
            _sunLoadingData = "暂时没有数据";
            this._secondaryCouponCate = [];
          });
        }
        //_sunToast("${value.data['message']}");
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Drawer(     //侧边栏按钮Drawer
      child: new ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(   //Material内置控件
            accountName: new Text('夜市',
                style:TextStyle(
                    fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                    color:Colors.white //颜色使用Colors组件，设置系统自带的颜色
                  //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                )
            ), //用户名
            accountEmail: new Text(
                '邮箱:jessicesun@gmail.com',
                style:TextStyle(
                    fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                    color:Colors.white //颜色使用Colors组件，设置系统自带的颜色
                  //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                )
            ),  //用户邮箱
            currentAccountPicture: new GestureDetector( //用户头像
              //onTap: () => print('current user'),
              child: new CircleAvatar(
                backgroundColor: Colors.white,//圆形图标控件
                backgroundImage: new NetworkImage('https://www.shsun.xyz/images/logo.jpg'),//图片调取自网络
              ),
            ),
            // otherAccountsPictures: <Widget>[    //粉丝头像
            //   new GestureDetector(    //手势探测器，可以识别各种手势，这里只用到了onTap
            //     onTap: () => print('other user'), //暂且先打印一下信息吧，以后再添加跳转页面的逻辑
            //     child: new CircleAvatar(
            //       backgroundImage: new NetworkImage('https://img.alicdn.com/bao/uploaded/i1/1755465524/O1CN01Pm1kC51qg2Q32t7pd_!!1755465524.jpg'),
            //     ),
            //   ),
            //   new GestureDetector(
            //     onTap: () => print('other user'),
            //     child: new CircleAvatar(
            //       backgroundImage: new NetworkImage('https://upload.jianshu.io/users/upload_avatars/8346438/e3e45f12-b3c2-45a1-95ac-a608fa3b8960?imageMogr2/auto-orient/strip|imageView2/1/w/240/h/240'),
            //     ),
            //   ),
            //   new GestureDetector(
            //     onTap: () => print('other user'),
            //     child: new CircleAvatar(
            //       backgroundImage: new NetworkImage('https://upload.jianshu.io/users/upload_avatars/8346438/e3e45f12-b3c2-45a1-95ac-a608fa3b8960?imageMogr2/auto-orient/strip|imageView2/1/w/240/h/240'),
            //     ),
            //   ),
            //   new GestureDetector(
            //     onTap: () => print('other user'),
            //     child: new CircleAvatar(
            //       backgroundImage: new NetworkImage('https://upload.jianshu.io/users/upload_avatars/8346438/e3e45f12-b3c2-45a1-95ac-a608fa3b8960?imageMogr2/auto-orient/strip|imageView2/1/w/240/h/240'),
            //     ),
            //   ),
            //   new GestureDetector(
            //     onTap: () => print('other user'),
            //     child: new CircleAvatar(
            //       backgroundImage: new NetworkImage('https://upload.jianshu.io/users/upload_avatars/8346438/e3e45f12-b3c2-45a1-95ac-a608fa3b8960?imageMogr2/auto-orient/strip|imageView2/1/w/240/h/240'),
            //     ),
            //   ),
            // ],
            decoration: new BoxDecoration(    //用一个BoxDecoration装饰器提供背景图片
              image: new DecorationImage(
                fit: BoxFit.fill,
                // image: new NetworkImage('https://raw.githubusercontent.com/flutter/website/master/_includes/code/layout/lakes/images/lake.jpg')
                //可以试试图片调取自本地。调用本地资源，需要到pubspec.yaml中配置文件路径
                image: new NetworkImage('http://5b0988e595225.cdn.sohucs.com/images/20180605/a3b922ac0b2d4bdc993b5b6606456a1d.jpeg'),
              ),
            ),
          ),
          new ListTile(   //第一个功能项
              title: new Text('热门推荐'),
              //trailing: new Icon(Icons.list),
              onTap: () {
                //Navigator.of(context).pop();
                //Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new SidebarPage()));
              }
          ),
          Column(
            children: _secondaryCouponCate.length>0?_secondaryCouponCate.map((e){
              _sonCate = e["son"];
              //print(_sonCate);
              return Column(
                children: _sonCate.length>0?_sonCate.map((value){
                  var index =
                      _sonCate.indexOf(e) + 1;
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {
                          //命名路由传值跳转到栏目列表页
                          Navigator.pushNamed(
                              context,
                              '/suncatlist',
                              arguments: {
                                "catid": value["pid"],
                                "name":
                                e["name"],
                                "soncatid":
                                value["id"],
                                "_tabSunControllerInt":
                                index
                              });
                          //命名路由跳转到某个页面
                          //Navigator.pushNamed(context, '/sunTeam');
                          //debugPrint("我的团队");
                        },
                        //leading: Icon(Icons.list),
                        trailing: new Icon(Icons.arrow_forward_ios_sharp,size: 14.0,),
                        title: Text("${value["name"]}"),
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey,
                      ),
                    ],
                  );
                }).toList():[],
              );
              _sonCate.length>0?_sonCate.map((value){
                return Column(
                  children: [
                    Text("${value["name"]}"),
                    new Divider(),    //分割线控件
                  ],
                );
              }).toList():[];
            }).toList():[],
          )
          // new ListTile(   //第二个功能项
          //     title: new Text('Second Page'),
          //     trailing: new Icon(Icons.arrow_right),
          //     onTap: () {
          //       Navigator.of(context).pop();
          //       //Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new SidebarPage()));
          //     }
          // ),
          // new ListTile(   //第二个功能项
          //     title: new Text('Second Page'),
          //     trailing: new Icon(Icons.arrow_right),
          //     onTap: () {
          //       Navigator.of(context).pop();
          //       Navigator.of(context).pushNamed('/a');
          //     }
          // ),

          // new ListTile(   //退出按钮
          //   title: new Text('Close'),
          //   trailing: new Icon(Icons.cancel),
          //   onTap: () => Navigator.of(context).pop(),   //点击后收起侧边栏
          // ),
        ],
      ),
    );
  }

}