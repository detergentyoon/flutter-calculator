import 'package:flutter/material.dart';

// Control에서 사용될 변수
var displayNumber = '0';
var makeNumber = '';        // 사용자 입력을 통해 나타나는 숫자
var selectedOperator = '-';
var displayFontSize = 80.0;
var pointExist = false;     // 소수점이 존재하는 경우

var firstNumber = 0.0;
var secondNumber = 0.0;

var _designPage = new DesignPage();

/// ▼ 숫자 키 입력 함수
///
/// 숫자키와 소숫점을 눌렀을 때 적용됨.
///
/// 처음 입력 시 문자열의 형태로 저장되고
/// 이후 연산할 때 double 형의 숫자로 변경된다
void _numberOnPressed(String st) {
  bool inputAdd = true;

  if (makeNumber.length < 9) { // 숫자는 9자리 까지만 입력 가능
    if (st == '.') { // 소숫점이 눌러졌을 경우
      if (makeNumber.isEmpty == true) { // 아무 값도 누르지 않은 상태이면
        makeNumber += '0.';
        inputAdd = false;
      } else {
        if (pointExist == true)
          inputAdd = false; // 소수점이 없을 경우만 추가
      }
      pointExist = true;
    }
    else if(st == '0' && makeNumber.isEmpty == true) inputAdd = false;

    if (inputAdd == true)  makeNumber += st;

    displayNumber = makeNumber;

    if (displayNumber.length < 7) displayFontSize = 80.0;
    else displayFontSize = 50; // 화면에 나타난 숫자가 7자 이상인 경우 폰트 사이즈를 줄임

    _designPage.setState(() { displayNumber; }); // 화면을 갱신시킴
  }
}

/// ▼ 연산자 키 입력 함수
///
/// 4개의 연산 키를 눌렀을 때 적용됨
void _operatorOnPressed(String st) {
  _resultOnPressed('=');

  selectedOperator = st;
  firstNumber = double.parse(displayNumber);

  makeNumber = '';
  pointExist = false;
}

/// ▼ 연산결과(=), 클리어(C) 키 입력 함수
void _resultOnPressed(String st) {
  if (st == 'C') { // clear input
    makeNumber = ''; // clear clicked
    displayNumber = '0';
    selectedOperator = '+';
  } else {
    secondNumber = double.parse(makeNumber);
    makeNumber = '';

    var result = 0.0;

    switch (selectedOperator) {
      case '+': result = firstNumber + secondNumber; break;
      case '-': result = firstNumber - secondNumber; break;
      case 'x': result = firstNumber * secondNumber; break;
      case '/': result = firstNumber / secondNumber; break;
    }
    displayNumber = result.toString();
  }
  pointExist = false;

  // 화면을 갱신시킴
  _designPage.setState(() {
    displayNumber;
    makeNumber;
    pointExist;
  });
}

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Material Design Pattern으로 설계
      title: 'Calculator', // 앱의 한 줄 설명(기능은 없음)
      theme: ThemeData(primarySwatch: Colors.lightGreen), // 앱의 테마 지정
      home: MainPage(), // 실질적인 화면 UI가 구현되는 위젯(Scaffold)
    );
  }
}

// 주 화면 클래스
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  // createState(): 위젯 트리의 위젯과 상태 클래스를 연결
  DesignPage createState() => _designPage; // DesignPage 클래스 생성자 호출
}

// Scaffold(UI를 그리는 도화지) 클래스
// Scaffold의 기본 구조는 크게 3 영역으로 나뉨
// - AppBar: 상단바(앱 제목)
// - Body: 앱 동작의 주요 영역
// - BottomNavigationBar: 하단바(다른 창으로 이동할 수 있는 버튼들이 있는 영역)
class DesignPage extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(// 앱의 주요 화면 UI 영역 (Column 위젯을 사용)
          crossAxisAlignment: CrossAxisAlignment.stretch, // Column 컨테이너의 좌우를 꽉 차게 정렬
          children: <Widget>[ // 여러 개의 위젯들을 List 형태로 할당하여 구현
            Container(
              padding: EdgeInsets.all(30), // Container 내부 전체 여백 30 (각 버튼 간에 여유 공간 확보) <- ???
              alignment: Alignment(1.0, 1.0), // 내부 위젯의 위치를 우측 하단으로 설정
                                              // x: 좌(-)에서 우(+),  y: 상(-)에서 하(+) == 즉 제4사분면에 위치함
              color: Colors.white, // 배경색 지정
              height: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * 0.30,
              // Container의 높이를 전체화면의 30%로 설정
              // 기기 별로 화면 사이즈가 다르기 때문에, 기기의 세로값을 불러와 세로값의 30%의 크기로 자동 생성함

              child: displayText(caption: '$displayNumber', fontsize: displayFontSize,),
              // Text 위젯을 생성하고 Container에 할당
            ),
            Container(
              padding:EdgeInsets.only(left: 15, right: 15) ,
              child: Divider() // 구분선 추가
            ),
            ButtonGroupWidget(), // 버튼 그룹 위젯 생성
          ],
        ),
      ),
      backgroundColor: Colors.white, // 화면 전체 배경색 지정
    );
  }
}

