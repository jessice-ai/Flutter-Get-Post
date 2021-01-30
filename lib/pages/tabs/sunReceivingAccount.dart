import 'package:flutter/material.dart';

class sunReceivingAccount extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunReceivingAccountSon();
  }

}
class sunReceivingAccountSon extends State{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Scaffold(
      appBar: AppBar(
        title: Text("收款账号"),
      ),
      body: Column(
        children: [
          ListTile(
            onTap: () {
              //命名路由跳转到某个页面
              Navigator.pushNamed(context, '/sunali');
              //debugPrint("我的团队");
            },
            leading: Icon(Icons.account_balance_wallet),
            title: Text("支付宝"),
          ),
          Divider(
            height: 1,
            color: Colors.grey,
          )
        ],
      ),
    );
  }

}