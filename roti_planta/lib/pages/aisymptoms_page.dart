import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:roti_planta/pages/aichat_page.dart';
import 'package:roti_planta/appconfig.dart';
import 'package:roti_planta/pages/application_page.dart';
import 'package:roti_planta/pages/dietrec_page.dart';
import 'package:roti_planta/pages/minichat_page.dart';
import 'package:roti_planta/pages/profile_page.dart';
import 'package:roti_planta/pages/aiemotional_page.dart';
import 'package:roti_planta/pages/aimedicine_page.dart';

class AiSymptomsPage extends StatefulWidget {
  const AiSymptomsPage({super.key});

  @override
  _AiSymptomsPageState createState() => _AiSymptomsPageState();
}

class _AiSymptomsPageState extends State<AiSymptomsPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/check-symptoms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response received';
      } else {
        throw Exception('Failed to get response: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _handleSendMessage() async {
    if (_controller.text.isEmpty) return;

    String userMessage = _controller.text;
    setState(() {
      _messages.add({'text': userMessage, 'sender': 'user'});
      _isLoading = true;
    });
    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      String aiResponse = await sendMessage(userMessage);
      setState(() {
        _messages.add({'text': aiResponse, 'sender': 'ai'});
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      setState(() {
        _messages.add({'text': 'Error: $e', 'sender': 'ai'});
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkHealth().then((isHealthy) {
      if (!isHealthy) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Warning: Unable to connect to server')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF852745)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AiChatPage()),
            );
          },
        ),
        backgroundColor: Color(0xFFD59FA6),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD59FA6), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 0, right: 15, bottom: 10, left: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations?.checkSymptoms ?? 'Check Symptoms',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                      color: const Color(0xFF852745),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                localizations?.describeSymptoms ??
                                    'Describe your symptoms to me and I\'ll help you understand them.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.black,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/images/symptoms_icon.png',
                          height: 115,
                          color: const Color(0xFF852745),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Card(
                      elevation: 7.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: const Color(0xFFFFE5D9),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, right: 20, bottom: 15, left: 20),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 450,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color.fromARGB(255, 119, 26, 26),
                                  width: 1.5,
                                ),
                              ),
                              child: _messages.isEmpty
                                  ? Center(
                                      child: Text(
                                        // 'Start by describing your symptoms...',
                                        localizations?.sharingSymptoms ?? 'Start by describing your symptoms...',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.all(10.0),
                                      itemCount: _messages.length,
                                      itemBuilder: (context, index) {
                                        final message = _messages[index];
                                        final isUser = message['sender'] == 'user';
                                        return Align(
                                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                          child: Container(
                                            margin: const EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                                            padding: const EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 12),
                                            decoration: BoxDecoration(
                                              color: isUser ? Colors.yellow[200] : Colors.red[100],
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Text(
                                              message['text']!,
                                              style: TextStyle(
                                                color: isUser ? Colors.black : Colors.black87,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      hintText: localizations?.tellMeYourSymptoms ?? 'Tell me your symptoms ...',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 10.0,
                                      ),
                                    ),
                                    onSubmitted: (_) => _handleSendMessage(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(
                                    Icons.send,
                                    color: Color(0xFF852745),
                                  ),
                                  iconSize: 35.0,
                                  onPressed: _handleSendMessage,
                                ),
                              ],
                            ),
                            if (_isLoading)
                              const Padding(
                                padding: EdgeInsets.only(top: 10.0),
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: MiniChatWidget(
                currentPage: "AiSymptomsPage",
                onNavigateToProfile: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
                onNavigateToApps: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ApplicationPage()),
                  );
                },
                onNavigateToDiet: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DietRecPage()),
                  );
                },
                onNavigateToAiChat: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiChatPage()),
                  );
                },
                onNavigateToEmotionalSupport: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiEmotionalPage()),
                  );
                },
                onNavigateToCheckSymptoms: () {
                  Navigator.pop(context);
                },
                onNavigateToMedicineRecommendation: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiMedicinePage()),
                  );
                },
              ),
            ),
          );
        },
        child: Icon(Icons.chat, color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}