import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_alibc/alibc_const_key.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_alibc/flutter_alibc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/**
 * SearchDelegate 是一个抽象类，需要实现其方法
 */

class sunDataSearch extends SearchDelegate<String> {
  List _sunGoodsList = [];
  int _sunSearchPage = 1;
  var _sunSetState;
  int _sunUserID;
  var _dataLoadingData = "";
  int _sunFavoritesStatus = 0;
  ScrollController _scrollController = new ScrollController();
  bool isReflash = false;
  bool isLoading = false;
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();
  //热门搜索数据
  var _sunHotSearch = [];

  //汇总数据
  //final _sunSearchAll = ["黄渤", "黄磊", "罗志祥", "张艺兴", "王迅"];
  final _sunSearchAll = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    //throw UnimplementedError();
    //显示右边关闭按钮
    return [
      IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black87,
          ),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    //throw UnimplementedError();
    /**
     * 加载左边向左箭头
     * leading icon on the left of the app bar
     */
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
          color: Colors.black87,
        ),
        onPressed: () {
          close(context, null);
        });
  }
//客户收藏宝贝
  _sunFavoritesGoods({contentID = 0}) async {
    //只有用户登陆状态判断过了才能返回数据
    Map sunJsonData = {"contentID": contentID, "uid": _sunUserID};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio.post(
        "https://www.shsun.xyz/tbcouponseconday/Cobaby",
        data: sunJsonData);
    //print("数据:${sunResponse.data['data']}");
    if (sunResponse.data['code'] == 200) {
      this._sunSetState(() {
        _sunFavoritesStatus = 1;
      });
    }else if(sunResponse.data['code'] == 300){
      this._sunSetState(() {
        _sunFavoritesStatus = 0;
      });
    }
    _sunToast("${sunResponse.data['message']}");
  }
