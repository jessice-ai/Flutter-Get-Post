
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:date_format/date_format.dart';

class sunIncomeBreakdown extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunIncomeBreakdownSon();
  }
}
class sunIncomeBreakdownSon extends State{
  int _sunUserID;
  List _sunBreakdown = [];
  bool isReflash = false;
  String _sunLoading = "Loading...";
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();
  @override
  void initState() {
    super.initState();
    //验证用户登陆状态
    initFromCache().then((result) {
      this._sunUserID = result;
      _sunGetIncomeBreakdown(); //用户收益明细,列表
    });
  }
  //用户收益明细,列表
  _sunGetIncomeBreakdown() async {
    if(mounted){
      setState(() {
        isReflash = false;
      });
    }
    //只有用户登陆状态判断过了才能返回数据
    Map sunJsonData = {"uid": _sunUserID};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio.post(
        "https://www.shsun.xyz/tb/Incomebreakdown",
        data: sunJsonData);

    //print("数据:${sunResponse.data['data']}");
    if (sunResponse.data['code'] == 200) {
      if(mounted){
        setState(() {
          _sunBreakdown = sunResponse.data['data'];
        });
      }
    } else {
      _sunLoading = "暂时没有交易明细";
      return [];
      //_sunToast("网络请求异常Cate! ${sunResponse.data['message']}");
    }
  }

  //获取用户登陆数据
  initFromCache() async {
    SharedPreferences prefs = await _sunPrefs;
    int intValue = prefs.getInt("sunId"); //获取用户登陆ID
    //print("${intValue}");
    // ignore: unrelated_type_equality_checks
    if (intValue != "" && intValue != null) {
      return intValue;
    }else{
      //用户登陆
      //命名路由跳转到某个页面
      Navigator.pushNamed(context, '/sunLogin');
    }
  }
  //下拉刷新，函数
  Future<void> _onRefresh() async {
    //print('执行刷新');
    isReflash = true;
    //刷新数据
    this._sunGetIncomeBreakdown();
    //给3秒刷新数据时间
    await Future.delayed(Duration(seconds: 3), () {
      //print('refresh');
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Scaffold(
      appBar: AppBar(
        title: Text("收入明细"),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Container(
            //color: Colors.blue,
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      /**
                       * 纵轴
                       * stretch 纵轴部分，拉伸占满整个屏幕
                       * center 整体纵轴居中
                       * end 整体纵轴底部显示
                       * start 整体纵轴顶部显示
                       */
                      crossAxisAlignment: CrossAxisAlignment.center,
                      /**
                       * 横轴
                       * spaceEvenly 元素与元素之间，元素与边框之间距离平均，常用
                       * center 水平方向整体居中
                       * end 整体右侧显示
                       * start 整体左侧显示
                       * spaceAround 多个元素中间空隙平均
                       * spaceBetween 左边边上没有距离，其他的空白部分平均
                       */
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Colors.cyan,
                            height: 48.0,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text("类目",
                                textAlign: TextAlign.center,
                                style:TextStyle(
                                  //fontWeight: FontWeight.bold, //加粗
                                    fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                    color:Colors.white //颜色使用Colors组件，设置系统自带的颜色
                                  //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                )
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: Colors.cyan,
                            height: 48.0,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text("关系",
                                textAlign: TextAlign.center,
                                style:TextStyle(
                                  //fontWeight: FontWeight.bold, //加粗
                                    fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                    color:Colors.white //颜色使用Colors组件，设置系统自带的颜色
                                  //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                )
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: Colors.cyan,
                            height: 48.0,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text("预估收益",
                                textAlign: TextAlign.center,
                                style:TextStyle(
                                  //fontWeight: FontWeight.bold, //加粗
                                    fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                    color:Colors.white //颜色使用Colors组件，设置系统自带的颜色
                                  //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                )
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Colors.cyan,
                            height: 48.0,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text("时间",
                                textAlign: TextAlign.center,
                                style:TextStyle(
                                  //fontWeight: FontWeight.bold, //加粗
                                    fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                    color:Colors.white //颜色使用Colors组件，设置系统自带的颜色
                                  //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                )
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: Colors.cyan,
                            height: 48.0,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text("状态",
                                textAlign: TextAlign.center,
                                style:TextStyle(
                                  //fontWeight: FontWeight.bold, //加粗
                                    fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                    color:Colors.white //颜色使用Colors组件，设置系统自带的颜色
                                  //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                )
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Column(
                  children: this._sunBreakdown.length>0?this._sunBreakdown.map((e){
                    var str = "";
                    if(e["level"]==1){
                      str="自己购物";
                    }else{
                      str="下级购物";
                    }
                    return Column(
                      children: [
                        Row(
                          /**
                           * 纵轴
                           * stretch 纵轴部分，拉伸占满整个屏幕
                           * center 整体纵轴居中
                           * end 整体纵轴底部显示
                           * start 整体纵轴顶部显示
                           */
                          crossAxisAlignment: CrossAxisAlignment.center,
                          /**
                           * 横轴
                           * spaceEvenly 元素与元素之间，元素与边框之间距离平均，常用
                           * center 水平方向整体居中
                           * end 整体右侧显示
                           * start 整体左侧显示
                           * spaceAround 多个元素中间空隙平均
                           * spaceBetween 左边边上没有距离，其他的空白部分平均
                           */
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 48.0,
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Text("${e["item_category_name"]}",
                                    textAlign: TextAlign.center,
                                    style:TextStyle(
                                      //fontWeight: FontWeight.bold, //加粗
                                      fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                      //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                    )
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 48.0,
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Text("${str}",
                                    textAlign: TextAlign.center,
                                    style:TextStyle(
                                      //fontWeight: FontWeight.bold, //加粗
                                      fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                      //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                    )
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 48.0,
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Text("${e["commission"]}",
                                    textAlign: TextAlign.center,
                                    style:TextStyle(
                                      //fontWeight: FontWeight.bold, //加粗
                                      fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                      //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                    )
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 48.0,
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Text(formatDate(DateTime.parse(e["created_at"]) ,[mm,'-',dd," ",HH,":",nn]),
                                    textAlign: TextAlign.center,
                                    style:TextStyle(
                                      //fontWeight: FontWeight.bold, //加粗
                                      fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                      //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                    )
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 48.0,
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Text("${e["tk_status_name"]}",
                                    textAlign: TextAlign.center,
                                    style:TextStyle(
                                      //fontWeight: FontWeight.bold, //加粗
                                      fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                      //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                    )
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 1.0,color: Colors.black12,),
                      ],
                    );

                  }).toList():[
                    Container(
                      height: MediaQuery.of(context).size.height-130,
                      child: Center(
                        child: Text("${_sunLoading}"),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}