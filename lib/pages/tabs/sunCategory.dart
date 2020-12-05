import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class sunCategory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State {
  String nextPage =
      "https://pixabay.com/api/?key=17946669-543fe6c4c313739ab33b63515&q=yellow+flowers&image_type=photo&pretty=true";

  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;
  List names = new List();
  final dio = new Dio();

  void _getMoreData() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      final response = await dio.get(nextPage);

      //nextPage = response.data['totalHits'];

      setState(() {
        isLoading = false;
        names.addAll(response.data['hits']);
      });
    }
  }

  @override
  void initState() {
    this._getMoreData();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
//+1 for progressbar
      itemCount: names.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == names.length) {
          return _buildProgressIndicator();
        } else {
          return new ListTile(
            title: Text((names[index]['tags'])),
            onTap: () {
              print(names[index]);
            },
          );
        }
      },
      controller: _scrollController,
    );
  }

  //下拉刷新，函数
  Future<void> _onRefresh() async {
    //print('执行刷新');
    //刷新数据
    //this._getData();
    //给3秒刷新数据时间
    await Future.delayed(Duration(seconds: 3), () {
      //print('refresh');
    });
  }

  //下拉刷新Body内部内容，效果一
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pagination"),
      ),
      body: Container(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child:_buildList(),
        ),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
  //下拉刷新整个 Scaffold，效果二
// @override
// Widget build(BuildContext context) {
//   return RefreshIndicator(
//     onRefresh: _onRefresh,
//     child: Scaffold(
//       appBar: AppBar(
//         title: const Text("Pagination"),
//       ),
//       body: Container(
//         child: _buildList(),
//       ),
//       resizeToAvoidBottomPadding: false,
//     ),
//   );
//
// }
}