//优惠券结构
  Widget _getData(context, index) {
    //print(_couponData[index]["zk_final_price"]);
    var _sunCoPrice = _sunGoodsList[index]["zk_final_price"] -
        _sunGoodsList[index]["coupon_amount"];
    _sunCoPrice = _sunCoPrice.toStringAsFixed(1);
    var price = _sunCoPrice.toString();
    //print(_sunCoPrice);
    String xaint;
    String xbint;
    List xaintarr = price.split('.');
    if (xaintarr.length > 1) {
      //print("有小数点:${xaintarr}");
      xaint = xaintarr[0];
      xbint = xaintarr[1];
    } else {
      //print("没有小数点:${xaintarr}");
      xaint = xaintarr[0];
      xbint = "0";
    }

    return Container(
      alignment: Alignment.center,
      //Column() 组件会竖向铺，但是不会横向自适应铺满；ListView() 横向自动铺满
      child: ListView(
        shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
        physics: NeverScrollableScrollPhysics(), //禁用滑动事件
        children: <Widget>[
          //给图增加水波纹效果，并使用期点击事件
          InkWell(
            child: Image.network(
              _sunGoodsList[index]["pict_url"],
              fit: BoxFit.cover,
            ),
            onTap: () {
              //命名路由传值给详情页
              Navigator.pushNamed(context, '/sunproductcontent',
                  arguments: {"contentId": _sunGoodsList[index]["item_id"]});
            },
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
            _sunGoodsList[index]["title"],
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, //溢出之后显示三个点
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 1, //字母间隙
            ),
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 3, 0, 0)),
          Row(
            children: [
              Expanded(
                flex:2,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    //color: Colors.black,
                    border: Border.all(color: Colors.red, width: 1)
                  ),
                  child: Text("优惠券${_sunGoodsList[index]["coupon_amount"]}元",
                      style: TextStyle(
                        fontSize: 12,
                        //color: Colors.yellowAccent,
                        //letterSpacing: 1, //字母间隙
                      )),
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                flex:1,
                child: InkWell(
                  child: Container(
                    width: 10.0,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.cyan, width: 1)),
                    child: Text(_sunGoodsList[index]["Favorites"]==1?"已收藏":"收藏",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          //letterSpacing: 1, //字母间隙
                        )),
                  ),
                  onTap: (){
                      this._sunSetState(() {
                        _sunGoodsList[index]["Favorites"]=_sunGoodsList[index]["Favorites"]==1?2:1;
                      });
                    _sunFavoritesGoods(contentID: _sunGoodsList[index]["id"]);
                  },
                ),
              )
            ],
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 0)),
          Row(
            children: [
              Text(
                "券后 ￥ ",
                maxLines: 2,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontFamily: 'DMSans',
                  //letterSpacing: 1, //字母间隙
                ),
              ),
              xaint != "0"
                  ? Text(
                "${xaint}",
                maxLines: 2,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.bold
                  //letterSpacing: 1, //字母间隙
                ),
              )
                  : Center(),
              xbint != "0"
                  ? Column(
                children: [
                  Padding(padding: EdgeInsets.fromLTRB(0, 3, 0, 0)),
                  Text(
                    ".${xbint}",
                    maxLines: 2,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.bold
                      //letterSpacing: 1, //字母间隙
                    ),
                  )
                ],
              )
                  : Center(),
              Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
              Text(
                " ￥",
                maxLines: 2,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'DMSans',
                  color: Colors.grey,
                  //letterSpacing: 1, //字母间隙
                ),
              ),
              Text(
                " ${_sunGoodsList[index]["reserve_price"]}",
                maxLines: 2,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'DMSans',
                  decoration: TextDecoration.lineThrough, //删除线
                  color: Colors.grey,
                  //letterSpacing: 1, //字母间隙
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
            ],
          ),

          Text(
            "已售${_sunGoodsList[index]["volume"]}件",
            maxLines: 2,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis, //溢出之后显示三个点
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'DMSans',
              color: Colors.grey,
              //letterSpacing: 1, //字母间隙
            ),
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: InkWell(
                  child: Container(
                    height: 24.0,
                    decoration: BoxDecoration(
                      //border: Border.all(color: Colors.red, width: 1),//边框
                      //border: Border.all(color: Colors.white, width: 1),//边框
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(
                          //圆角
                          Radius.circular(5.0),
                        )
                      //borderRadius: BorderRadius.horizontal(left: Radius.circular(70.0),right: Radius.circular(0.0)), //左侧半圆，右侧不变
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "分享赚${_sunGoodsList[index]["estimated_New"]}元",
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        //letterSpacing: 1, //字母间隙
                        //fontWeight: FontWeight.bold, //加粗
                        //fontStyle: FontStyle.italic, //倾斜
                        //decoration: TextDecoration.lineThrough, //删除线
                        //decorationColor:Colors.deepOrange,//删除线颜色
                        //decorationStyle: TextDecorationStyle.dashed, //删除线改成虚线
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/sunshar',
                        arguments: {"contentId": _sunGoodsList[index]["id"]});
                  },
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 10, 5, 10)),
              Expanded(
                flex: 1,
                child: InkWell(
                  child: Container(
                    height: 24.0,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        //border: Border.all(color: Colors.red, width: 1),//边框
                        //border: Border.all(color: Colors.red, width: 1),//边框
                        borderRadius: BorderRadius.all(
                          //圆角
                          Radius.circular(5.0),
                        )
                      //borderRadius: BorderRadius.horizontal(left: Radius.circular(0.0),right: Radius.circular(70.0)), //左侧半圆，右侧不变
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "自购得${_sunGoodsList[index]["estimated_New"]}元",
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        //letterSpacing: 1, //字母间隙
                        //fontWeight: FontWeight.bold, //加粗
                        //fontStyle: FontStyle.italic, //倾斜
                        //decoration: TextDecoration.lineThrough, //删除线
                        //decorationColor:Colors.deepOrange,//删除线颜色
                        //decorationStyle: TextDecorationStyle.dashed, //删除线改成虚线
                      ),
                    ),
                  ),
                  onTap: () async {
                    _sunGetUserTaobaoauth(
                        prourl: _sunGoodsList[index]["coupon_share_url"]);
                  },
                ),
              )
            ],
          )
        ],
      ),
      //Container 边框
      decoration: BoxDecoration(
        //border: Border.all(color:Colors.black26,width: 1)
      ),
    );
  }
  _sunGetUserTaobaoauth({prourl}) async {
    Map sunJsonData = {"uid": _sunUserID};
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tbcouponseconday/getUsertb",
        // ignore: missing_return
        data: sunJsonData)
    // ignore: missing_return
        .then((value) async {
      //print("打印${value.data}");
      if (value.data["code"] == 300) {
        //没有授权过
        await FlutterAlibc.initAlibc(appName: "白羽电商导购", version: "1.0.0+1")
            .then((value) async {
          var result = await FlutterAlibc.loginTaoBao();
          // print(
          //     "登录淘宝  ${result.data.nick} ${result.data.topAccessToken}");
          _sunGetUserTaobaoauthPost(
              result.data.nick, result.data.topAccessToken);
        });

        // print("ddddddd-------${value}");
      } else if (value.data["code"] == 400) {
        //用户未登录
        _sunToast("请先登陆!");
      } else if (value.data["code"] == 200) {
        //print(this._sunContentData[0]['url']);
        //有授权过
        await FlutterAlibc.initAlibc(appName: "白羽电商导购", version: "1.0.0+1")
            .then((value) async {
          //print(this._sunContentData[0]['url']);
          var result = await FlutterAlibc.openByUrl(
              url: prourl,
              //backUrl: "tbopen27822502:https://h5.m.taobao.com",
              openType: AlibcOpenType.AlibcOpenTypeAuto,
              isNeedCustomNativeFailMode: true,
              nativeFailMode: AlibcNativeFailMode.AlibcNativeFailModeJumpH5);
        });
        //print(result);
      } else {
        //其他错误
      }
    });
  }
  //下拉刷新，函数
  Future<void> _onRefresh() async {
    //print('执行刷新');
    isReflash = true;
    //刷新数据
    this._sunSearchPage = 1;
    _sunSearchData(keyword: query);
    //给3秒刷新数据时间
    await Future.delayed(Duration(seconds: 3), () {
      //print('refresh');
    });
  }
  _sunGetUserTaobaoauthPost(String nick, String topAccessToken) async {
    Map sunJsonData = {
      "uid": _sunUserID,
      "nick": nick,
      "topAccessToken": topAccessToken
    };
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tbcouponseconday/getItb",
        // ignore: missing_return
        data: sunJsonData)
    // ignore: missing_return
        .then((value) {
      if (value.data["code"] == 200) {
        _sunToast("授权成功!");
      } else {
        _sunToast("授权失败!");
      }
    });
  }
  //获取用户登陆数据
  initFromCache() async {
    SharedPreferences prefs = await _sunPrefs;
    int intValue = prefs.getInt("sunId"); //获取用户登陆ID
    //intValue = 0;
    if (intValue != "" && intValue != null) {
       this._sunUserID = intValue;
      //this.sunLoginStatus = true;
    }
    return intValue;
  }
  // //记录用户搜索信息
  // sunPostinsert({query}) async{
  //   var sunDio = Dio();
  //   Map sunJsonData = {"word": query, "uid": _sunUserID};
  //   await sunDio.post(
  //       "http://192.168.9.45:8083/tb/gethotsins",
  //       data: sunJsonData);
  // }
  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    //throw UnimplementedError();
    //show some result based on the selection

    /**
     * 获取远程数据显示出来
     */
    print("搜索的内容:${query}");
    /**
     * 侦听滚动事件
     */
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {

        this._sunSearchPage++;
        this._sunSetState(() {
          this._dataLoadingData = "数据加载中";
        });
        _sunSearchData(keyword: query);
      }
    });
    initFromCache();//验证用户是否登陆
    //sunPostinsert(query: query);
    _sunSearchData(keyword: query);
    return StatefulBuilder(
      // ignore: missing_return

      builder: (modalContext, modalSetState) {
        this._sunSetState = modalSetState;


        // modalSetState((){
        //
        // });
        // if(this._sunGoodsList.length>0){
        //   print("内容: ${_sunGoodsList}");
        // }

        if (this._sunGoodsList.length > 0) {

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      //Divider(height: 1.0,color: Colors.black12,), //线条
                      Container(
                          color: Colors.white,
                          //height: 600.0,
                          width: double.infinity,
                          //强制container撑满整个屏幕
                          alignment: Alignment.center,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(10),
                            //使用padding 把上下左右留出空白距离
                            //SliverGridDelegateWithFixedCrossAxisCount 这个单词比较长，用的时候拷贝下就好
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 10.0, //左右两个之间距离
                              mainAxisSpacing: 5.0, //上下两个之间距离
                              crossAxisCount: 2, //列数2
                              childAspectRatio:
                              3 / 5.5, //宽度与高度的比例，通过这个比例设置相应高度
                            ),
                            itemCount: _sunGoodsList.length,
                            //指定循环的数量
                            itemBuilder:
                            // ignore: missing_return
                                (BuildContext context, int index) {
                              //如果循环到最后一个宝贝，显示加载图标
                              //print(_couponData.length);
                              //print(index);
                              return this._getData(context, index);
                            },
                            //controller: _scrollController,
                          ))
                    ],
                  ),
                  //底部加载提示
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 10.0, 0, 40.0),
                      child: Center(
                        child: Text("${_dataLoadingData}"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            child: Center(
              child: Text(""),
            ),
          );
        }
        _scrollController.dispose();
        // return Container(
        //   height: 100.0,
        //   width: 100.0,
        //   child: Card(
        //     color: Colors.red,
        //     child: Center(
        //       child: Text(query),
        //     ),
        //   ),
        // );
      },
    );
  }

  _sunSearchData({keyword = 0}) async {

    //print("搜索的内容: ${keyword}");
    if (isReflash == true) {
      this._sunSetState(() {
        this._sunGoodsList = [];
        _dataLoadingData = "数据加载中";
        this._sunSearchPage = 1;
      });
    }
    //print("dddeeee");
    Map sunJsonData = {"keyword": keyword, "uid": _sunUserID, "page": _sunSearchPage};
    print("POST值: ${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio.post(
        "https://www.shsun.xyz/tbcouponsearch/index",
        data: sunJsonData);
    if (sunResponse.data['code'] == 200) {
      if (this.isReflash == true) {
        this._sunSetState(() {
          isLoading = false;
          isReflash = false;
          this._sunGoodsList = sunResponse.data['data'];
        });
        //print("搜索的json: ${_sunGoodsList}");
        //print("优惠券数组重置，现在有:${_sunGoodsList.length} 条数据");
      } else {
        this._sunSetState(() {
          isLoading = false;
          this.isReflash = false;
          //this._couponData = sunResponse.data['data'];
          this._sunGoodsList.addAll(sunResponse.data['data']);
        });


        //print("优惠券数组增加，现在有:${_sunGoodsList.length} 条数据");
      }
    } else {
      this._sunSetState(() {
        _sunSearchPage--;
        _dataLoadingData = "我是有底线的";
        this.isReflash = false;
        this.isLoading = false;
      });
      //_sunToast("暂时没有数据!");
    }
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
  // getSearchData() async{
  //   var sunDio = Dio();
  //   Map sunJsonData = {"word": query, "uid": _sunUserID};
  //   Response sunResponse = await sunDio.post(
  //       "http://192.168.9.45:8083/tb/gethots",
  //       // ignore: missing_return
  //       data: sunJsonData).then((value){
  //     //print("热门搜索词内容 ${value}");
  //     print(value.data['data'].length);
  //     if (value.data['code'] == 200) {
  //        this._sunHotSearch = value.data['data'];
  //     }
  //   });
  // }
  @override
  Widget buildSuggestions(BuildContext context) {

    // TODO: implement buildSuggestions
    //throw UnimplementedError();
    /**
     * 显示常用搜索内容
     * show when someone searches for something
     */
    initFromCache().then((value){
      //getSearchData();
    });
    //print(_sunHotSearch);
    final _sunActionList = query.isEmpty
        ? _sunHotSearch
        : _sunSearchAll.where((value) {
            return value.startsWith(query);
          }).toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        return Column(
          children: [
            ListTile(
              onTap: () {
                showResults(context);
              },
              //leading: Icon(Icons.location_city),
              //title: Text(_sunActionList[index]),
              title: RichText(
                text: TextSpan(
                    text: _sunActionList[index].substring(0, query.length),
                    style: TextStyle(color: Colors.black87, fontSize: 16.0),
                    children: [
                      TextSpan(
                          text: _sunActionList[index].substring(query.length),
                          style: TextStyle(color: Colors.black87, fontSize: 16.0)),

                    ]),

              ),
            ),
            Divider()
          ],
        );
      },
      itemCount: _sunActionList.length,
    );
  }
}
