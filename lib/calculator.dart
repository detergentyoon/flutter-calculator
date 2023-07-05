import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Material Design Pattern으로 설계
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(primarySwatch: Colors.lightGreen),
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {

  /// 현재 계산기에 표시되는 계산식을 나타내는 문자열
  ///
  /// 사용자가 입력한 계산식을 보여주기 위한 역할
  /// 사용자가 버튼을 누를 때마다 `equation` 변수가 업데이트되어 계산식이 동적으로 표시됨
  String equation = "0";

  String result = "0";

  double equationFontSize = 38.0;
  double resultFontSize = 28.0;

  /// 계산식을 포함한 문자열의 각 항을 저장하는 리스트
  ///
  /// 이전 계산식을 참조할 수 있음
  List<String> equations = [];

  buttonPressed(String btnText) { // 버튼의 문자를 통해 인식
    setState(() {
      final lastChar = equation.substring(equation.length - 1);
      List<String> operators = ['+', '-', '×', '÷'];
      List<String> numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9' ,'0'];

      if (btnText == "C") {
        equation = "0";
        result = "0";
        equations.clear(); // .clear(): 계산식에 포함된 모든 항을 제거
      }

      else if (btnText == "←") {
        equation = equation.substring(0, equation.length - 1); // 문자열 끝단 길이 1 제거
        if (equation.isEmpty) {
          equation ="0";
          result = "0";
        }
      }

      else if (btnText == "%") {
        equation += "%";
        if (equation.isNotEmpty) {
          String valueStr = equation.substring(0, equation.length - 1);
          double value = double.parse(valueStr);
          double percentValue = value / 100;

          equation = percentValue.toString();
          result = calculateResult();
        }
      }

      //------------------------------------ 수정 요망 -------------------------------------
      // 0이 아닌 상태에서 소숫점 입력 시 뒤에 기존 숫자에 0이 추가됨
      else if (btnText == ".") {
        if (lastChar == "0") {
          equation = equation + btnText;
        } else {
          equation = equation + "0" + btnText; // <-- 이 부분
        }
        if(lastChar =="."){
          equation = equation.substring(0, equation.length - 2);
        }
      }
      //-----------------------------------------------------------------------------------

      // 연산 부호 교체
      else if (operators.contains(lastChar) && operators.contains(btnText)){
        if (equation.length > 1) {
          // 하나의 연산 기호가 입력된 상태에서 다른 기호를 입력하면 새로 입력한 부호로 교체됨
          equation = equation.substring(0, equation.length - 1); // 기존 부호를 계산식에서 삭제
        } else { // 초기값에서 연산 기호로 첫 입력을 시도하면 입력을 무효화함
          equation = "0";
        }
        equation = equation + btnText; // 사용자가 입력한 부호를 계산식에 추가
      }

      // 계산 수행
      else if (btnText == "=") {
        equations.add(equation); // 현재 계산식을 추가
        String expression = equations.join(); // 계산식들을 이어붙임
        expression = expression.replaceAll('×', '*').replaceAll('÷', '/');
        try {
          Parser p = Parser();
          Expression exp = p.parse(expression);

          ContextModel cm = ContextModel(); // 수학 표현식에서 변수의 값을 참조할 수 있도록 함
          double evalResult = exp.evaluate(EvaluationType.REAL, cm);

          // 계산식에 백분율 연산이 포함되어 있을 경우, 그 연산식의 결괏값을 참조하여 계산을 진행함
          if (equation.contains("%")) {
            double percentage = double.parse(equation.substring(0, equation.indexOf('%'))) / 100;
            evalResult *= percentage;
          }
          result = evalResult.toString();

          equations.clear(); // 이전 계산식은 초기화
          equation = result; // 결과 값은 현재 계산식으로 대체함
        } catch (e) {
          result = result;
        }
      }

      else {
        equationFontSize = 38.0;
        resultFontSize = 28.0;

        if (equation == "0" && operators.contains(btnText)) {
          return; // 첫 번째 값에서 가장 먼저 연산 기호를 입력한 경우 입력 무효화
        }

        if (equation == "0") {
          equation = btnText; // 0을 처음 누른 숫자로 변경
        } else {
          equation += btnText; // 입력마다 문자를 뒤로 이어 붙힘
        }
        String expression = equation.replaceAll('×', '*').replaceAll('÷', '/');

        try {
          Parser p = Parser();
          Expression exp = p.parse(expression);

          ContextModel cm = ContextModel();
          result = '${exp.evaluate(EvaluationType.REAL, cm)}';
        } catch (e) {
          result = result;
        }
      }
    });
  }

  /// 계산식을 포함한 문자열을 수학 표현식으로 바꿔 계산한 다음, 다시 문자열로 바꿔주는 함수
  String calculateResult() {
    String expression = equation;
    expression = expression.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('%', '*0.01');

    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);

      ContextModel cm = ContextModel();
      double evalResult = exp.evaluate(EvaluationType.REAL, cm);

      // // 계산 결과가 정수인지 확인하고, 불필요한 소수점과 이하 숫자는 제거하여 깔끔한 결과를 제공하는 역할의 분기문
      // if (evalStr.endsWith('.0')) {
      //   // 문자열의 마지막 두 문자(소수점과 소수점 이하 숫자)를 제거하여 정수 부분만 출력
      //   evalStr = evalStr.substring(0, evalStr.length - 2); // ex) '5.0' ==> '5' 변환
      // }

      return evalResult.toString();
    } catch (e) {
      // result = result;
      return "ERROR";
    }

  }

  Widget buildButton(String btnText, double btnHeight, double txtSize, Color btnColor, Color btnTxtColor) {
    Widget button = TextButton(
      onPressed: () => buttonPressed(btnText),
      child: Text(
        btnText,
        style: TextStyle(
          fontSize: txtSize,
          fontWeight: FontWeight.normal,
          color: btnTxtColor,
        ),
      ),
    );

    if (btnText == "←") {
      button = Align(
        alignment: Alignment.centerRight, // 우측 정렬
        child: button,
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.1 * btnHeight,
      child: button,
      color: btnColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: <Widget>[
            Container(height: 120.0), // 상단 여백

            Container( // 계산식
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(10, 20, 80, 0),
              child: Text(equation, style: TextStyle(fontSize: equationFontSize),),
            ),

            Container( // 결괏값
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(10, 20, 80, 0),
              child: Text(result, style: TextStyle(fontSize: resultFontSize, color: Colors.grey),),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 80, 10), // "←" 버튼 위아래 여백
              child: buildButton("←", 1, 30.0, Color.fromARGB(255, 250, 250, 250), Colors.lightGreen),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0), // 구분선 위아래 여백
              child: Container(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                child: Divider(),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 10.0), // 구분선과 Row 사이의 여백
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * .75,
                    child: Table(
                      children: [
                        TableRow(
                          children: [
                            buildButton("C", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Colors.red),
                            buildButton("( )", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Color.fromARGB(255, 68, 149, 55)),
                            buildButton("%", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Color.fromARGB(255, 68, 149, 55)),
                            buildButton("÷", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Color.fromARGB(255, 68, 149, 55)),
                          ]
                        ),

                        TableRow(
                          children: [
                            buildButton("7", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Colors.black87),
                            buildButton("8", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Colors.black87),
                            buildButton("9", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Colors.black87),
                            buildButton("×", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Color.fromARGB(255, 68, 149, 55)),
                          ]
                        ),

                        TableRow(
                          children: [
                            buildButton("4", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Colors.black87),
                            buildButton("5", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Colors.black87),
                            buildButton("6", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Colors.black87),
                            buildButton("-", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Color.fromARGB(255, 68, 149, 55)),
                          ]
                        ),

                        TableRow(
                          children: [
                            buildButton("1", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Colors.black87),
                            buildButton("2", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Colors.black87),
                            buildButton("3", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Colors.black87),
                            buildButton("+", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Color.fromARGB(255, 68, 149, 55)),
                          ]
                        ),

                        TableRow(
                          children: [
                            buildButton("+/-", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Colors.black87),
                            buildButton("0", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Colors.black87),
                            buildButton(".", 1, 43.0, Color.fromARGB(255, 250, 250, 250), Colors.black87),
                            buildButton("=", 1, 43.0, Colors.lightGreen, Colors.white),
                          ]
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        )
    );
  }
}