// Text 위젯(버튼 역할) 클래스
class displayText extends StatelessWidget {
  // 생성자 정의
  displayText({super.key, required this.caption, required this.fontsize});
  // 생성자 매개변수
  final String caption;
  final double fontsize;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$caption',
      style: TextStyle(color: Colors.black, backgroundColor: Colors.white, fontSize: fontsize,),
      textAlign: TextAlign.right,
    );
  }
}

// 버튼 위젯 클래스 (버튼 모양 틀)
//
// 버튼을 하나하나 개별적으로 만들지 않고 아래 클래스를 모형틀로 사용해, 속성값만 주어서 버튼을 생성
class CalButton extends StatelessWidget {
  // 생성자 정의
  CalButton({super.key, required this.caption, required this.bgColor, required this.fontColor, required this.kind});
  // 생성자 매개변수
  final String caption; // 버튼에 들어갈 문자
  final Color bgColor; // 버튼의 배경색
  final Color fontColor; // 버튼의 폰트색
  final int kind; // 입력된 버튼의 기능 분류(0:숫자, 1:연산, 2:기능)

  @override
  Widget build(BuildContext context) {
    // ElevatedButton(): 눌림에 응답하는 버튼 위젯
    //
    // 사용자와 상호작용하는 요소를 제공
    // 버튼을 클릭하면 지정된 동작을 수행
    return ElevatedButton(
      onPressed: () {
        switch (kind) {
          case 0: _numberOnPressed(caption); break;
          case 1: _operatorOnPressed(caption); break;
          case 2: _resultOnPressed(caption); break;
        }
      }, // 버튼 입력 이벤트 처리
      style: ElevatedButton.styleFrom(
        elevation: 0, // 버튼 테두리에 그림자 제거
        backgroundColor: bgColor,
        fixedSize: Size(
            (MediaQuery.of(context).size.width / 4) - 30,
            (MediaQuery.of(context).size.width / 4) - 20
        ),
        shape: const CircleBorder(), // 버튼 모양 => 원형
      ), // 버튼 스타일 정의

      // 버튼에 들어가는 글자의 스타일
      child: Text('$caption', style: TextStyle(fontSize: 40, color: fontColor),
      ),
    );
  }
}

// 버튼 그룹 위젯
//
// 버튼 위젯 클래스인 CalButton을 이용하여 4 x 5 행열의 키보드 위젯 생성
// Table Layout 위젯을 사용
class ButtonGroupWidget extends StatelessWidget {
  // 기본 생성자
  const ButtonGroupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder(borderRadius: BorderRadius.zero), // Table 그리드 선 제거
      columnWidths: const <int, TableColumnWidth> {
        0: FlexColumnWidth(),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle, // Table 셀의 내용을 중앙으로 정렬
      children: <TableRow>[
        TableRow(
            decoration: const BoxDecoration(color: Colors.white,),
            children: <Widget> [
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: 'C', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Colors.red, kind: 2,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '( )', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Color.fromARGB(255, 68, 149, 55), kind: 1,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '%', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Color.fromARGB(255, 68, 149, 55), kind: 1,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '÷', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Color.fromARGB(255, 68, 149, 55), kind: 1,),),
            ]
        ),
        TableRow(
            decoration: const BoxDecoration(color: Colors.white,),
            children: <Widget> [
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '7', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Colors.black87, kind: 0,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '8', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Colors.black87, kind: 0,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '9', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Colors.black87, kind: 0,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: 'x', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Color.fromARGB(255, 68, 149, 55), kind: 1,),),
            ]
        ),
        TableRow(
            decoration: const BoxDecoration(color: Colors.white,),
            children: <Widget> [
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '4', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Colors.black87, kind: 0,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '5', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Colors.black87, kind: 0,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '6', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Colors.black87, kind: 0,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: 'ㅡ', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Color.fromARGB(255, 68, 149, 55), kind: 1,),),
            ]
        ),
        TableRow(
            decoration: const BoxDecoration(color: Colors.white,),
            children: <Widget> [
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '1', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Colors.black87, kind: 0,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '2', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Colors.black87, kind: 0,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '3', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Colors.black87, kind: 0,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '+', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Color.fromARGB(255, 68, 149, 55), kind: 1,),),
            ]
        ),
        TableRow(
            decoration: const BoxDecoration(color: Colors.white,),
            children: <Widget> [
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '+/-', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Colors.black87, kind: 1,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '0', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Colors.black87, kind: 0,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '.', bgColor: Color.fromARGB(255, 250, 250, 250), fontColor: Colors.black87, kind: 0,),),
              Padding(padding: EdgeInsets.all(5), child: CalButton(caption: '=', bgColor: Colors.lightGreen, fontColor: Colors.white, kind: 2,),),
            ]
        ),
      ],
    );
  }
}