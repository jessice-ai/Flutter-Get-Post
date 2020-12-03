import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

class sunHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    /**
     *  一般我们会使用 MaterialApp() 作为Flutter的一个根组件使用
     *  常用属性：
     *  home 主页
     *  title 标题
     *  color 颜色
     *  theme 主题
     *  routes 路由
     */
    return MaterialApp(
      home: Scaffold(
        //appBar 导航
        //body 主体
        body: sunHomeContent(),
      ),
      //theme 主体
      theme: ThemeData(primarySwatch: Colors.amber //修改主体颜色
          ),
    );
  }
}

/**
 * StatelessWidget 无状态组件
 * StatefulWidget 有状态组件，点击页面脚本出发页面数据发生变化
 */
//说明：使用TabControllers实现顶部tab切换,必须使用动态组件,也就是 StatefulWiget
class sunHomeContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    //这里不能直接返回组件，因为返回的数据类型是 State<StatefulWidget>
    return sunHomeContentState();
  }
}

class sunHomeContentState extends State with SingleTickerProviderStateMixin {
  TabController _tabController;
  List _couponCate = [];
  List _couponData = [];


  //dispose生命周期函数
  //dispose 当组件销毁时，触发的生命周期函数
  @override
  // ignore: must_call_super
  void dispose() {
    super.dispose();
    _tabController.dispose(); //把它自己销毁
  }

  //Dio Post实现网络请求 优惠券
  _sunDioPostData({catid:0}) async {
    var sunDio = Dio();
    Response sunResponse;
    //print("栏目ID:${catid}");
    Map sunJsonData = {
      "catid":catid
    };
    if(catid!=0){
       sunResponse =
      await sunDio.post("http://192.168.9.45:8083/tbcouponapi/index",data: sunJsonData);
    }else{
       sunResponse =
      await sunDio.post("http://192.168.9.45:8083/tbcouponapi/index");
    }

    if (sunResponse.data['code'] == 200) {
      //print(sunResponse.data['data']);
      setState(() {
        this._couponData = sunResponse.data['data'];
      });
    } else {
      _sunToast("网络请求异常!");
    }
    //print(_couponData);
  }

  //Dio Post实现网络请求:分类
  _sunDioPostCateData() async {
    var sunDio = Dio();
    Response sunResponse =
        await sunDio.post("http://192.168.9.45:8083/tbcouponapi/cat");
    if (sunResponse.data['code'] == 200) {
      //print(sunResponse.data['data']);
      setState(() {
        this._couponCate = sunResponse.data['data'];

      });
    } else {
      _sunToast("网络请求异常!");
    }
  }
  var _sunTabIndex = 0;
  @override
  void initState() {
    super.initState();

    _sunDioPostData(); //获取优惠券
    _sunDioPostCateData(); //获取栏目
    _tabController = TabController(length: 11, vsync: this);
    //侦听
    _tabController.addListener(() {
      //打印选中项索引值
      var index = _tabController.index;
      print("Jessice :${index}");
      var MapDataCat = this._couponCate[index];
      var catid = MapDataCat['id'];
      setState(() {
        this._sunTabIndex = index;
      });
      //_sunDioPostData(catid: catid);
    });
  }

