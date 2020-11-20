
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class sunPicture extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunPictureSon();
  }

}

class sunPictureSon extends State{
  var sunFlag = true;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Switch(
                value: this.sunFlag,
                onChanged: (value){
                  setState(() {
                      this.sunFlag = value;
                      print("${value}");
                  });
                }
            )
          ],
        ),
      ),
    );
  }

}

