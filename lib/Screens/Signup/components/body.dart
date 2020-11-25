import 'package:flutter/material.dart';
import 'package:flutter_app/Screens/Login/login_screen.dart';
import 'package:flutter_app/Screens/Signup/components/background.dart';
import 'package:flutter_app/Screens/Signup/components/or_divider.dart';
import 'package:flutter_app/Screens/Signup/components/social_icon.dart';
import 'package:flutter_app/components/already_have_an_account_acheck.dart';
import 'package:flutter_app/components/rounded_button.dart';
import 'package:flutter_app/components/rounded_input_field.dart';
import 'package:flutter_app/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Body extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return BodydSon();
  }

}
class BodydSon extends State{
  String _sunName;
  String _sunPassword;
  //向服务器端提交数据
  _sunPostData() async{
    // print("${_sunName}");
    // print("${_sunPassword}");
    var ApiUrl = "https://pixabay.com/api/?key=17946669-543fe6c4c313739ab33b63515&q=yellow+flowers&image_type=photo&pretty=true";
    //{"name":"黄磊","age":23}这个是Map类型数据
    var result = await http.post(ApiUrl,body: {"name":"${_sunName}","password":"${_sunPassword}"});
    if(result.statusCode == 200){
      Map sunData = json.decode(result.body);  //把返回的json字符串类型数据，转化为Map类型
      print(sunData); //打印服务器端返回的数据
    }else{
      //打印错误码
      print(result.statusCode);
    }
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // TODO: implement build
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(
            //   "SIGNUP",
            //   style: TextStyle(fontWeight: FontWeight.bold),
            // ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),
            RoundedInputField(
              hintText: "邮箱",
              onChanged: (value) {
                setState(() {
                  _sunName = value;
                });
              },
            ),
            RoundedPasswordField(
              onChanged: (value) {
                setState(() {
                  _sunPassword=value;
                });
              },
            ),
            RoundedButton(
              text: "注册",
              press: () {
                //print("${_sunName}");  //账号
                //print("${_sunPassword}"); //密码
                if(_sunName==null || _sunName=="" || _sunPassword == null || _sunPassword == ""){
                  _sunToast("邮箱 / 密码不可空！");
                }
                var sunIsEmail = isEmail(_sunName);
                if(sunIsEmail==false){
                  _sunToast("邮箱格式不正确！");
                }
                //数据发送给服务器
                _sunPostData();
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
            OrDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SocalIcon(
                  iconSrc: "assets/icons/facebook.svg",
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/icons/twitter.svg",
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/icons/google-plus.svg",
                  press: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );;
  }
  bool isEmail(String em) {

    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  _sunToast(String message){
    Fluttertoast.showToast(
        msg: "${message}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, //提示信息展示位置
        timeInSecForIos: 10, //显示时间，这个只在IOS上有效，android 是默认时间
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  
}

