import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
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
        _expression += '**'; // Используем ** для степени
      } else if (_isOperator(value) && _isOperator(_getLastChar())) {
        // Заменяем последний оператор
        _display = _display.substring(0, _display.length - 1) + value;
        _expression = _expression.substring(0, _expression.length - 1) + value;
      } else {
        _display += value;
        _expression += value;
      }
    });

    // Сбрасываем состояние нажатия через короткое время
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

      // Заменяем все ** на pow для вычисления степени
      String evalExpression = _expression.replaceAll('**', '^');
      
      // Проверка деления на ноль
      if (_expression.contains('/0')) {
        throw Exception('Деление на ноль');
      }

      // Простая реализация вычислений (в реальном приложении лучше использовать парсер выражений)
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
    // Простая реализация вычисления выражения
    // В реальном приложении лучше использовать математический парсер
    try {
      // Упрощенная обработка выражений
      expression = expression.replaceAll(' ', '');
      
      // Обработка степени
      while (expression.contains('**')) {
        final index = expression.indexOf('**');
        final leftPart = expression.substring(0, index);
        final rightPart = expression.substring(index + 2);
        
        final leftNum = _getLastNumber(leftPart);
        final rightNum = _getFirstNumber(rightPart);
        
        final result = _power(leftNum, rightNum);
        expression = leftPart.substring(0, leftPart.length - leftNum.toString().length) + 
                    result.toString() + rightPart.substring(rightNum.toString().length);
      }
      
      // Используем basic eval для остальных операций (в продакшн лучше использовать парсер)
      return _safeEval(expression);
    } catch (e) {
      throw Exception('Некорректное выражение');
    }
  }

  double _getLastNumber(String str) {
    String numStr = '';
    for (int i = str.length - 1; i >= 0; i--) {
      if (_isNumber(str[i]) || str[i] == '.') {
        numStr = str[i] + numStr;
      } else {
        break;
      }
    }
    return double.parse(numStr);
  }

  double _getFirstNumber(String str) {
    String numStr = '';
    for (int i = 0; i < str.length; i++) {
      if (_isNumber(str[i]) || str[i] == '.') {
        numStr += str[i];
      } else {
        break;
      }
    }
    return double.parse(numStr);
  }

  double _power(double base, double exponent) {
    return _safeEval('pow($base, $exponent)');
  }

  double _safeEval(String expression) {
    // Простая реализация для демонстрации
    // В реальном приложении используйте пакет like 'math_expression'
    try {
      // Упрощенная обработка базовых операций
      if (expression.contains('+')) {
        final parts = expression.split('+');
        return _safeEval(parts[0]) + _safeEval(parts[1]);
      } else if (expression.contains('-')) {
        final parts = expression.split('-');
        return _safeEval(parts[0]) - _safeEval(parts[1]);
      } else if (expression.contains('*')) {
        final parts = expression.split('*');
        return _safeEval(parts[0]) * _safeEval(parts[1]);
      } else if (expression.contains('/')) {
        final parts = expression.split('/');
        final divisor = _safeEval(parts[1]);
        if (divisor == 0) throw Exception('Деление на ноль');
        return _safeEval(parts[0]) / divisor;
      } else {
        return double.parse(expression);
      }
    } catch (e) {
      throw Exception('Ошибка вычисления');
    }
  }

  String _formatNumber(double num) {
    if (num % 1 == 0) {
      return num.toInt().toString();
    } else {
      return num.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
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
      margin: const EdgeInsets.all(4),
      width: isWide ? 150 : 70,
      height: 70,
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
            borderRadius: BorderRadius.circular(35),
          ),
          elevation: isPressed ? 2 : 6,
          shadowColor: Colors.black26,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _display,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                padding: const EdgeInsets.all(8),
                children: [
                  // First row
                  _buildCalculatorButton('AC', color: Colors.red),
                  _buildCalculatorButton('C', color: Colors.orange),
                  _buildCalculatorButton('(', color: Colors.grey),
                  _buildCalculatorButton(')', color: Colors.grey),
                  
                  // Second row
                  _buildCalculatorButton('7'),
                  _buildCalculatorButton('8'),
                  _buildCalculatorButton('9'),
                  _buildCalculatorButton('/', color: Colors.green),
                  
                  // Third row
                  _buildCalculatorButton('4'),
                  _buildCalculatorButton('5'),
                  _buildCalculatorButton('6'),
                  _buildCalculatorButton('*', color: Colors.green),
                  
                  // Fourth row
                  _buildCalculatorButton('1'),
                  _buildCalculatorButton('2'),
                  _buildCalculatorButton('3'),
                  _buildCalculatorButton('-', color: Colors.green),
                  
                  // Fifth row
                  _buildCalculatorButton('0'),
                  _buildCalculatorButton('.'),
                  _buildCalculatorButton('^', color: Colors.purple),
                  _buildCalculatorButton('+', color: Colors.green),
                  
                  // Sixth row
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