  //优惠券结构
  Widget _getData(context, index) {
    var tabIndex = _sunTabIndex;
    //print("SOOOOO  ${_sunTabIndex}");
    //print("aaaa - ${_couponData[tabIndex]}");
    return Container(
      alignment: Alignment.center,
      //Column() 组件会竖向铺，但是不会横向自适应铺满；ListView() 横向自动铺满
      child: ListView(
        shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
        physics: NeverScrollableScrollPhysics(), //禁用滑动事件

        children: <Widget>[
          Image.network(
            _couponData[tabIndex]["data"][index]["small_images"],
            fit: BoxFit.cover,
          ),
          //设置一个空白的高度，方式1
          // Container(
          //   height: 10,
          // ),
          //设置一个空白的高度，方式1，建议
          SizedBox(
            height: 10,
          ),
          Text(
            _couponData[tabIndex]["data"][index]["title"],
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, //溢出之后显示三个点
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 1, //字母间隙
            ),
          ),
        ],
      ),
      //Container 边框
      decoration: BoxDecoration(
          //border: Border.all(color:Colors.black26,width: 1)
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();

    return  Scaffold(
      appBar: AppBar(
        title: Text("分类"),
        bottom: TabBar(
          isScrollable: true, //多Tab不叠加,滑动展示
          controller: this._tabController, //注意，必须得加
          tabs: this._couponCate.map((value) {
            return Tab(
              text: "${value['name']}",
              //icon: Icon(Icons.directions_bike),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController, //注意，必须得加
        children: this._couponCate.map((e){
          return Container(
              child: GridView.builder(
                padding: EdgeInsets.all(10), //使用padding 把上下左右留出空白距离
                //SliverGridDelegateWithFixedCrossAxisCount 这个单词比较长，用的时候拷贝下就好
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 10.0, //左右两个之间距离
                  mainAxisSpacing: 5.0, //上下两个之间距离
                  crossAxisCount: 2, //列数2
                  childAspectRatio: 0.75, //宽度与高度的比例，通过这个比例设置相应高度
                ),
                itemCount: _couponData.length, //指定循环的数量
                itemBuilder: this._getData,
              ));
        }).toList(),
      ),
    );
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start, //横轴
    //   mainAxisAlignment: MainAxisAlignment.center,  //纵轴
    //   children: <Widget>[
    //     ///向无状态组件，StatelessWidget 传递参数
    //     //按钮一
    //     RaisedButton(
    //       child: Text("向无状态组件，StatelessWidget 传递参数"),
    //       onPressed: (){
    //         //命名路由跳转到某个页面
    //         Navigator.pushNamed(context, '/goods',arguments:{
    //           "id":123,
    //           "title":"商品"
    //         });
    //       },
    //       color: Theme.of(context).accentColor, //颜色主题
    //       textTheme: ButtonTextTheme.primary, //文本主题
    //     ),
    //     ///向有状态组件，StatefulWidget 传递参数
    //     RaisedButton(
    //       child: Text("向有状态组件，StatefulWidget 传递参数"),
    //       onPressed: (){
    //         //命名路由跳转到某个页面
    //         Navigator.pushNamed(context, '/sunNews',arguments:{
    //           "id":123,
    //           "title":"新闻"
    //         });
    //       },
    //       color: Theme.of(context).accentColor, //颜色主题
    //       textTheme: ButtonTextTheme.primary, //文本主题
    //     ),
    //     SizedBox(height: 30,),
    //     ///向有状态组件，StatefulWidget 传递参数
    //     RaisedButton(
    //       child: Text("跳转到Form表单"),
    //       onPressed: (){
    //         //命名路由跳转到某个页面
    //         Navigator.pushNamed(context, '/sform');
    //       },
    //       color: Theme.of(context).accentColor, //颜色主题
    //       textTheme: ButtonTextTheme.primary, //文本主题
    //     ),
    //     SizedBox(height: 30,),
    //     ///向有状态组件，StatefulWidget 传递参数
    //     RaisedButton(
    //       child: Text("跳转到时间页面一"),
    //       onPressed: (){
    //         //命名路由跳转到某个页面
    //         Navigator.pushNamed(context, '/sdata');
    //       },
    //       color: Theme.of(context).accentColor, //颜色主题
    //       textTheme: ButtonTextTheme.primary, //文本主题
    //     ),
    //     RaisedButton(
    //       child: Text("跳转到时间页面二"),
    //       onPressed: (){
    //         //命名路由跳转到某个页面
    //         Navigator.pushNamed(context, '/sunCupert');
    //       },
    //       color: Theme.of(context).accentColor, //颜色主题
    //       textTheme: ButtonTextTheme.primary, //文本主题
    //     ),
    //     RaisedButton(
    //       child: Text("Dialog"),
    //       onPressed: (){
    //         //命名路由跳转到某个页面
    //         Navigator.pushNamed(context, '/sunlog');
    //       },
    //       color: Theme.of(context).accentColor, //颜色主题
    //       textTheme: ButtonTextTheme.primary, //文本主题
    //     ),
    //     RaisedButton(
    //       child: Text("Toast"),
    //       onPressed: (){
    //         //命名路由跳转到某个页面
    //         Navigator.pushNamed(context, '/sunoast');
    //       },
    //       color: Theme.of(context).accentColor, //颜色主题
    //       textTheme: ButtonTextTheme.primary, //文本主题
    //     ),
    //     RaisedButton(
    //       child: Text("自定义Dialog组件"),
    //       onPressed: (){
    //             showDialog(context: context,builder: (context){
    //               return sunMyDialog(
    //                 suntitle: "标题",
    //                 suncontent: "内容",
    //               );
    //             });
    //         },
    //       color: Theme.of(context).accentColor, //颜色主题
    //       textTheme: ButtonTextTheme.primary, //文本主题
    //     ),
    //     RaisedButton(
    //       child: Text("Dio实现网络请求"),
    //       onPressed: (){
    //         //命名路由跳转到某个页面
    //         Navigator.pushNamed(context, '/sundio');
    //       },
    //       color: Theme.of(context).accentColor, //颜色主题
    //       textTheme: ButtonTextTheme.primary, //文本主题
    //     ),
    //     RaisedButton(
    //       child: Text("SearchBar"),
    //       onPressed: (){
    //         //命名路由跳转到某个页面
    //         Navigator.pushNamed(context, '/sunsearch');
    //       },
    //       color: Theme.of(context).accentColor, //颜色主题
    //       textTheme: ButtonTextTheme.primary, //文本主题
    //     ),
    //
    //
    //     // SizedBox(height: 20.0,),
    //     // RaisedButton(
    //     //   child: Text("跳转到宝贝页面"),
    //     //   onPressed: (){
    //     //     //基本路由跳转到某个页面
    //     //     Navigator.of(context).push(
    //     //         MaterialPageRoute(
    //     //           // ignore: missing_return
    //     //             builder: (context){
    //     //               return sunGoodsList(sunCount: 55,titlet: "aaa",);
    //     //             }
    //     //           //页面控件
    //     //         )
    //     //     );
    //     //   },
    //     //   color: Theme.of(context).accentColor, //颜色主题
    //     //   textTheme: ButtonTextTheme.primary, //文本主题
    //     //
    //     // )
    //   ],
    // );
  }

  _sunToast(String message) {
    Fluttertoast.showToast(
        msg: "${message}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        //提示信息展示位置
        timeInSecForIos: 10,
        //显示时间，这个只在IOS上有效，android 是默认时间
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
