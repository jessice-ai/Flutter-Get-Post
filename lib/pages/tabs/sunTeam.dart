import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class sunTeam extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunTeamSon();
  }

}

class sunTeamSon extends State{
  int _sunUserID;
  List _sunMyTeams = [];
  String _sunLoading = "Loading...";
  ScrollController _scrollController = new ScrollController();


  //获取用户团队信息
  _sunGetMyTeams() async {
    Map sunJsonData = {"uid": _sunUserID};
    print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tbcouponseconday/teams",
        // ignore: missing_return
        data: sunJsonData)
    // ignore: missing_return
        .then((value) {
      if (value.data['code'] == 200) {
        //print("重置完${isReflash}");
        if (mounted) {
          setState(() {
            this._sunMyTeams = value.data['data'];
          });
        }
        //print("${this._secondaryCouponCate}");
      }else if(value.data['code'] == 500) {
        //命名路由跳转到某个页面
        Navigator.pushNamed(context, '/sunLogin');
      } else {
        if (mounted) {
          setState(() {
            //this._sunMyTeams = [];
            _sunLoading = "数据加载失败";
          });
        }
        //_sunToast("${value.data['message']}");
      }
    });
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
      this._sunUserID = intValue;
      _sunGetMyTeams(); //用户登陆之后，获取用户端对信息
    }else{
      //用户登陆
      //命名路由跳转到某个页面
      Navigator.pushNamed(context, '/sunLogin');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    print(_sunMyTeams.length);
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("我的团队"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: _sunMyTeams.length>0?_sunMyTeams.asMap().keys.map((e){
            return Column(
              children: [
                ListTile(
                  onTap: (){
                    //debugPrint("${e["nickname"]}");
                  },
                  leading: Icon(Icons.person),
                  title: Text(
                    "${_sunMyTeams[e]["nickname"]}",
                  ),
                ),
                Divider(
                  height: 1,
                  color: Colors.grey,
                ),
              ],
            );
          }).toList():[Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Center(
              child: Text("${_sunLoading}"),
            ),
          )],
        ) ,
      ),
    );
  }

}