
import 'package:flutter/material.dart';
/**
 * SearchDelegate 是一个抽象类，需要实现其方法
 */
class sunDataSearch extends SearchDelegate<String>{
  //热门搜索数据
  final _sunHotSearch = [
    "黄渤",
    "黄磊",
  ];
  //汇总数据
  final _sunSearchAll = [
    "黄渤",
    "黄磊",
    "罗志祥",
    "张艺兴",
    "王迅"
  ];
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    //throw UnimplementedError();
    //显示右边关闭按钮
    return [IconButton(icon: Icon(Icons.close,color: Colors.black87,), onPressed: (){
      query = "";
    })];

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
        )
        , onPressed: (){
      close(context, null);
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    //throw UnimplementedError();
    //show some result based on the selection
    return Container(
      height: 100.0,
      width: 100.0,

      child: Card(
        color: Colors.red,
        child: Center(
          child: Text(query),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    //throw UnimplementedError();
    /**
     * 显示常用搜索内容
     * show when someone searches for something
     */
    final _sunActionList = query.isEmpty?_sunHotSearch:_sunSearchAll.where((value){
      return value.startsWith(query);
    }).toList();

    return ListView.builder(
      itemBuilder: (context,index){
        return ListTile(
          onTap: (){
            showResults(context);
          },
          leading: Icon(Icons.location_city),
          //title: Text(_sunActionList[index]),
          title: RichText(text: TextSpan(
              text: _sunActionList[index].substring(0,query.length),
              style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 16.0),
              children: [
                TextSpan(
                    text: _sunActionList[index].substring(query.length),
                    style: TextStyle(color: Colors.black87,fontSize: 16.0)
                )
              ]
          ),),
        );
      },
      itemCount: _sunActionList.length,
    );

  }

}