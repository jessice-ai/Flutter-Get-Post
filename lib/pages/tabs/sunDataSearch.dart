import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

/**
 * SearchDelegate 是一个抽象类，需要实现其方法
 */

class sunDataSearch extends SearchDelegate<String> {
  List _sunGoodsList = [];
  int _sunSearchPage = 1;
  var _sunSetState;

  ScrollController _scrollController = new ScrollController();
  bool isReflash = false;
  bool isLoading = false;

  //热门搜索数据
  final _sunHotSearch = [
    "黄渤",
    "黄磊",
  ];

  //汇总数据
  final _sunSearchAll = ["黄渤", "黄磊", "罗志祥", "张艺兴", "王迅"];

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

//优惠券结构
  Widget _getData(context, index) {
    //var tabIndex = this._sunTabIndex;
    //print("Jessice:A ${_sunGoodsList}");
    if (_sunGoodsList.isNotEmpty) {
      return Container(
        alignment: Alignment.center,
        //Column() 组件会竖向铺，但是不会横向自适应铺满；ListView() 横向自动铺满
        child: ListView(
          shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
          physics: NeverScrollableScrollPhysics(), //禁用滑动事件

          children: <Widget>[
            Image.network(
              _sunGoodsList[index]["pict_url"],
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
              _sunGoodsList[index]["title"],
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
    } else {
      return Container();
    }

    //print("${_couponData[tabIndex]["data"][index]["small_images"]}");
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

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    //throw UnimplementedError();
    //show some result based on the selection
    /**
     * 获取远程数据显示出来
     */
    //print("搜索的内容:${query}");
    /**
     * 侦听滚动事件
     */
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        this._sunSearchPage++;
        _sunSearchData(keyword: query);
      }
    });
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
              child: Container(
                  child: GridView.builder(
                padding: EdgeInsets.all(10),
                //使用padding 把上下左右留出空白距离
                //SliverGridDelegateWithFixedCrossAxisCount 这个单词比较长，用的时候拷贝下就好
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 10.0, //左右两个之间距离
                  mainAxisSpacing: 5.0, //上下两个之间距离
                  crossAxisCount: 2, //列数2
                  childAspectRatio: 0.75, //宽度与高度的比例，通过这个比例设置相应高度
                ),
                itemCount: _sunGoodsList.length,
                //指定循环的数量
                itemBuilder: (BuildContext context, int index) {
                  return this._getData(context, index);
                },
                controller: _scrollController,
              )));
        } else {
          return Container(
            child: Center(
              child: Text("数据加载中..."),
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
      this._sunSearchPage = 1;
    }
    Map sunJsonData = {"keyword": keyword, "uid": 1, "page": _sunSearchPage};
    print("POST值: ${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio.post(
        "http://39.98.92.36/tbcouponsearch/index",
        data: sunJsonData);
    if (sunResponse.data['code'] == 200) {
      if (this.isReflash == true) {
        this._sunSetState(() {
          isLoading = false;
          isReflash = false;
          this._sunGoodsList = sunResponse.data['data'];
        });
        //print("搜索的json: ${_sunGoodsList}");
        print("优惠券数组重置，现在有:${_sunGoodsList.length} 条数据");
      } else {
        this._sunSetState(() {
          isLoading = false;
          //this._couponData = sunResponse.data['data'];
          this._sunGoodsList.addAll(sunResponse.data['data']);
        });
        print("优惠券数组增加，现在有:${_sunGoodsList.length} 条数据");
      }
    } else {
      _sunSearchPage--;
      //_sunToast("暂时没有数据!");
      this.isLoading = false;
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

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    //throw UnimplementedError();
    /**
     * 显示常用搜索内容
     * show when someone searches for something
     */
    final _sunActionList = query.isEmpty
        ? _sunHotSearch
        : _sunSearchAll.where((value) {
            return value.startsWith(query);
          }).toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
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
                      style: TextStyle(color: Colors.black87, fontSize: 16.0))
                ]),
          ),
        );
      },
      itemCount: _sunActionList.length,
    );
  }
}
