import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final List<Map<String, dynamic>> quizData;

  QuizPage({required this.quizData});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentIndex = 0;
  Map<int, String?> _selectedAnswers = {};
  bool _quizSubmitted = false;

  void _nextQuestion() {
    if (_currentIndex < widget.quizData.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _selectAnswer(String? answer) {
    setState(() {
      _selectedAnswers[_currentIndex] = answer;
    });
  }

  void _submitQuiz() {
    setState(() {
      _quizSubmitted = true;
    });

    // Implement your logic to calculate score
  }

  void _resetQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedAnswers.clear();
      _quizSubmitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quizData[_currentIndex];
    final totalQuestions = widget.quizData.length;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text(_quizSubmitted ? 'Quiz Results' : 'Quiz'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: _quizSubmitted
          ? _buildQuizResults()
          : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${_currentIndex + 1}/$totalQuestions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    question['question'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (question['options'] as List<dynamic>).map((option) {
                      return RadioListTile<String?>(
                        title: Text(option.toString(), style: TextStyle(color: Colors.white),),
                        value: option.toString(),
                        groupValue: _selectedAnswers[_currentIndex],
                        onChanged: _quizSubmitted ? null : _selectAnswer,
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _previousQuestion,
                        child: Text('Previous'),
                      ),
                      ElevatedButton(
                        onPressed: _currentIndex == totalQuestions - 1 ? _submitQuiz : _nextQuestion,
                        child: Text(_currentIndex == totalQuestions - 1 ? 'Submit' : 'Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildQuizResults() {
    // Implement your logic to calculate score
    int correctAnswers = 0;
    List<Widget> results = [];

    widget.quizData.asMap().forEach((index, question) {
      final selectedAnswer = _selectedAnswers[index];
      final correctAnswer = question['answer'];
      final isCorrect = selectedAnswer == correctAnswer;

      results.add(
  Container(
    margin: EdgeInsets.symmetric(vertical: 8.0), // Add vertical spacing between items
    padding: EdgeInsets.all(10.0), // Add padding inside the container
    decoration: BoxDecoration(
      color: Colors.black, // Background color (dark theme)
      border: Border.all(color: Colors.grey), // Border color and width
      borderRadius: BorderRadius.circular(10.0), // Rounded corners
    ),
    child: ListTile(
      title: Text(
        question['question'],
        style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold), // Larger, bold question text
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5.0), // Space between question and answers
          Text(
            'Your Answer: ${selectedAnswer ?? 'No answer selected'}',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Correct Answer: $correctAnswer',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green), // Make correct answer text green
          ),
        ],
      ),
      trailing: isCorrect
          ? Icon(Icons.check, color: Colors.green, size: 30.0) // Larger green check icon
          : Icon(Icons.close, color: Colors.red, size: 30.0), // Larger red close icon
    ),
  ),
);


      if (isCorrect) {
        correctAnswers++;
      }
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Quiz Score: $correctAnswers/${widget.quizData.length}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Navigate back to homepage
          },
          child: Text('Back to Chat'),
        ),
        SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: results,
            ),
          ),
        ),
      ],
    );
  }
}
