import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/tabs/Routes.dart';


void main() {
  runApp(sunApp());
}

/// 自定义 Widget 组件
/// StatelessWidget 状态不可改变组件，抽象类，需要实现build方法
/// StatefulWidget 状态可改变组件

class sunApp extends StatelessWidget {

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
     *  routes 命名路由
     *  onGenerateRoute 命名路由传递参数
     */
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        //此处
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        //此处
        const Locale('zh', 'CH'),
        const Locale('en', 'US'),
      ],
      //home: sunFooterTabsContent(),
      initialRoute: '/sunTags',  //这个是App初始化时候加载那个路由
      //theme 主体
      theme: ThemeData(primaryColor: Colors.white),//修改主体颜色
      // onGenerateRoute 设置为命名路由 传递参数
      // ignore: missing_return

      onGenerateRoute: onGenerateRoute,

    );
  }
}

