import 'package:flutter/material.dart';
import 'sunCategory.dart';
import 'sunSetting.dart';
import 'sunHome.dart';
import 'sunMy.dart';
import 'sunPicture.dart';
/**
 * StatelessWidget 无状态组件
 * StatefulWidget 有状态组件，点击页面脚本出发页面数据发生变化
 */
class sunFooterTabsContent extends StatefulWidget{
  final index;
  sunFooterTabsContent({Key key,this.index=0}) : super(key:key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    //这里不能直接返回组件，因为返回的数据类型是 State<StatefulWidget>
    return _sunFooterTabsContentState(index);
  }
}
class _sunFooterTabsContentState extends State{
  int _currentIndex = 0;
  _sunFooterTabsContentState(index){
    this._currentIndex = index;
  }
  /// 创建一个数组，存储三个组件
  List _pageList = [
    sunHome(),
    sunCategory(),
    sunSetting(),
    sunPicture(),
    sunMy(),
  ];
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    // ListView 水平布局组件
    return Scaffold(
      //appBar 导航
      // appBar: AppBar(
      //   title: Text('SunTitleBar'),
      // ),
      //body 主体
      body: this._pageList[this._currentIndex], //配置对应的 控件选中
      //底部导航条
      bottomNavigationBar: BottomNavigationBar(
        //默认选中第几个
        currentIndex: this._currentIndex,
        // 点击底部菜单触发的方法
        onTap: (int index){
          //print(index);
          //重新渲染页面
          setState(() {
            this._currentIndex = index;
          });
        },
        iconSize: 24.0, //Icon图标大小
        fixedColor: Colors.deepOrangeAccent, //选中之后的颜色
        type:BottomNavigationBarType.fixed , //配置底部，可以有多个按钮，默认3个
        //底部导航条按钮集合
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            // ignore: deprecated_member_use
            title: Text("首页"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            // ignore: deprecated_member_use
            title:Text("分类"),
          ),
          BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          // ignore: deprecated_member_use
            title:Text("发布"),
          ),
          BottomNavigationBarItem(
          icon: Icon(Icons.favorite,),
          // ignore: deprecated_member_use
            title:Text("收藏"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            // ignore: deprecated_member_use
            title:Text("我的"),
          )

        ],
      ),
//显示浮动按钮控件 FloatingActionButton
      floatingActionButton:Container(
        //floatingActionButton大小
        width: 60,
        height: 60,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          //floatingActionButton背景颜色
          color: Colors.white,
          //floatingActionButton背景变成圆形
          borderRadius: BorderRadius.circular(30), //设置宽度的一般
        ),
        child: FloatingActionButton(
          //浮动按钮内部图标
          child: Icon(Icons.add,color: Colors.white,size: 40,),
          //点击事件
          onPressed: (){
            //切换到分类页面
            setState(() {
              this._currentIndex = 2;
            });
          },
          //阴影
          //elevation: 10.0,
          //默认背景颜色,三元运算符
          backgroundColor: this._currentIndex==2?Colors.deepOrange:Colors.cyan,
          //backgroundColor: Colors.deepOrange,
        ),
      ),
      /**
       * 控制 FloatingActionButton 浮动按钮控件位置
       * centerFloat 底部中间位置
       * endFloat 右下角
       * centerDocked 底部中间位置，必centerFloat 还要往下一点
       * centerTop 顶部中间位置
       * startTop 左上角
       */
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class sunSddd extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return sunSdddson();
  }

}
class sunSdddson extends State {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Column(
      children: <Widget>[
        Text("Hello"),
      ],
    );
  }
}