import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';

class sunData extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return sunDataSon();
  }

}

class sunDataSon extends State{
  DateTime _sunnow = DateTime.now();
  //日期选择:写法一
  // _sunShowDatePicker(){
  //   /**
  //    * showDatePicker 是用 Future 修饰的,所以是一个异步方法
  //    * 异步方法需要用.then获取异步选中的内容
  //    */
  //   showDatePicker(
  //       context: context,
  //       initialDate: _sunnow, //初始化的时候,当前日期
  //       firstDate: DateTime(1980), //日期可选范围中的开始日期
  //       lastDate:  DateTime(2100), //日期可选范围中的结束日期
  //   ).then((value){
  //     //value 是选中的值
  //     print(value);
  //   });
  // }

  //日期选择:写法二 重点在于 async await 两个关键词
  _sunShowDatePicker() async {
    //await关键词等待异步处理完成，返回结果,await本身必须是在一个异步函数中，所以需加async关键词
    var result = await showDatePicker(
      context: context,
      initialDate: _sunnow, //初始化的时候,当前日期
      firstDate: DateTime(1980), //日期可选范围中的开始日期
      lastDate:  DateTime(2100), //日期可选范围中的结束日期
    );
    //print(result);
    if(result==null) return; //这句需要加,否则用户点取消会报错
    setState(() {
      _sunnow = result;
    });
  }

  var _sunTimeOfDay = TimeOfDay(hour: 12,minute: 30);

  //时间选择，方式一
  // _sunshowDatePicker(){
  //   showTimePicker(
  //       context: context,
  //       initialTime: _sunTimeOfDay //初始值
  //   ).then((value){
  //     print(value);
  //     setState(() {
  //         _sunTimeOfDay = value;
  //     });
  //   });
  // }
  //时间选择，方式二
  _sunshowDatePicker() async{
    var sunResult_showTimePicker  = await showTimePicker(
        context: context,
        initialTime: _sunTimeOfDay
    );
    if(sunResult_showTimePicker==null) return; //这句需要加,否则用户点取消会报错
    setState(() {
      print(sunResult_showTimePicker);
      this._sunTimeOfDay = sunResult_showTimePicker;
    });
  }

  @override
  void initState(){
    print(_sunnow); //_sunnow: 2020-11-21 09:48:42.874642
    var timeStamp = _sunnow.millisecondsSinceEpoch; //把当前日期转化为时间戳
    print(timeStamp); //timeStamp:1605923462096
    var dateStr = DateTime.fromMillisecondsSinceEpoch(timeStamp); //把时间戳转化为日期
    print(dateStr); //dateStr:2020-11-21 09:54:30.687

    /**
     * 格式化时间需引入 date_format库
     */
    print(formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd," ",HH, ':', nn, ':', ss])); //  2020-11-21 20:30:05
    print(formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd])); //  2020-11-21
    print(formatDate(DateTime.now(), [yyyy, '年', mm, '月', dd,'日'])); //  2020年11月21日
    print(formatDate(DateTime.now(), [ mm, '/', dd])); //  11/21
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Scaffold(
      appBar: AppBar(
        title: Text("时间控件"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /**
               * InkWell 有水波纹的组件,可点击,用的比较多
               */
              InkWell(
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //Text("${_sunnow}"),
                    Text("日期选择："),
                    Text("${formatDate(_sunnow, [yyyy, '-', mm, '-', dd])}"),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
                //侦听onTap点击事件
                onTap: _sunShowDatePicker,
              ),
              InkWell(
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    Text("时间选择："),
                    //Text("${_sunTimeOfDay}"), //TimeOfDay(20:20)
                    Text("${_sunTimeOfDay.format(context)}"), // 20:20 AM
                    Icon(Icons.arrow_drop_down)
                  ],
                ),
                //侦听onTap点击事件
                onTap: _sunshowDatePicker,
              )
            ],
          )
        ],
      ),
    );
  }

}