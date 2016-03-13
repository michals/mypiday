library spiral;

import 'dart:math' as math;

abstract class SpiralRenderer {
  drawItem(num x, num y, num angle, num size, int index);
}

class Spiral {
  final int totalItems;
  final num density;
  final num lineDensity = 0.1;

  // items per round
  num _ipr;

  // first item radius
  num _cr;

  SpiralRenderer renderer;

  Spiral({this.totalItems: 1000, this.density: 1.0}) {
    _ipr = _determineIpr();
    _cr = math.PI / _ipr;
  }

  draw(SpiralRenderer renderer, {num startAngle: 0}) {
    num dAngle = math.PI * 2 / (_ipr); // delta angle
    num dRadius = (1 - ((_ipr * lineDensity) / totalItems)); // delta radius
    num theta;
    num r = 1;
    num x, y;
    for (int i = 0; i < totalItems; i++) {
      theta = startAngle + (i * density * dAngle);
      r = math.pow(dRadius, i * density);
      x = r * math.sin(theta);
      y = r * -math.cos(theta);
      renderer.drawItem(x, y, theta, _cr * r, i);
    }
  }

  num _itemRadius(num ipr, int i) {
    num dRadius = (1 - ((ipr * lineDensity) / totalItems));
    num r = math.pow(dRadius, i);
    return (math.PI / ipr) * r;
  }

  num _determineIpr() {
    int ipr;
    num r0, rspr, rspr2;
    num rr0, rrspr, rrspr2;
    num cr;
    for (ipr = 10; ipr <= 110; ipr++) {
      r0 = _itemRadius(ipr, 0);
      rspr = _itemRadius(ipr, ipr);
      rspr2 = _itemRadius(ipr, (ipr * 0.5).ceil());
      cr = math.PI / ipr; // small circle radius
      rr0 = cr * r0;
      rrspr = cr * rspr;
      rrspr2 = cr * rspr2;
      if (r0 - rspr - rr0 - rrspr > 2 * rrspr2) {
        return ipr;
      }
    }
    return null; // just some fallback
  }

}
