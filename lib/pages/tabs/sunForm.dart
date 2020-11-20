import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
class sunForm extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunFormSon();
  }

}
class sunFormSon extends State{
  String name;
  String info;
  int sex=1;
  List  hobby = [
    {
      "checked":true,
      "title":"吃饭"
    },
    {
      "checked":false,
      "title":"睡觉"
    },
    {
      "checked":true,
      "title":"看电影"
    }
  ];
  List<Widget> _getHobby(){
    List<Widget> tempList = [];
      for(var i=0;i<this.hobby.length;i++){
        tempList.add(
          Row(
            children: [
              Text(this.hobby[i]["title"]+":"),
              Checkbox(
                value: this.hobby[i]["checked"],
                onChanged: (value){
                  setState(() {
                    this.hobby[i]["checked"] = value;
                  });
                },
              )
            ],
          )
        );
      }
      return tempList;
  }

  void _sexChange(value){
    setState(() {
      this.sex = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Scaffold(
      appBar: AppBar(
        title: Text("学员信息录入"),

      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: "输入用户信息",
              ),
              onChanged: (value){
                  setState(() {
                    this.name = value;
                  });
              },
            ),
            Row(
              children: <Widget>[
                Text("男"),
                Radio(
                    value: 1,
                    groupValue: this.sex,
                    onChanged: this._sexChange,

                ),
                Text("女"),
                Radio(
                  value: 2,
                  groupValue: this.sex,
                  onChanged: this._sexChange,
                ),

              ],
            ),
            SizedBox(height: 10,),
            Column(
              children: this._getHobby(),
            ),
            SizedBox(height: 10,),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "介绍",
                border: OutlineInputBorder()
              ),
              onChanged: (value){
                setState(() {
                  this.info = value;
                });
              },
            ),
            SizedBox(height: 10,),
            Container(
              //把Container改成自适应
              width: double.infinity,
              height: 40,
              child: RaisedButton(
                child: Text("登陆"),
                onPressed: (){
                  print(this.sex);
                  print(this.name);
                  print(this.hobby);
                  print(this.info);
                },
                color: Colors.deepOrange,
                textColor: Colors.white,
              ),
            ),


          ],
        ),
      ),
    );
  }

}