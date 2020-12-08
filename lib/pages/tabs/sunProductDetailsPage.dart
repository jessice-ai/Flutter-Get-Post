import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';

class sunProductDetailsPage extends StatefulWidget {
  final arguments;

  sunProductDetailsPage({Key key, this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunProductDetailsPageSon(arguments: this.arguments);
  }
}

class sunProductDetailsPageSon extends State {
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();
  Map arguments;
  var _contentId;
  int _sunUserID;
  List _sunContentData = [];
  bool sunLoginStatus = false;
  List _sunSmallImage = [];

  //获取用户登陆数据
  initFromCache() async {
    SharedPreferences prefs = await _sunPrefs;
    int intValue = prefs.getInt("sunId"); //获取用户登陆ID
    return intValue;
  }

  @override
  void initState() {
    super.initState();
    //验证用户登陆状态
    initFromCache().then((result) {
      this._sunUserID = result;
      //print("用户ID:${result}");
      _contentId = this.arguments["contentId"];
      _sunGetGoodsDetail(contentID: _contentId).then((result) {
        setState(() {
          this._sunContentData = result;
        });
      });
    });
  }

  sunProductDetailsPageSon({this.arguments});

  _sunGetGoodsDetail({contentID = 0}) async {
    //只有用户登陆状态判断过了才能返回数据
    Map sunJsonData = {"contentID": contentID, "uid": _sunUserID};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio.post(
        "http://192.168.9.45:8083/tbcouponseconday/content",
        data: sunJsonData);
    //print("数据:${sunResponse.data['data']}");
    if (sunResponse.data['code'] == 200) {
      return sunResponse.data['data'];
      //print("${this._secondaryCouponCate}");
    } else {
      return [];
      //_sunToast("网络请求异常Cate! ${sunResponse.data['message']}");
    }
  }

  List<Map> imgList = [
    {"url": "https://pic2.zhimg.com/v2-848ed6d4e1c845b128d2ec719a39b275_b.jpg"},
    {
      "url":
          "https://pic2.zhimg.com/80/v2-40c024ce464642fcab3bbf1b0a233174_hd.jpg"
    },
    {
      "url":
          "https://pic4.zhimg.com/80/v2-9cf53967a3825fb27b4199b771cb692b_720w.jpg"
    },
    {
      "url":
          "https://pic3.zhimg.com/80/v2-130838b9c036021e3656b30b01e55ce2_720w.jpg"
    },
    {
      "url":
          "https://pic2.zhimg.com/80/v2-552354a50944d5146fdb42dfc692dd51_720w.jpg"
    },
    {"url": "http://picture.name/images/2019/01/24/21515938.jpg"}
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    if (this._sunContentData.length > 0) {

      String small_images = this._sunContentData[0]['small_images'];
      _sunSmallImage = json.decode(small_images);
      print("${this._sunContentData[0]}");
      //print("${this._sunSmallImage.length} 张图片");
      return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          //backgroundColor: Colors.white.withOpacity(0.1),
          elevation: 0,
          // title: Text("aaa"),
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: Swiper(
                  itemBuilder: _swiperBuilder,
                  itemCount: this._sunSmallImage.length,
                  //pagination 控制底部分页器是否显示,注释掉不显示，不注释则显示
                  pagination: SwiperPagination(
                      builder: DotSwiperPaginationBuilder(
                    color: Colors.black54,
                    activeColor: Colors.redAccent,
                  )),
                  //control: new SwiperControl(), //控制左右箭头是否显示,注释掉不显示，不注释则显示
                  scrollDirection: Axis.horizontal,
                  //autoplay: true,
                  onTap: (index) => print('点击了第$index个'),
                )),
            Column(
              children: [
                //价格栏
                Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                Container(

                  height: 46.0,
                  alignment: Alignment.center,
                  //color: Colors.red,
                  child:Container(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child:Row(
                            children: [
                              Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
                              Text("¥",style:TextStyle(
                                  fontSize:16.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                  color:Colors.red //颜色使用Colors组件，设置系统自带的颜色
                                //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                              )),
                              Padding(padding: EdgeInsets.fromLTRB(1, 0, 0, 0)),
                              Text("${this._sunContentData[0]["zk_final_price"]}",
                                  style:TextStyle(
                                      fontWeight: FontWeight.bold, //加粗
                                      fontSize:24.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                      color:Colors.red //颜色使用Colors组件，设置系统自带的颜色
                                    //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                  )
                              ),
                              Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
                              Text("起",
                                  style:TextStyle(
                                      fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                      color:Colors.red //颜色使用Colors组件，设置系统自带的颜色
                                    //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                  )
                              ),
                              Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
                              Text("¥${this._sunContentData[0]['reserve_price']}",
                                  style:TextStyle(
                                      fontSize:14.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                                    decoration: TextDecoration.lineThrough, //删除线
                                    //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                                  )
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child:Container(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("已售件${this._sunContentData[0]['volume']}件"),
                                Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                              ],
                            ),

                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //标题栏
                new Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("${this._sunContentData[0]["title"]}",
                    style:TextStyle(
                      fontSize:16.0, //Flutter 中所有数字，都是double类型，所以后边都要加点零，否则会报错；40.0 表示40px
                      //color:Color.fromRGBO(r, g, b, opacity)  //color:Color.fromRGBO(r, g, b, opacity) 颜色也可自定义，RGB，透明度
                    ),
                    softWrap: true,
                  ),
                ),

              ],
            )
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Container(
          child: Center(
            child: Text("加载中..."),
          ),
        ),
      );
    }
  }

  Widget _swiperBuilder(BuildContext context, int index) {
    return Image.network(
      this._sunSmallImage[index]['url'],
      fit: BoxFit.fill,
    );
  }
}

//自定义组件
class iconItemContent extends StatelessWidget {
  double size = 24.0;
  Color color = Colors.red;
  IconData icon;

  //{} 标识可选值
  iconItemContent(this.icon, {this.color, this.size}) {}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    //ListView 列表组件
    return Container(
      width: 100,
      height: 100,
      color: this.color,
      child: Center(
        child: Icon(this.icon, size: this.size, color: Colors.white),
      ),
    );
  }
}
