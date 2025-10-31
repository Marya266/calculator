import 'package:flutter/material.dart';
import 'dart:math'; // Добавляем этот импорт

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false, // Убираем debug надпись
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  bool _lastOperationCompleted = false;
  String? _lastPressedButton;

  void _onButtonPressed(String value) {
    setState(() {
      _lastPressedButton = value;
      
      if (_lastOperationCompleted && _isNumber(value)) {
        _display = value;
        _expression = value;
        _lastOperationCompleted = false;
        return;
      }

      if (_display == '0' && _isNumber(value)) {
        _display = value;
        _expression = value;
      } else if (value == '^') {
        _display += '^';
        _expression += '^';
      } else if (_isOperator(value) && _isOperator(_getLastChar())) {
        _display = _display.substring(0, _display.length - 1) + value;
        _expression = _expression.substring(0, _expression.length - 1) + value;
      } else {
        _display += value;
        _expression += value;
      }
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _lastPressedButton = null;
        });
      }
    });
  }

  bool _isNumber(String value) {
    return double.tryParse(value) != null;
  }

  bool _isOperator(String value) {
    return ['+', '-', '*', '/', '^'].contains(value);
  }

  String _getLastChar() {
    return _display.isNotEmpty ? _display[_display.length - 1] : '';
  }

  void _calculateResult() {
    try {
      if (_expression.isEmpty) return;

      // Проверка деления на ноль
      if (_expression.contains('/0')) {
        throw Exception('Деление на ноль');
      }

      double result = _evaluateExpression(_expression);
      
      setState(() {
        _display = _formatNumber(result);
        _expression = _formatNumber(result);
        _lastOperationCompleted = true;
      });
    } catch (e) {
      setState(() {
        _display = 'Ошибка';
        _expression = '';
        _lastOperationCompleted = true;
      });
    }
  }

  double _evaluateExpression(String expression) {
    try {
      // Упрощенная реализация вычислений
      expression = expression.replaceAll(' ', '');
      
      // Обработка степени
      expression = expression.replaceAll('^', '**');
      
      // Используем JavaScript-like вычисления через рекурсию
      return _parseExpression(expression);
    } catch (e) {
      throw Exception('Некорректное выражение');
    }
  }

  double _parseExpression(String expression) {
    // Упрощенный парсер выражений
    List<String> tokens = _tokenize(expression);
    return _parseTokens(tokens);
  }

  List<String> _tokenize(String expression) {
    // Разбиваем выражение на токены
    List<String> tokens = [];
    String currentToken = '';
    
    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];
      
      if (_isOperator(char) || char == '(' || char == ')') {
        if (currentToken.isNotEmpty) {
          tokens.add(currentToken);
          currentToken = '';
        }
        tokens.add(char);
      } else {
        currentToken += char;
      }
    }
    
    if (currentToken.isNotEmpty) {
      tokens.add(currentToken);
    }
    
    return tokens;
  }

  double _parseTokens(List<String> tokens) {
    // Простая реализация вычисления токенов
    double result = double.parse(tokens[0]);
    
    for (int i = 1; i < tokens.length; i += 2) {
      if (i + 1 >= tokens.length) break;
      
      String operator = tokens[i];
      double nextNum = double.parse(tokens[i + 1]);
      
      switch (operator) {
        case '+':
          result += nextNum;
          break;
        case '-':
          result -= nextNum;
          break;
        case '*':
          result *= nextNum;
          break;
        case '/':
          if (nextNum == 0) throw Exception('Деление на ноль');
          result /= nextNum;
          break;
        case '**':
          result = _power(result, nextNum);
          break;
      }
    }
    
    return result;
  }

  double _power(double base, double exponent) {
    return pow(base, exponent).toDouble(); // Исправлено: pow вместо Math.pow
  }

  String _formatNumber(double num) {
    if (num % 1 == 0) {
      return num.toInt().toString();
    } else {
      return num.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    }
  }

  void _deleteLast() {
    setState(() {
      if (_display.isNotEmpty) {
        _display = _display.substring(0, _display.length - 1);
        _expression = _expression.substring(0, _expression.length - 1);
        if (_display.isEmpty) {
          _display = '0';
          _expression = '';
        }
      }
    });
  }

  void _clearDisplay() {
    setState(() {
      _display = '0';
      _expression = '';
      _lastOperationCompleted = false;
    });
  }

  Widget _buildCalculatorButton(String text, {Color? color, bool isWide = false}) {
    final isPressed = _lastPressedButton == text;
    
    return Container(
      margin: const EdgeInsets.all(2),
      width: isWide ? 110 : 50,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (text == '=') {
            _calculateResult();
          } else if (text == 'C') {
            _deleteLast();
          } else if (text == 'AC') {
            _clearDisplay();
          } else {
            _onButtonPressed(text);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isPressed 
              ? (color ?? Colors.blue).withOpacity(0.7)
              : color ?? Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: isPressed ? 2 : 4,
          shadowColor: Colors.black26,
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _display,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Calculator buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                padding: const EdgeInsets.all(4),
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                children: [
                  _buildCalculatorButton('AC', color: Colors.red),
                  _buildCalculatorButton('C', color: Colors.orange),
                  _buildCalculatorButton('(', color: Colors.grey),
                  _buildCalculatorButton(')', color: Colors.grey),
                  
                  _buildCalculatorButton('7'),
                  _buildCalculatorButton('8'),
                  _buildCalculatorButton('9'),
                  _buildCalculatorButton('/', color: Colors.green),
                  
                  _buildCalculatorButton('4'),
                  _buildCalculatorButton('5'),
                  _buildCalculatorButton('6'),
                  _buildCalculatorButton('*', color: Colors.green),
                  
                  _buildCalculatorButton('1'),
                  _buildCalculatorButton('2'),
                  _buildCalculatorButton('3'),
                  _buildCalculatorButton('-', color: Colors.green),
                  
                  _buildCalculatorButton('0'),
                  _buildCalculatorButton('.'),
                  _buildCalculatorButton('^', color: Colors.purple),
                  _buildCalculatorButton('+', color: Colors.green),
                  
                  _buildCalculatorButton('=', color: Colors.blue, isWide: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}