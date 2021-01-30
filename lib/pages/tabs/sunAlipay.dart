import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class sunAlipay extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunAlipaySon();
  }
}

class sunAlipaySon extends State {
  String alipay_name;
  int _sunUserID;
  String accountnumber;
  Future<SharedPreferences> _sunPrefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    //验证用户登陆状态
    initFromCache().then((result) {
      this._sunUserID = result;
      _sunGetAlipay();
    });
  }

  //获取用户支付宝信息
  _sunGetAlipay() async {
    Map sunJsonData = {"uid": _sunUserID};
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tb/getAlipay",
            // ignore: missing_return
            data: sunJsonData)
        // ignore: missing_return
        .then((value) {
      if (value.data['code'] == 200) {
        if (mounted) {
          setState(() {
            this.alipay_name = value.data['data']["alipay_name"];
            this.accountnumber = value.data['data']["alipay_account"];
          });
        }
      }
    });
  }

  //获取用户登陆数据
  initFromCache() async {
    SharedPreferences prefs = await _sunPrefs;
    int intValue = prefs.getInt("sunId"); //获取用户登陆ID
    //print("${intValue}");
    if (intValue != "" && intValue != null) {
      return intValue;
    } else {
      //用户登陆
      //命名路由跳转到某个页面
      Navigator.pushNamed(context, '/sunLogin');
    }
  }

  _sunPAlipay() async {
    Map sunJsonData = {
      "uid": _sunUserID,
      "name": this.alipay_name,
      "accountnumber": this.accountnumber
    };
    //print("参数:${sunJsonData}");
    var sunDio = Dio();
    Response sunResponse = await sunDio
        .post("https://www.shsun.xyz/tb/Alipay",
            // ignore: missing_return
            data: sunJsonData)
        .then((value) {
      if (value.data['code'] == 200) {
        _sunToast("保存成功！");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Scaffold(
      appBar: AppBar(
        title: Text("支付宝设置"),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [

              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text("支付宝姓名："),
                      )),
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: this.alipay_name,
                        ),
                        onChanged: (value) {
                          setState(() {
                            this.alipay_name = value;
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
              Divider(
                height: 1,
                color: Colors.grey,
              ),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text("支付宝账号："),
                      )),
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: this.accountnumber,
                        ),
                        onChanged: (value) {
                          setState(() {
                            this.accountnumber = value;
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
              Divider(
                height: 1,
                color: Colors.grey,
              ),
              Container(
                height: 20.0,
              ),
              Container(
                //把Container改成自适应
                width: double.infinity,
                height: 40,
                child: RaisedButton(
                  child: Text("保存"),
                  onPressed: () {
                    // print(this.name);
                    // print(this.accountnumber);
                    if (this.alipay_name == null || this.alipay_name == "") {
                      _sunToast("请输入支付宝姓名");
                    }
                    if (this.accountnumber == null ||
                        this.accountnumber == "") {
                      _sunToast("请输入支付宝账号");
                    }
                    _sunPAlipay();
                  },
                  color: Colors.deepOrange,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
