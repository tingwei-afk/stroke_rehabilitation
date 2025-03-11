import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stroke_rehabilitation_app/vision_detector_views/label_detector_view/detect_headneck_bend.dart';
import 'package:stroke_rehabilitation_app/vision_detector_views/label_detector_view/detect_pursed_lips.dart';
import '../../trainmouth/trainmouth_widget.dart';
import '../../main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../flutter_flow/flutter_flow_util.dart';





// void main() => runApp(const MyApp());

// class speech extends StatelessWidget {
//   const speech({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: PhonemeSelectionScreen(), // 啟動時顯示音節選擇畫面
//     );
//   }
// }

/// **第一個畫面：讓使用者選擇 PA、TA、KA**
class speech extends StatefulWidget {
  const speech({super.key});

  @override
  State<speech> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<speech> {
  final Set<String> _completedPhonemes = {}; // 用來追蹤已測試音節

  void _navigateToDetectionScreen(BuildContext context, String phoneme) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SoundDetectionScreen(
          selectedPhoneme: phoneme,
        ),
      ),
    );

    // 測完回來，加入已完成的音節
    setState(() {
      _completedPhonemes.add(phoneme);
    });

    // **當三個音節都測完時，自動跳轉到 TrainmouthWidget**
    if (_completedPhonemes.containsAll(["PA", "TA", "KA"])) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TrainmouthWidget()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            color: Colors.blue[500]!,
            child: Row(
              children: [
                Image.asset('assets/images/58.png', width: 50, height: 50),
                const SizedBox(width: 10),
                const Text(
                  "訓練音節",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPhonemeButton(context, "PA"),
                      const SizedBox(width: 20),
                      _buildPhonemeButton(context, "TA"),
                      const SizedBox(width: 20),
                      _buildPhonemeButton(context, "KA"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "已完成：${_completedPhonemes.length}/3",
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhonemeButton(BuildContext context, String phoneme) {
    bool isCompleted = _completedPhonemes.contains(phoneme);

    return GestureDetector(
      onTap: isCompleted ? null : () => _navigateToDetectionScreen(context, phoneme),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isCompleted ? Colors.grey : Colors.blue[300]!,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            phoneme,
            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}


/// **第二個畫面：偵測聲音**
class SoundDetectionScreen extends StatefulWidget {
  final String selectedPhoneme;

  const SoundDetectionScreen({super.key, required this.selectedPhoneme});

  @override
  State<SoundDetectionScreen> createState() => _SoundDetectionScreenState();
}

class _SoundDetectionScreenState extends State<SoundDetectionScreen>
    with SingleTickerProviderStateMixin {
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  bool _isListening = false;
  double _soundLevel = 0.0;
  int _wordCount = 0;
  bool _hasAddedWord = false;
  double _dBThreshold = 80.0;

  // 動畫控制
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // 倒數計時
  Timer? _countdownTimer;
  int _remainingTime = 10; // 設定倒數 10 秒

  @override
  void initState() {
    super.initState();
    _requestPermissions();/// 請求麥克風權限

    // 動畫：讓氣泡變大縮小
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),// 動畫時間 500ms
      lowerBound: 1.0,
      upperBound: 2,// 放大 2 倍
    );
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.3).animate(_animationController);///開始後大小
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  void _startListening() {
    if (_isListening) return;

    _resetValues();// 重置計數與變數
    _noiseMeter ??= NoiseMeter();

    try {// 開始監聽音量
      _noiseSubscription = _noiseMeter!.noiseStream.listen((noiseEvent) {
        setState(() {
          _soundLevel = noiseEvent.meanDecibel;//更新音量數據

          if (_soundLevel > _dBThreshold) {
            if (!_hasAddedWord) {
              _wordCount++;
              _hasAddedWord = true;
            }
            _animationController.forward();// 氣泡放大
          } else {
            _hasAddedWord = false;
            _animationController.reverse();// 氣泡縮小
          }
        });
      }, onError: (e) {
        debugPrint('噪音偵測錯誤：$e');
        _stopListening();
      });

      // 開始倒數計時
      _startCountdown();
    } catch (e) {
      debugPrint('啟動偵測時發生錯誤：$e');
      _stopListening();
    }

    setState(() => _isListening = true);
  }

  void _stopListening() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    _noiseMeter = null;
    _countdownTimer?.cancel(); // 停止倒數
    setState(() {
      _isListening = false;
    });
  }

  void _resetValues() {
    setState(() {
      _wordCount = 0;
      _soundLevel = 0.0;
      _hasAddedWord = false;
      _remainingTime = 10; // 重置倒數
    });
  }

  // **開始倒數計時**
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 1) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        _navigateToResultScreen();
      }
    });
  }

  // 倒數結束後，跳轉到結果畫面
  void _navigateToResultScreen() {
    _stopListening();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectionResultScreen(detectedWordCount: _wordCount),
      ),
    );
  }

  // 計算顏色變化
  Color _getBubbleColor(double dB) {
    if (dB < 60) return Colors.blue[300]!;
    // if (dB < 80) return Colors.orange[300]!;
    return Colors.blue[300]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(//內容垂直排列
        mainAxisAlignment: MainAxisAlignment.center,//內容置中對齊
        children: [
          const Spacer(),
          Center(
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _getBubbleColor(_soundLevel),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 3,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.selectedPhoneme,
                          style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Text(
                        //   "${_soundLevel.toStringAsFixed(1)} ",
                        //   style: const TextStyle(
                        //     fontSize: 18,
                        //     color: Colors.white70,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),///PA,TA,KA按鈕距離
            child: Column(  ///垂直排列Text 和 Slider 兩個元件
              children: [
                Text(
                  "設定偵測門檻：${_dBThreshold.toStringAsFixed(0)} ",///小數店後一位
                  style: const TextStyle(fontSize: 18),///字體大小
                ),
                Slider(     ///滑桿
                  value: _dBThreshold,
                  min: 30,
                  max: 150,
                  divisions: 120,///範圍 切成 120 份，例如:31、32、33dB
                  label: _dBThreshold.toStringAsFixed(1),///滑桿的小數點後一位
                  onChanged: (value) {
                    setState(() {///更新 _dBThreshold 的數值
                      _dBThreshold = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "倒數 $_remainingTime 秒...",
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
          const Spacer(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? _stopListening : _startListening,
        tooltip: '開始/停止偵測',
        backgroundColor: _isListening ? Colors.red : Colors.blue,
        child: Icon(
          _isListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {//取消動作
    _noiseSubscription?.cancel();
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }
}

// **偵測結果畫面**
class DetectionResultScreen extends StatelessWidget {
  final int detectedWordCount;

  const DetectionResultScreen({super.key, required this.detectedWordCount});//接收偵測到的字數，並在畫面上顯示。

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/58.png', width: 150),
            const SizedBox(height: 20),
            Text(' $detectedWordCount 個字', style: const TextStyle(fontSize: 24, color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await endout9(); // 确保 endout9() 執行完再返回
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TrainmouthWidget()),
                ); // 重新加载 TrainmouthWidget
              },
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
Future<void> endout9() async {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  var url;
  if(Face_Detect_Number==9){                //抿嘴
    url = Uri.parse(ip+"train_mouthok.php");
    print("初階,吞嚥");
  }
  final responce = await http.post(url,body:{
    "time": formattedDate,
    "account": FFAppState().accountnumber.toString(),
    "action": FFAppState().mouth.toString(), //動作
    "degree": "初階",
    "parts": "吞嚥",
    "times": "1", //動作
    "coin_add": "5",
  });
  if (responce.statusCode == 200) {
    print("ok");
  } else {
    print(responce.statusCode);
    print("no");
  }
}