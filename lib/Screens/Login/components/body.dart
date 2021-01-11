import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_app/Screens/Login/components/background.dart';
import 'package:flutter_app/Screens/Signup/signup_screen.dart';
import 'package:flutter_app/components/already_have_an_account_acheck.dart';
import 'package:flutter_app/components/rounded_button.dart';
import 'package:flutter_app/components/rounded_input_field.dart';
import 'package:flutter_app/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_app/pages/tabs/sunFooterTabsContent.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class Body extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return BodySon();
  }
}

class BodySon extends State{
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  /**
   * Flutter 使用 shared_preferences 包实现数据持久化，数据写入内存中
   */
  Future<void> _incrementCounter() async {
    final SharedPreferences prefs = await _prefs;

    prefs.setString("sunEmail",_sunEmail );
    prefs.setString("sunPhone",_sunPhone );
    prefs.setString("sunNickname",_sunNickname );
    prefs.setString("sunAvailable_quota",_sunAvailable_quota );
    prefs.setInt("sunId",_sunId );

  }
  List _sunData;
  String _sunName;
  String _sunPassword;
  String _sunEmail;
  int _sunId;
  String _sunNickname;
  String _sunPhone;
  String _sunAvailable_quota;

  //向服务器端提交数据
  _sunPostData() async{
    var ApiUrl = "http://39.98.92.36/User/login";
    //{"name":"黄磊","age":23}这个是Map类型数据
    var result = await http.post(ApiUrl,body: {"email":"${_sunName}","password":"${_sunPassword}"});
    if(result.statusCode == 200){
      Map sunData = json.decode(result.body);  //把返回的json字符串类型数据，转化为Map类型
      _sunToast(sunData['message']); //登陆成功提示

      if(sunData['code']==200){
        _sunEmail = sunData['data']["email"];
        _sunId = sunData['data']["id"];
        _sunNickname = sunData["data"]["nickname"];
        _sunPhone = sunData["data"]["phone"];
        _sunNickname = sunData["data"]["nickname"];
        _sunAvailable_quota = sunData["data"]["available_quota"];

        _incrementCounter();

        //销毁之前所有跳转记录，直接返回指定的页面
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (context) => new sunFooterTabsContent(index: 4,)), (route)=> route == null);
      }
      //print(sunData); //打印服务器端返回的数据
    }else{
      //打印错误码
      _sunToast("网络请求异常!");
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(
            //   "LOGIN",
            //   style: TextStyle(fontWeight: FontWeight.bold),
            // ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/login.svg",
              height: size.height * 0.35,
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              hintText: "邮箱",
              onChanged: (value) {
                setState(() {
                  _sunName = value;
                });
              },
            ),
            RoundedPasswordField(
              label: "密码",
              onChanged: (value) {
                setState(() {
                  _sunPassword=value;
                });
              },
            ),
            RoundedButton(
              text: "登陆",
              press: () {
                if(_sunName==null || _sunName=="" || _sunPassword == null || _sunPassword == ""){
                  _sunToast("邮箱 / 密码不可空！");
                  return false;
                }
                var sunIsEmail = isEmail(_sunName);
                if(sunIsEmail==false){
                  _sunToast("邮箱格式不正确！");
                  return false;
                }
                //数据发送给服务器
                _sunPostData();
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  _sunToast(String message){
    Fluttertoast.showToast(
        msg: "${message}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, //提示信息展示位置
        timeInSecForIos: 10, //显示时间，这个只在IOS上有效，android 是默认时间
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  bool isEmail(String em) {

    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

}