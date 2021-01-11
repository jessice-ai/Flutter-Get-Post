
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/tabs/sunAutoTb.dart';
import 'package:flutter_app/pages/tabs/sunTeam.dart';
import 'sunGoodsList.dart';
import 'sunCategory.dart';
import 'sunMy.dart';
import 'sunFooterTabsContent.dart';
import 'sunNews.dart';
import 'sunRegister.dart';
import 'sunRegisterSuccess.dart';
import 'sunRegisterSuccessReturn.dart';
import 'sunForm.dart';
import 'sunData.dart';
import 'sunCupertinoDatePicker.dart';
import 'sunDialog.dart';
import 'sunToast.dart';
import 'sunDio.dart';
import 'sunSearchBar.dart';
import 'sunProductDetailsPage.dart';
import 'sunCategoriesList.dart';
import 'package:flutter_app/Screens/Welcome/welcome_screen.dart';

// 命名路由需定义在 MaterialApp 中，接收的数据是Map类型，跟别名差不多，比如 加载名字为 sunGoodsList 的路由就是加载后面对应的控件
final routes = {
  "/goods":(context,{arguments})=>sunGoodsList(arguments:arguments),
  "/category":(context)=>sunCategory(),
  "/my":(context)=>sunMy(),
  "/sunTags":(context)=>sunFooterTabsContent(),
  "/sunNews":(context,{arguments})=>sunNews(arguments:arguments),
  "/sunRegister":(context)=>sunRegister(),
  "/sunRegisterSuccess":(context)=>sunRegisterSuccess(),
  "/sunRegisterSuccessReturn":(context)=>sunRegisterSuccessReturn(),
  "/sform":(context)=>sunForm(),
  "/sdata":(context)=>sunData(),
  "/sunCupert":(context)=>sunCupertinoDatePicker(),
  "/sunlog":(context)=>sunDialog(),
  "/sunoast":(context)=>sunToast(),
  "/sundio":(context)=>sunDio(),
  "/sunsearch":(context)=>sunSearchBar(),
  "/sunLogin":(context)=>WelcomeScreen(),
  "/sunproductcontent":(context,{arguments})=>sunProductDetailsPage(arguments:arguments),
  "/suncatlist":(context,{arguments})=>sunCategoriesList(arguments:arguments),
  "/sunTeam":(context)=>sunTeam(),
  "/sunTb":(context)=>sunAutoTb()

};

// onGenerateRoute 命名路由传递参数，一下代码是固定写法，直接拷贝即可
// ignore: missing_return, top_level_function_literal_block
var onGenerateRoute = (RouteSettings settings){
  //统一处理
  final String name=settings.name;
  final Function pageContentBuilder = routes[name];
  if(pageContentBuilder!=null){
    if(settings.arguments != null){
      final Route route=MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context,arguments:settings.arguments));
      return route;
    }else{
      final Route route=MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context));
      return route;
    }
  }
};