import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'chat_message.dart';
import 'quiz_page.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _chatHistory = [];
  bool _isLoading = false;

  Future<void> sendJsonData(String newMessage) async {
    // Your API URL (replace with your local IP address)
    final String apiUrl = 'https://flashtutor-api.onrender.com/chat'; // Update with your IP address

    // Add user message to chat history
    setState(() {
      _chatHistory.add(ChatMessage(
        role: 'user',
        parts: [ChatPart(text: newMessage)],
      ));
      _isLoading = true;
      _scrollToBottom();
    });

    // Data to send
    Map<String, dynamic> data = {
      "history": _chatHistory.map((message) => message.toJson()).toList(),
      "newMessage": newMessage
    };

    // Convert data to JSON
    String jsonData = json.encode(data);

    // Send the request
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Successful response
        Map<String, dynamic> responseData = json.decode(response.body);

        // Log the response for debugging
        // print('Response data: $responseData');

        // Check if the 'message' field exists and is not null
        if (responseData.containsKey('response') && responseData['response'] != null) {
          ChatMessage modelMessage = ChatMessage(
            role: 'model',
            parts: [ChatPart(text: responseData['response'])],
          );

          // Add model response to chat history
          setState(() {
            _chatHistory.add(modelMessage);
            _isLoading = false;
            _scrollToBottom();
          });
        } else {
          print('Error: Response does not contain a valid message field');
        }
      } else {
        // Error response
        print('Failed to send data: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
          _isLoading = false;
        });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

   void _showQuizDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _numQuestionsController = TextEditingController();

        return AlertDialog(
          title: Text('Create Quiz'),
          content: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _numQuestionsController,
                decoration: InputDecoration(
                  labelText: 'Number of questions (max 20)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () async {
                int numQuestions = int.parse(_numQuestionsController.text);
                if (numQuestions > 20) {
                  showRedAlert(context, "Must not exceed 20");
                } else {
                  
                  Navigator.of(context).pop();
                  _scrollToBottom();
                  await _createQuiz(numQuestions);
                }
              },
            ),
          ],
        );
      },
    );
  }


void showRedAlert(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.redAccent,
        title: Text(
          'Error',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  Future<void> _createQuiz(int numQuestions) async {
    final String apiUrl = 'https://flashtutor-api.onrender.com/quiz'; // Update with your IP address

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> data = {
      "history": _chatHistory.map((message) => message.toJson()).toList(),
      "numQuestions": numQuestions,
    };

    String jsonData = json.encode(data);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        final quizData = (jsonDecode(response.body) as Map<String, dynamic>)['questions'] as List;
        final List<Map<String, dynamic>> formattedQuizData = quizData.map((e) => Map<String, dynamic>.from(e)).toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizPage(quizData: formattedQuizData),
          ),
        );
      } else {
        print('Failed to create quiz: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
  title: Row(
    children: [
      // Spacer to push text to the center
      Spacer(),
      Text(
        'FlashTutor',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22, // Adjust font size for better visibility
          color: Colors.black, // Text color
          letterSpacing: 1.2, // Spacing between letters
          shadows: [
            Shadow(
              blurRadius: 4.0,
              color: Colors.black.withOpacity(0.6),
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
      Spacer(flex: 2), // Extra space between text and icon
      IconButton(
        icon: Icon(Icons.quiz, size: 30), // Adjust icon size
        onPressed: _showQuizDialog,
        color: Colors.black, // Icon color
      ),
    ],
  ),
  backgroundColor: Colors.amber, // AppBar background color
  elevation: 4, // Shadow under the AppBar
  centerTitle: false,
)

,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_chatHistory.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    "Welcome to FlashTutor!\nStart a conversation with the model on educational topics, then generate quizzes to test your knowledge.\nTap the quiz icon at the top to create a quiz based on your chat.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            if (_chatHistory.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoading && index == _chatHistory.length) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final message = _chatHistory[index];
                    return Align(
                      alignment: message.role == 'user'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: message.role == 'user'
                              ? Color.fromARGB(255, 245, 196, 122)
                              : Color.fromARGB(255, 172, 240, 109),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: MarkdownBody(
                          data: message.parts.map((part) => part.text).join("\n"),
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(fontSize: 16),
                            strong: TextStyle(fontWeight: FontWeight.bold),
                            // Add more markdown styles as needed
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      labelText: 'Developed by Favour Solomon',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                     style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.black),
                    onPressed: () {
                      String newMessage = _controller.text;
                      _controller.clear();
                      sendJsonData(newMessage);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}