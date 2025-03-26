import 'dart:convert';
import '../main.dart';
import '../vision_detector_views/label_detector_view/face_class.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'trainmouth_model.dart';
export 'trainmouth_model.dart';
import '../vision_detector_views/label_detector_view/face_video.dart';

int Face_Detect_Number = 0;
class TrainmouthWidget extends StatefulWidget {
  const TrainmouthWidget({Key? key}) : super(key: key);

  @override
  _TrainmouthWidgetState createState() => _TrainmouthWidgetState();
}

class _TrainmouthWidgetState extends State<TrainmouthWidget> {
  late TrainmouthModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  var  gettime=DateTime.now();  //獲取按下去的時間
  var  gettime1;  //轉換輸出型態月日年轉年月日

  /*inputtime()async{
    var url = Uri.parse(ip+"inputtimeMOUTH.php");
    final responce = await http.post(url,body: {
      "account" : FFAppState().accountnumber,
      "degree":"進階",
      "parts":"口腔",
      "time": gettime1.toString(),
      "action": FFAppState().mouth,//動作
    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body); //將json解碼為陣列形式
      print(data["action"]);
      print(data["time"]);
      print(gettime1=dateTimeFormat('yyyy-M-d', gettime));//轉換輸出型態月日年轉年月日
      if("沒時間"==data["time"]){
        if("有訓練"==data["action"]||"有時間"==data["time"]){
          Navigator.push(context,
              MaterialPageRoute(builder: (context)=>FaceVideoApp()));
        }
        else{
          Navigator.push(context,
              MaterialPageRoute(builder: (context)=>FaceVideoApp()));
        }
      }
      else if(data["times"]=="1次"&&"有時間"==data["time"]){
        if(data["timeaction"]=="對"){
          Navigator.push(context,
              MaterialPageRoute(builder: (context)=>FaceVideoApp()));
        }
      }
      else if(data["times"]=="2次"){
        Navigator.push(context,
            MaterialPageRoute(builder: (context)=>FaceVideoApp()));
      }
    }
  }*/

  inputtime()async{                                                             //測試動作有無反應
    Navigator.push(context,
        MaterialPageRoute(builder: (context)=>FaceVideoApp()));
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TrainmouthModel());
  }

  @override
  void dispose() {
    _model.dispose();

    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBtnText,
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
          Expanded(
              child:Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.97,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: BoxDecoration(
                        color: Color(0xFF90BDF9),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [


                          Row(///標題口腔動作
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                                child: Image.asset(
                                  'assets/images/15.png',
                                  width: MediaQuery.of(context).size.width * 0.3,
                                  height: MediaQuery.of(context).size.height * 0.12,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20, 10, 0, 0),
                                child: Text(
                                  '口腔動作',
                                  textAlign: TextAlign.start,
                                  style: FlutterFlowTheme.of(context)
                                      .displaySmall
                                      .override(
                                    fontFamily: 'Poppins',
                                    fontSize: 50,
                                  ),
                                ),
                              ),
                            ],
                          ),



                          Expanded(
                            child: SingleChildScrollView(//允許 Column 內容可滾動
                              child: Column(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF90BDF9),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                          child: Wrap(//自動換行
                                            spacing: 60,// 垂直間距
                                            runSpacing: 20,// 垂直間距
                                            alignment: WrapAlignment.start,//讓按鈕置中對齊
                                            children: List.generate(11, (index) {//生成按鈕
                                              //  定義圖片
                                              List<String> buttonLabels = [
                                                '抿唇動作', '臉頰微笑', '吐舌頭式', '嘟嘴式', '張嘴說阿',
                                                '彈舌式', '頭頸側彎', '下巴運動', '發音練習', '頭部轉向', '肩部上下'
                                              ];

                                              List<int> detectNumbers = [6, 1, 2, 3, 4, 5, 7, 8, 9, 10, 11];
                                              //  設定圖片
                                              List<String> imagePaths = [
                                                'assets/images/57.png', // 抿唇動作
                                                'assets/images/44.png', // 臉頰微笑
                                                'assets/images/45.png', // 吐舌頭式
                                                'assets/images/55.png', // 嘟嘴式
                                                'assets/images/56.png', // 張嘴說阿
                                                'assets/images/46.png', // 彈舌式
                                                'assets/images/54.png', // 頭頸側彎
                                                'assets/images/53.png', // 下巴運動
                                                'assets/images/58.png', // 發音練習
                                                'assets/images/59.png', // 頭部左右轉向
                                                'assets/images/60.png', // 新動作2
                                              ];

                                              return GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    Face_Detect_Number = detectNumbers[index];
                                                    FFAppState().mouth = buttonLabels[index];
                                                  });
                                                  inputtime();
                                                },
                                                child: Column(
                                                  children: [
                                                    Image.asset(
                                                      imagePaths[index], //  設定的圖片
                                                      width: MediaQuery.of(context).size.width * 0.3,
                                                      height: MediaQuery.of(context).size.height * 0.15,
                                                      fit: BoxFit.fill,
                                                    ),
                                                    Text(
                                                      buttonLabels[index],
                                                      style: FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .override(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 28,//文字大小
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.safePop();
                                },
                                child: Image.asset(
                                  'assets/images/17.jpg',
                                  width:
                                  MediaQuery.of(context).size.width * 0.2,
                                  height:
                                  MediaQuery.of(context).size.height * 0.1,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                '返回',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Poppins',
                                  fontSize: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed('documental');
                                },
                                child: Image.asset(
                                  'assets/images/18.jpg',
                                  width:
                                  MediaQuery.of(context).size.width * 0.2,
                                  height:
                                  MediaQuery.of(context).size.height * 0.1,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                '使用紀錄',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Poppins',
                                  fontSize: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed('notice');
                                },
                                child: Image.asset(
                                  'assets/images/19.jpg',
                                  width:
                                  MediaQuery.of(context).size.width * 0.2,
                                  height:
                                  MediaQuery.of(context).size.height * 0.1,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                '新通知',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Poppins',
                                  fontSize: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed('about');
                                },
                                child: Image.asset(
                                  'assets/images/20.jpg',
                                  width:
                                  MediaQuery.of(context).size.width * 0.2,
                                  height:
                                  MediaQuery.of(context).size.height * 0.1,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                '關於',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Poppins',
                                  fontSize: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
