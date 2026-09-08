import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const GuardianApp());
}

class GuardianApp extends StatelessWidget {
  const GuardianApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Core',
      theme: ThemeData.dark(),
      home: const GuardianHomeScreen(),
    );
  }
}

class GuardianHomeScreen extends StatefulWidget {
  const GuardianHomeScreen({Key? key}) : super(key: key);

  @override
  _GuardianHomeScreenState createState() => _GuardianHomeScreenState();
}

class _GuardianHomeScreenState extends State<GuardianHomeScreen> {
  final String _geminiApiKey = "AQ.Ab8RN6Jz0fto_IGwT_0zUcz0ud7KUe8y6G6oqe-VD-5MEi-GYg"; 
  
  String _recognizedText = "周囲の音声を監視していません。";
  String _aiStatus = "SAFE";
  String _aiAnalysisLog = "システム待機中...";
  bool _isAlertTriggered = false;

  void _simulateTraffickingDialogue() {
    setState(() {
      _recognizedText = "未経験でも月収100万円以上保証するよ。まずはカンボジアのポイペト（Poipet）のオフィスに来て。旅費もホテル代も全部こっちで持つから心配いらない。ただ、セキュリティの関係でパスポートと携帯は一度オフィスの金庫で預かるね。会社のルールだから、断るならここから帰すわけにはいかないよ。";
    });
    _auditWithGeminiAPI(_recognizedText);
  }

  void _simulateSafeDialogue() {
    setState(() {
      _recognizedText = "今日はオーンと一緒にシェムリアップのアンコールワット近くのカフェで美味しいコーヒーを飲んでいます。天気がとても良くて幸運な一日です。";
    });
    _auditWithGeminiAPI(_recognizedText);
  }

  Future<void> _auditWithGeminiAPI(String text) async {
    setState(() {
      _aiAnalysisLog = "AI語源・文脈監査を実行中...";
    });

    final String url = "https://googleapis.com";

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {"text": text}
          ]
        }
      ],
      "systemInstruction": {
        "parts": [
          {
            "text": "あなたはラックヌンロイバァーン株式会社の防衛AIです。入力されたテキストから人身売買、監禁、AI詐欺の文脈を監査してください。日常会話なら必ず「SAFE」の4文字のみを出力。危険を検知した場合は厳格に以下のJSONフォーマットのみを出力して、前置きは一切書かないでください。{\"status\": \"ALERT\", \"risk_category\": \"犯罪ジャンル\", \"confidence_score\": \"危険度0-1\", \"detected_text_segment\": \"該当テキスト\", \"linguistic_analysis\": \"語源・理由の解説\"}"
          }
        ]
      }
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String aiResponseText = responseData['candidates']['content']['parts']['text'].toString().trim();

        if (aiResponseText.contains("ALERT")) {
          final cleanJson = aiResponseText.substring(
            aiResponseText.indexOf('{'),
            aiResponseText.lastIndexOf('}') + 1,
          );
          final Map<String, dynamic> logData = jsonDecode(cleanJson);

          setState(() {
            _aiStatus = "ALERT";
            _isAlertTriggered = true;
            _aiAnalysisLog = "【⚠️ 証拠ロック完了・特殊部隊出動シグナル】\n\n■ リスク分類: ${logData['risk_category']}\n■ 危険度スコア: ${logData['confidence_score']}\n\n■ 語源・文脈解析:\n${logData['linguistic_analysis']}";
          });
        } else {
          setState(() {
            _aiStatus = "SAFE";
            _isAlertTriggered = false;
            _aiAnalysisLog = "監査完了: 異常なし（SAFE）\n平和な会話、または犯罪の文脈は含まれていません。";
          });
        }
      } else {
        setState(() {
          _aiAnalysisLog = "APIエラー: ステータスコード ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _aiAnalysisLog = "通信エラーが発生しました: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isAlertTriggered ? const Color(0xFF4A0000) : const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Guardian Core v1.0', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isAlertTriggered ? Colors.redAccent : Colors.greenAccent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("SYSTEM AUDIT STATUS:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(
                      _aiStatus,
                      style: TextStyle(
                        color: _isAlertTriggered ? Colors.redAccent : Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text("【検知音声・テキストストリーム】", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                height: 120,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SingleChildScrollView(
                  child: Text(_recognizedText, style: const TextStyle(fontSize: 13, height: 1.4)),
                ),
              ),
              const SizedBox(height: 15),
              const Text("【LUCK NUNG ROI BAAN：AI監査ログ】", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                height: 180,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _aiAnalysisLog,
                    style: TextStyle(
                      color: _isAlertTriggered ? Colors.orangeAccent : Colors.white70,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _simulateSafeDialogue,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text("日常会話テスト", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _simulateTraffickingDialogue,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: const Text("人身売買テスト", style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

