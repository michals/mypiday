library cloudlesspiday;

import 'dart:html';
import 'dart:math' as math;

import 'spiral.dart';
import 'pidigits.dart' as pi;
import 'utils.dart' as utils;


main() async {
  InputElement inputEl = querySelector('#input');
  inputEl.focus();
  inputEl.onKeyUp.listen((KeyboardEvent event) async {
    if (event.keyCode == 13) {
      var dateStr = (event.target as InputElement).value;
      try {
        var date = DateTime.parse(dateStr);
        inputEl.readOnly = true;
        querySelector("#wait").style.display = 'block';
        await doSearch(date);
        querySelector("#inputBox").style.display = 'none';
      } catch (e) {
        utils.log(e);
      }
    }
  });
}

doSearch(DateTime date) async {
  var yy = utils.pad02(date.year % 100);
  var mm = utils.pad02(date.month);
  var dd = utils.pad02(date.day);
  var query = '${yy}${mm}${dd}';
  print('Searching for $query ...');
  var index = await pi.dateToIndex(query);
  print('index is $index');
  int resolution = 10000; // max digits to draw (in case of huge index)
  int size = math.min((index ~/ 2), resolution ~/ 2); // digits in single spiral
  String digitsHead = await pi.getPiDigits(0, size);
  var extra = 5; // extra 5 digits after query
  const dots = "...";
  var tailIndex = index - size + query.length + extra;
  String digitsTail = await pi.getPiDigits(tailIndex, size);
  digitsHead = genHeadString(digitsHead, size);
  var queryBullets = genBulletsQuery(query);
  digitsTail =
      genTailString(digitsTail, size, extra, query, queryBullets, dots);
  Spiral spiral = new Spiral(totalItems: size, density: 0.75);
  CanvasElement canvas = querySelector("#canvas");
  var rendererHead = new PiSpiralRenderer(canvas, digitsHead, "red");
  var rendererTail = new PiSpiralRenderer(
      canvas, digitsTail, "white", isTail: true,
      queryIndex: extra + dots.length,
      query: queryBullets);
  var ctx = canvas.getContext("2d");
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  spiral.draw(rendererHead, startAngle: math.PI * (-0.1));
  spiral.draw(rendererTail, startAngle: math.PI * (0.9));
  drawPi(canvas, index + 1);
}

// add "3.1" prefix, trim to sieze
String genHeadString(String digitsHead, size) {
  return ("3." + digitsHead).substring(0, size);
}

// change "810217" into "81•02•17"
String genBulletsQuery(query) {
  const bullet = "•";
  return query.substring(0, 2) + bullet + query.substring(2, 4) +
      bullet + query.substring(4, 6);
}

// add dots, replace query with bulletsQuery, reverse, trim
String genTailString(String digitsTail, size, extra, query, queryBullets,
    dots) {
  var qi = digitsTail.length - extra - query.length;
  digitsTail = digitsTail.replaceRange(qi, qi + query.length, queryBullets);
  digitsTail = (digitsTail + dots)
      .split('')
      .reversed
      .join()
      .substring(0, size);
  return digitsTail;
}

// draw big Pi and text
drawPi(CanvasElement canvas, int index) {
  CanvasRenderingContext2D ctx = canvas.getContext("2d");
  var min = math.min(canvas.width, canvas.height);
  var cx = min / 2;
  var cy = min / 2;
  num fontSize = min * 0.8;
  String pi = "π";
  ctx.beginPath();
  ctx.font = "${fontSize}px Times New Roman";
  var pim = ctx.measureText(pi);
  ctx.fillStyle = "rgb(231, 46, 46)";
  ctx.lineWidth = 6;
  ctx.strokeStyle = "black";
  ctx.strokeText(pi, cx - pim.width / 2, cy + pim.width / 2);
  ctx.fillText(pi, cx - pim.width / 2, cy + pim.width / 2);
  fontSize = min * 0.04;
  ctx.font = "${fontSize}px Times New Roman";
  var text = "My browser found my pi day @ pi digit " + (index + 1).toString();
  var textm = ctx.measureText(text);
  ctx.fillText(text, cx - textm.width / 2, min);
  ctx.closePath();
}


class PiSpiralRenderer extends SpiralRenderer {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  num cx;
  num cy;
  num radius;
  String color;
  String digits;
  bool isTail;
  int queryIndex;
  String query;
  String qColor;
  static const TAU = math.PI * 2;

  PiSpiralRenderer(CanvasElement this.canvas, this.digits, this.color,
      {this.isTail: false, this.queryIndex: -1, this.query: "", this.qColor: "#FF8000"}) {
    ctx = canvas.getContext("2d");
    var min = math.min(canvas.width, canvas.height);
    cx = min / 2;
    cy = min / 2;
    var outerMargin = 0.15;
    radius = math.min(cx, cy) * (1 - outerMargin);
  }

  drawItem(num x, num y, num angle, num size, int index) {
    if (size * radius < 1) {
      return;
    }
    ctx.save();
    ctx.beginPath();
    ctx.lineWidth = 1;
    ctx.strokeStyle = color;
    if (index >= queryIndex && index < queryIndex + query.length) {
      ctx.fillStyle = qColor;
    } else {
      ctx.fillStyle = color;
    }
    var xx = (x * radius) + cx;
    var yy = (y * radius) + cy;
    var fontSize = size * radius * 1.6;
//    ctx.arc(xx, yy, size * radius, 0, TAU, false);
//    ctx.stroke();
    ctx.translate(xx, yy);
    ctx.rotate((isTail) ? angle + (math.PI) : angle);
    ctx.font = "${fontSize}px arial,monospace";
    ctx.fillText(digits[index], -fontSize * 0.275, fontSize * 0.35);
    if (index == queryIndex + query.length - 1) {
      ctx.fillText("▴", -fontSize * 0.275, fontSize * 1.1);
    }
    ctx.closePath();
    ctx.restore();
  }
}
