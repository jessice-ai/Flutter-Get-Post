import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alibc/alibc_const_key.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_alibc/flutter_alibc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class sunSearchShow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunSearchShowSon();
  }

}
class sunSearchShowSon extends State{
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();
  int _sunUserID;
  bool isReflash = false;
  var sunSearchKeyword = "";
  bool _sunSearchInt = false;
  var _couponData = [];
  bool isLoading = false;
  ScrollController _scrollController = new ScrollController();
  int _sunPage = 1;
  String _dataLoading = "Loading...";
  var _dataLoadingData = "Loading...";
  String SearchXon = "";
  //获取用户登陆数据
  initFromCache() async {
    SharedPreferences prefs = await _sunPrefs;
    int intValue = prefs.getInt("sunId"); //获取用户登陆ID
    // ignore: unrelated_type_equality_checks
    if (intValue != "" && intValue != null) {
      return intValue;
    } else {
      //用户登陆
      //命名路由跳转到某个页面
      Navigator.pushNamed(context, '/sunLogin');
    }
  }
  @override
  void initState() {
    super.initState();
    //验证用户登陆状态
    initFromCache().then((result) async {
      this._sunUserID = result;
      //print("用户ID:${result}");
    });
    /**
     * 侦听滚动事件
     */
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        this._sunPage++;
        //print("第 ${_sunPage} 页");
        //_buildProgressIndicator();
        _sunGetGoodsDetail(context: this.SearchXon);
      }
    });
  }
  //下拉刷新，函数
  Future<void> _onRefresh() async {
    //print('执行刷新');
    isReflash = true;
    //刷新数据
    //this._sunDioPostData(catid: _couponCateId);
    //给3秒刷新数据时间

    await Future.delayed(Duration(seconds: 3), () {
      //print('refresh');
    });
  }
  _sunGetGoodsDetail({context}) async {
    if (isReflash == true) {
      this._sunPage = 1;
      this._sunSearchInt = true;
    }
    //只有用户登陆状态判断过了才能返回数据
    Map sunJsonData = {"context": context, "uid": _sunUserID,"platform":1,"page":_sunPage};
    print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tb/searchkeyword", data: sunJsonData);
    //print("数据:${sunResponse.data['data']}");
    //print("${sunResponse.data['data']}");
    if (sunResponse.data['code'] == 200) {
      if (isReflash == true) {
        //下拉刷新重置数组
        if (mounted) {
          setState(() {
            this._couponData = sunResponse.data['data'];
            isLoading = false;
            isReflash = false;
            _dataLoadingData = "";

          });
        }
        if(this._couponData.length==0){
          if(mounted){
            _dataLoading = "没有找到数据";
          }
        }
        //print("重置完${isReflash}");
        print("优惠券数组重置，现在有:${_couponData.length} 条数据");
      } else {
        //上拉加载新数据
        if (mounted) {
          setState(() {
            isLoading = false;
            _dataLoadingData = "";
            _dataLoading = "";
            this._couponData.addAll(sunResponse.data['data']);
          });
        }
        print("优惠券数组增加，现在有:${_couponData.length} 条数据");
      }

    } else {
      if (mounted) {
        setState(() {
          _sunPage--;
          _dataLoadingData = "我是有底线的";
          _dataLoading = "没有数据";
          isLoading = false;
        });
      }
      //_sunToast("网络请求异常Cate! ${sunResponse.data['message']}");
    }
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
  _sunToast(String message) {
    Fluttertoast.showToast(
        msg: "${message}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        //提示信息展示位置
        timeInSecForIos: 3,
        //显示时间，这个只在IOS上有效，android 是默认时间
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
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

  //优惠券结构
  Widget _getData(context, index) {
    if (_couponData.isNotEmpty) {

      //print("Jessice:${_couponData[index]["zk_final_price"]}");
      //print("Jessice:${_couponData[index]["coupon_amount"]}");
      //print(_couponData[index]["zk_final_price"] is String);
      var _sunCoPrice = _couponData[index]["zk_final_price"] - _couponData[index]["coupon_amount"];
      // print("Jessice:---------");
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
      //print(_couponData);
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
                _couponData[index]["pict_url"],
                fit: BoxFit.cover,
              ),
              onTap: () {
                //命名路由传值给详情页
                print(_couponData[index]["item_id"]);
                Navigator.pushNamed(context, '/sunproductcontent',
                    arguments: {"contentId": _couponData[index]["item_id"]});
              },
            ),

            //设置一个空白的高度，方式1
            // Container(
            //   height: 10,
            // ),
            //设置一个空白的高度，方式1，建议
            SizedBox(
              height: 5,
            ),
            Text(
              _couponData[index]["title"],
              maxLines: 2,
              textAlign: TextAlign.left,
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
                        //color: Colors.red,
                        border: Border.all(color: Colors.red, width: 1)
                    ),
                    child: Text("优惠券${_couponData[index]["coupon_amount"]}元",
                        style: TextStyle(
                          fontSize: 12,
                          //color: Colors.yellowAccent,
                          //letterSpacing: 1, //字母间隙
                        )),
                  ),
                ),
                // SizedBox(width: 20,),
                // Expanded(
                //   flex:1,
                //   child: InkWell(
                //     child: Container(
                //       width: 10.0,
                //       alignment: Alignment.center,
                //       padding: EdgeInsets.all(5),
                //       decoration: BoxDecoration(
                //           color: Colors.cyan,
                //           borderRadius: BorderRadius.circular(5),
                //           border: Border.all(color: Colors.cyan, width: 1)),
                //       child: Text("推荐",
                //           style: TextStyle(
                //             fontSize: 12,
                //             color: Colors.white,
                //             //letterSpacing: 1, //字母间隙
                //           )),
                //     ),
                //     onTap: (){
                //       if(mounted){
                //         setState(() {
                //           _couponData[index]["Favorites"]=_couponData[index]["Favorites"]==1?2:1;
                //         });
                //       }
                //       //_sunFavoritesGoods(contentID: _couponData[index]["id"]);
                //     },
                //   ),
                // )
              ],
            ),
            Row(
              children: [
                Text(
                  "券后 ￥",
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                  style: TextStyle(
                    fontSize: 12,
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
                      fontSize: 16,
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
                    fontSize: 12,
                    fontFamily: 'DMSans',
                    color: Colors.grey,
                    //letterSpacing: 1, //字母间隙
                  ),
                ),
                Text(
                  "${_couponData[index]["reserve_price"]}",
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis, //溢出之后显示三个点
                  style: TextStyle(
                    fontSize: 14,
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
              "已售${_couponData[index]["volume"]}件",
              maxLines: 2,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis, //溢出之后显示三个点
              style: TextStyle(
                fontSize: 12,
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
                      padding: EdgeInsets.all(5.0),
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
                        "分享赚${_couponData[index]["estimated_New"]}元",
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
                          arguments: {"contentId": _couponData[index]["id"]});
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.fromLTRB(0, 10, 5, 10)),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.all(5.0),
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
                        "自购得${_couponData[index]["estimated_New"]}元",
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
                          prourl: _couponData[index]["coupon_share_url"]);
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
    } else {
      return Container(
        child: Center(
          child: Text("${_dataLoading}"),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: 40,
              //maxWidth: 200
          ),
          child: new TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
              hintText: '请输入搜索内容',
              prefixIcon: Icon(Icons.search),
              // contentPadding: EdgeInsets.all(10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none
              ),
              filled: true,
              //fillColor: Color(0xffaaaaaa),
            ),
            //输入框值发生变化，自动更新到变量中
            // onChanged: (pwd){
            //   setState(() {
            //     this.sunSearchKeyword = pwd;
            //   });
            // },
            //回车查询
            onSubmitted: (value) {
              this.SearchXon = value;
              //print(value);
              isReflash = true;
              _sunGetGoodsDetail(context: this.SearchXon);
              //搜索
              // Navigator.pushNamed(
              //     context,
              //     '/sunSearchContexts',
              //     arguments: {
              //       "sunkeyword":
              //       value,
              //     });

            },
          ),
        ),

      ),
      body: _sunSearchInt==true?
      SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          child: Column(
            children: [
              this._couponData.length > 0
                  ? Container(
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
                      0.53, //宽度与高度的比例，通过这个比例设置相应高度
                    ),
                    itemCount: _couponData.length,
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
                  : Padding(padding:EdgeInsets.all(10.0) ,child: Text("${_dataLoading}"),),
              //底部加载提示
              Container(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 10.0, 0, 40.0),
                  child: Center(
                    child: Text("${_dataLoadingData}"),
                  ),
                ),
              )
            ],
          ),
        ),
      ):
      Container(),
    );
  }

}