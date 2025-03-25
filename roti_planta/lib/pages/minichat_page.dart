import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roti_planta/appconfig.dart';

class MiniChatWidget extends StatefulWidget {
  final VoidCallback onNavigateToProfile;
  final VoidCallback onNavigateToApps;
  final VoidCallback onNavigateToDiet;
  final VoidCallback onNavigateToAiChat;
  final VoidCallback onNavigateToEmotionalSupport;
  final VoidCallback onNavigateToCheckSymptoms;
  final VoidCallback onNavigateToMedicineRecommendation;
  final String currentPage; 

  const MiniChatWidget({
    Key? key,
    required this.onNavigateToProfile,
    required this.onNavigateToApps,
    required this.onNavigateToDiet,
    required this.onNavigateToAiChat,
    required this.onNavigateToEmotionalSupport,
    required this.onNavigateToCheckSymptoms,
    required this.onNavigateToMedicineRecommendation,
    required this.currentPage,
  }) : super(key: key);

  @override
  _MiniChatWidgetState createState() => _MiniChatWidgetState();
}

class MiniChatService {
  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      ).timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception("Request timed out. Please check your network connection.");
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey("response")) {
          return data["response"];
        } else {
          throw Exception("Invalid response format from server: ${response.body}");
        }
      } else if (response.statusCode == 404) {
        throw Exception("Chat service not found. Please ensure the backend server is running.");
      } else {
        throw Exception("Failed to get response from chat: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error communicating with backend: $e");
    }
  }
}

class _MiniChatWidgetState extends State<MiniChatWidget> {
  final MiniChatService _miniChatService = MiniChatService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  String _currentStep = "start"; // Track the user's current step in the flow

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _loadUserProgress();
  }

  // Load chat history from Firestore
  void _loadChatHistory() async {
    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('chat_history')
            .orderBy('timestamp')
            .get();

        if (snapshot.docs.isEmpty) {
          // If no chat history, add the initial message
          _messages.add({
            "role": "bot",
            "content": "Welcome to VCare! You’re signed in—ready to get started? Just ask, 'What should I do now?'"
          });
          _saveMessageToFirestore("bot", _messages.last["content"]!);
        } else {
          // Load existing chat history
          for (var doc in snapshot.docs) {
            _messages.add({
              "role": doc['role'],
              "content": doc['content'],
            });
          }
        }
      } catch (e) {
        print("Error loading chat history: $e");
        _messages.add({
          "role": "bot",
          "content": "Welcome to VCare! You’re signed in—ready to get started? Just ask, 'What should I do now?'"
        });
      }
    }

    setState(() {
      _isLoading = false;
    });

    // Scroll to the bottom after loading messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Load user progress from Firestore
  void _loadUserProgress() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc['chat_progress'] != null) {
          setState(() {
            _currentStep = doc['chat_progress'];
          });
        }
      } catch (e) {
        print("Error loading user progress: $e");
      }
    }
  }

  // Save a message to Firestore
  void _saveMessageToFirestore(String role, String content) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('chat_history')
            .add({
          "role": role,
          "content": content,
          "timestamp": FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Error saving message to Firestore: $e");
      }
    }
  }

  // Save user progress to Firestore
  void _saveUserProgress(String step) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          "chat_progress": step,
        }, SetOptions(merge: true));
        setState(() {
          _currentStep = step;
        });
      } catch (e) {
        print("Error saving user progress: $e");
      }
    }
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    String userMessage = _controller.text;
    setState(() {
      _messages.add({"role": "user", "content": userMessage});
      _controller.clear();
    });

    // Save user message to Firestore
    _saveMessageToFirestore("user", userMessage);

    // Scroll to the bottom after adding a new message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      String botResponse = await _miniChatService.sendMessage(userMessage);
      setState(() {
        _messages.add({"role": "bot", "content": botResponse});
      });
      // Save bot response to Firestore
      _saveMessageToFirestore("bot", botResponse);

      // Update progress based on user message and current page
      if (userMessage.toLowerCase().contains("what should i do now")) {
        if (widget.currentPage == "HomePage" && _currentStep == "start") {
          _saveUserProgress("profile");
        } else if (widget.currentPage == "ProfilePage" && _currentStep == "profile") {
          _saveUserProgress("apps");
        } else if (widget.currentPage == "ApplicationPage" && _currentStep == "apps") {
          _saveUserProgress("diet");
        } else if (widget.currentPage == "DietRecPage" && _currentStep == "diet") {
          _saveUserProgress("aichat");
        }
      } else if (userMessage.toLowerCase().contains("done with my profile") && widget.currentPage == "ProfilePage") {
        _saveUserProgress("apps");
      }
    } catch (e) {
      String errorMessage = "Sorry, I couldn't process your request: $e. Please try again.";
      setState(() {
        _messages.add({"role": "bot", "content": errorMessage});
      });
      _saveMessageToFirestore("bot", errorMessage);
    }

    // Scroll to the bottom after bot response
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildNavigationButton(String botMessage) {
    // Determine the appropriate button based on the current step and page
    if (widget.currentPage == "HomePage" && _currentStep == "start") {
      return ElevatedButton(
        onPressed: () {
          widget.onNavigateToProfile();
          _saveUserProgress("profile");
        },
        child: Text("Go to Profile Page"),
      );
    } else if (widget.currentPage == "ProfilePage" && _currentStep == "profile") {
      return SizedBox.shrink(); // No button, wait for "Done with my profile"
    } else if ((widget.currentPage == "ProfilePage" && _currentStep == "apps") ||
               (widget.currentPage == "HomePage" && _currentStep == "apps")) {
      return ElevatedButton(
        onPressed: () {
          widget.onNavigateToApps();
          _saveUserProgress("apps");
        },
        child: Text("Go to APPS Page"),
      );
    } else if ((widget.currentPage == "ApplicationPage" && _currentStep == "apps") ||
               (widget.currentPage == "ProfilePage" && _currentStep == "diet") ||
               (widget.currentPage == "HomePage" && _currentStep == "diet")) {
      return ElevatedButton(
        onPressed: () {
          widget.onNavigateToDiet();
          _saveUserProgress("diet");
        },
        child: Text("Go to DIET Page"),
      );
    } else if ((widget.currentPage == "DietRecPage" && _currentStep == "diet") ||
               (widget.currentPage == "ApplicationPage" && _currentStep == "aichat") ||
               (widget.currentPage == "ProfilePage" && _currentStep == "aichat") ||
               (widget.currentPage == "HomePage" && _currentStep == "aichat")) {
      return ElevatedButton(
        onPressed: () {
          widget.onNavigateToAiChat();
          _saveUserProgress("aichat");
        },
        child: Text("Go to AI Chat Page"),
      );
    } else if (botMessage.contains("Emotional Support")) {
      return ElevatedButton(
        onPressed: widget.onNavigateToEmotionalSupport,
        child: Text("Try Emotional Support"),
      );
    } else if (botMessage.contains("Check Symptoms")) {
      return ElevatedButton(
        onPressed: widget.onNavigateToCheckSymptoms,
        child: Text("Try Check Symptoms"),
      );
    } else if (botMessage.contains("Medicine Recommendation")) {
      return ElevatedButton(
        onPressed: widget.onNavigateToMedicineRecommendation,
        child: Text("Try Medicine Recommendation"),
      );
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isBot = message["role"] == "bot";
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isBot ? Colors.grey[200] : Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message["content"]!,
                              style: TextStyle(
                                color: isBot ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                          if (isBot) _buildNavigationButton(message["content"]!),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (value) => _sendMessage(),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}