
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:date_format/date_format.dart';

class sunCupertinoDatePicker extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunCupertinoDatePickerSon();
  }
}

class sunCupertinoDatePickerSon extends State{
  DateTime _sundateTime = DateTime.now();
  static const String _sunMinDatetime = "2020-05-12";
  static const String _sunMaxDatetime = "2029-05-12";
  // ignore: non_constant_identifier_names
  _sun_flutter_cupertino_date_picker(){
    DatePicker.showDatePicker(
        context,
        pickerTheme:DateTimePickerTheme(
            showTitle: true,
            confirm: Text(
              "确定",
              style: TextStyle(
                color: Colors.red
              ),
            ),
          cancel: Text(
            "取消",
            style: TextStyle(
                color: Colors.red
            ),
          ),
        ),
        minDateTime: DateTime.parse(_sunMinDatetime),//起始日期
        maxDateTime: DateTime.parse(_sunMaxDatetime),//结束日期
        initialDateTime: _sundateTime, //初始化时间
        //dateFormat: "yyyy-MMMM-dd", //显示格式
        dateFormat: 'yyyy年M月d日 EEE,H时:m分', //显示格式
        pickerMode: DateTimePickerMode.datetime,
        locale: DateTimePickerLocale.zh_cn, //语言
        onCancel: (){
          debugPrint("取消");
        },
        // onChange: (datetime,List(int) index){
        //   setState(() {
        //     _sundateTime = datetime;
        //   });
        // },
        onConfirm: (value,List<int> index){
            setState(() {
              _sundateTime = value;
            });
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Scaffold(
      appBar: AppBar(
        title: Text("flutter_cupertino_date_picker"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            //主轴居中
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //水波纹区块按钮
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("${formatDate(_sundateTime, [yyyy, '-', mm, '-', dd," ",HH, ':', nn, ':', ss])}"),
                    Icon(Icons.arrow_drop_down)
                  ],
                ),
                //水波纹区块点击事件
                onTap: _sun_flutter_cupertino_date_picker,
              )
            ],
          )
        ],
      )
    );
  }

}