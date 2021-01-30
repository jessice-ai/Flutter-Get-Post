
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:date_format/date_format.dart';

class sunWithdrawalsRecord extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunWithdrawalsRecordSon();
  }

}
class sunWithdrawalsRecordSon extends State{
  ScrollController _scrollController = new ScrollController();
  int _sunUserID;
  List _sunBreakdown = [];
  int _sunPage = 1;
  bool isLoading = false;
  bool isReflash = false;
  String _sunLoading = "Loading...";
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();
  @override
  void initState() {
    super.initState();
    //验证用户登陆状态
    initFromCache().then((result) {
      this._sunUserID = result;
      _sunGetIncomeBreakdown(); //提现记录列表
    });
    /**
     * 侦听滚动事件
     */
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        this._sunPage++;
        _sunGetIncomeBreakdown(); //提现记录列表
      }
    });
  }
  // ignore: must_call_super
  void dispose() {
    super.dispose();
    _scrollController.dispose(); //销魂滚动控件
  }
  //用户收益明细,列表
  _sunGetIncomeBreakdown() async {
    if (isReflash == true) {
      this._sunPage = 1;
    }
    if(mounted){
      setState(() {
        isLoading = true;
        _sunLoading = "数据加载中";
      });
    }
    //只有用户登陆状态判断过了才能返回数据
    Map sunJsonData = {"uid": _sunUserID,"page":_sunPage};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio.post(
        "https://www.shsun.xyz/tb/listrecord",
        data: sunJsonData);
    //print("数据:${sunResponse.data['data']}");
    if (sunResponse.data['code'] == 200) {
      if (isReflash == true) {
        //下拉刷新重置数组
        if (mounted) {
          setState(() {
            this._sunBreakdown = sunResponse.data['data'];
            isLoading = false;
            isReflash = false;
          });
        }
        //print("重置完${_sunBreakdown}");
        //print("优惠券数组重置，现在有:${_couponData.length} 条数据");
      } else {
        //上拉加载新数据
        if (mounted) {
          setState(() {
            isLoading = false;
            //isReflash == false;
            //this._couponData = sunResponse.data['data'];
            this._sunBreakdown.addAll(sunResponse.data['data']);
          });
        }
      }

    } else {
      if (mounted) {
        setState(() {
          _sunPage--;
          _sunLoading = "我是有底线的";
          isLoading = false;
        });
      }
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
        title: Text("提现记录"),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          controller: _scrollController,
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
                            child: Text("提现金额",
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
                            child: Text("到账金额",
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
                            child: Text("提现时间",
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
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: Colors.cyan,
                            height: 48.0,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text("手续费",
                                textAlign: TextAlign.center,
                                style:TextStyle(
                                  //fontWeight: FontWeight.bold, //加粗
                                    fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                    color:Colors.white //颜色使用Colors组件，设置系统自带的颜色
                                  //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                )
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                Column(
                  children: this._sunBreakdown.length>0?this._sunBreakdown.map((e){
                    // DateTime dateTime = e["created_at"].toDate();
                    // print(e["created_at"]);
                    // print(DateTime.parse(e["created_at"])); //字符串转化DateTime,2021-01-20 14:02:32.000
                    // formatDate(DateTime.parse(e["created_at"]) ,[mm,'-',dd," ",HH,":",nn]); //DateTime 格式化为 formatString

                    //formatDate(DateTime ,[yyyy,'-',mm,'-',dd]);
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
                                child: Text("${e["amount"]}",
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
                                child: Text("${e["amount_account"]}",
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
                                child: Text(e["status"]==1?"待审核":"已审核",
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
                                child: Text("${e["percentage_handling_fee"]}",
                                    textAlign: TextAlign.center,
                                    style:TextStyle(
                                      //fontWeight: FontWeight.bold, //加粗
                                      fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                      //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                    )
                                ),
                              ),
                            )
                          ],
                        ),
                        Divider(height: 1.0,color: Colors.black12,),
                      ],
                    );
                  }).toList():[
                    Container()
                  ],
                ),
                isLoading==true?Container(
                  //color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 10.0, 0, 16.0),
                    child: Center(
                      child: Text("${_sunLoading}"),
                    ),
                  ),
                ):Container()
              ],
            ),
          ),
        ),
      ),
    );
  }

}